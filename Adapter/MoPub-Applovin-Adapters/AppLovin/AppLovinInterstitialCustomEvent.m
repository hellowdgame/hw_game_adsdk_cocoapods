#import "AppLovinInterstitialCustomEvent.h"
#import "AppLovinAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#if __has_include("MoPub.h")
    #import "MPError.h"
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALInterstitialAd.h"
    #import "ALPrivacySettings.h"
#endif

#define DEFAULT_ZONE @""
#define ZONE_FROM_INFO(__INFO) ( ([__INFO[@"zone_id"] isKindOfClass: [NSString class]] && ((NSString *) __INFO[@"zone_id"]).length > 0) ? __INFO[@"zone_id"] : @"" )

@interface AppLovinInterstitialCustomEvent() <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic, strong) ALSdk *sdk;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, copy) NSString *zoneIdentifier; // The zone identifier this instance of the custom event is loading for
@property (nonatomic, assign, getter=isTokenEvent) BOOL tokenEvent;
@property (nonatomic, strong) ALAd *tokenAd;

@end

@implementation AppLovinInterstitialCustomEvent
static NSString *const kALMoPubMediationErrorDomain = @"com.applovin.sdk.mediation.mopub.errorDomain";

// A dictionary of Zone -> Queue of `ALAd`s to be shared by instances of the custom event.
// This prevents skipping of ads as this adapter will be re-created and preloaded
// on every ad load regardless if ad was actually displayed or not.
static NSMutableDictionary<NSString *, NSMutableArray<ALAd *> *> *ALGlobalInterstitialAds;
static NSObject *ALGlobalInterstitialAdsLock;

#pragma mark - Class Initialization

+ (void)initialize
{
    [super initialize];
    
    ALGlobalInterstitialAds = [NSMutableDictionary dictionary];
    ALGlobalInterstitialAdsLock = [[NSObject alloc] init];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

#pragma mark - MPInterstitialCustomEvent Overridden Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    [self requestInterstitialWithCustomEventInfo: info adMarkup: nil];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    
    // Collect and pass the user's consent from MoPub onto the AppLovin SDK
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes) {
        BOOL canCollectPersonalInfo = [[MoPub sharedInstance] canCollectPersonalInfo];
        [ALPrivacySettings setHasUserConsent: canCollectPersonalInfo];
    }
    
    
    self.sdk = [self SDKFromCustomEventInfo: info];
    
    if (self.sdk == nil) {
        NSString *failureReason = @"ALSdk instance is nil likely because no AppLovin SDK key is available. Failing ad request";
        
        NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                             code: kALErrorCodeSdkDisabled
                                         userInfo: @{NSLocalizedFailureReasonErrorKey: failureReason}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], @"");
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError: error];

        return;
    }

    self.sdk.mediationProvider = ALMediationProviderMoPub;
    [self.sdk setPluginVersion: AppLovinAdapterConfiguration.pluginVersion];
    
    [AppLovinAdapterConfiguration setCachedInitializationParameters: info];
    
    BOOL hasAdMarkup = adMarkup.length > 0;
    
    MPLogInfo(@"Requesting AppLovin interstitial with info: %@ and has ad markup: %d", info, hasAdMarkup);
    
    if ( hasAdMarkup )
    {
        self.tokenEvent = YES;
        
        // Use token API
        [self.sdk.adService loadNextAdForAdToken: adMarkup andNotify: self];
        
        MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    }
    else
    {
        self.zoneIdentifier = ZONE_FROM_INFO(info);
        
        // Check if we already have a preloaded ad for the given zone
        ALAd *preloadedAd = [[self class] dequeueAdForZoneIdentifier: self.zoneIdentifier];
        if ( preloadedAd )
        {
            MPLogInfo(@"Found preloaded ad for zone: {%@}", self.zoneIdentifier);

            [self adService: self.sdk.adService didLoadAd: preloadedAd];
        }
        // No ad currently preloaded
        else
        {
            // If this is a default Zone, create the ad normally
            if ( [DEFAULT_ZONE isEqualToString: self.zoneIdentifier] )
            {
                [self.sdk.adService loadNextAd: [ALAdSize sizeInterstitial] andNotify: self];
                
                MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
            }
            // Otherwise, use the Zones API
            else
            {
                [self.sdk.adService loadNextAdForZoneIdentifier: self.zoneIdentifier andNotify: self];
                
                MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
            }
        }
    }
    
    [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:request isReward:NO Channel:@"Applovin"];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
   
    ALAd *preloadedAd;
    
    if ( [self isTokenEvent] && self.tokenAd != nil )
    {
        preloadedAd = self.tokenAd;
    }
    else
    {
        preloadedAd = [[self class] dequeueAdForZoneIdentifier: self.zoneIdentifier];
    }
    
    if ( preloadedAd )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Applovin" forKey:@"hwintertype"];
        [defaults synchronize];
        self.interstitialAd = [[ALInterstitialAd alloc] initWithSdk: self.sdk];
        self.interstitialAd.adDisplayDelegate = self;
        self.interstitialAd.adVideoPlaybackDelegate = self;
        [self.interstitialAd showAd: preloadedAd];
         [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:show isReward:NO Channel:@"Applovin"];
    }
    else
    {
        NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                             code: kALErrorCodeUnableToRenderAd
                                         userInfo: @{NSLocalizedFailureReasonErrorKey : @"Adapter requested to display an interstitial before one was loaded"}];
        
        [self.delegate interstitialCustomEvent: self didFailToLoadAdWithError: error];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:showFailed isReward:NO Channel:@"Applovin"];
    }
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    NSLog(@"hlyLog:Applovin interstitial加载成功");
    [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:requestSuccess isReward:NO Channel:@"Applovin"];
    if ( [self isTokenEvent] )
    {
        self.tokenAd = ad;
    }
    else
    {
        [[self class] enqueueAd: ad forZoneIdentifier: self.zoneIdentifier];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate interstitialCustomEvent: self didLoadAd: ad];

        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    });
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    NSLog(@"hlyLog:Applovin interstitial加载失败");
    [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:requestFailed isReward:NO Channel:@"Applovin"];
    NSError *error = [NSError errorWithDomain: kALMoPubMediationErrorDomain
                                         code: [self toMoPubErrorCode: code]
                                     userInfo: nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate interstitialCustomEvent: self didFailToLoadAdWithError: error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    });
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillAppear: self];
    
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidAppear: self];
    
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate trackImpression];
}


- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    NSLog(@"hlyLog:Applovin interstitial关闭");
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:AdClose isReward:NO Channel:@"Applovin"];
    [self.delegate interstitialCustomEventWillDisappear: self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidDisappear: self];
    
    self.interstitialAd = nil;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent: self];
    [self.delegate interstitialCustomEventWillLeaveApplication: self];
    [self.delegate trackClick];
    [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:click isReward:NO Channel:@"Applovin"];
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

#pragma mark - Video Playback Delegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    MPLogInfo(@"Interstitial video playback ended at playback percent: %lu", (unsigned long)percentPlayed.unsignedIntegerValue);
    if (wasFullyWatched) {
        [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:showSuccess isReward:NO Channel:@"Applovin"];
    }else{
        [[HwAds instance] hwAdsEventByPlacementId:self.zoneIdentifier hwSdkState:showFailed isReward:NO Channel:@"Applovin"];
    }
    
}

#pragma mark - Utility Methods

+ (nullable ALAd *)dequeueAdForZoneIdentifier:(NSString *)zoneIdentifier
{
    @synchronized ( ALGlobalInterstitialAdsLock )
    {
        ALAd *preloadedAd;
        
        NSMutableArray<ALAd *> *preloadedAds = ALGlobalInterstitialAds[zoneIdentifier];
        if ( preloadedAds.count > 0 )
        {
            preloadedAd = preloadedAds[0];
            [preloadedAds removeObjectAtIndex: 0];
        }
        
        return preloadedAd;
    }
}

+ (void)enqueueAd:(ALAd *)ad forZoneIdentifier:(NSString *)zoneIdentifier
{
    @synchronized ( ALGlobalInterstitialAdsLock )
    {
        NSMutableArray<ALAd *> *preloadedAds = ALGlobalInterstitialAds[zoneIdentifier];
        if ( !preloadedAds )
        {
            preloadedAds = [NSMutableArray array];
            ALGlobalInterstitialAds[zoneIdentifier] = preloadedAds;
        }
        
        [preloadedAds addObject: ad];
    }
}

- (MOPUBErrorCode)toMoPubErrorCode:(int)appLovinErrorCode
{
    if ( appLovinErrorCode == kALErrorCodeNoFill )
    {
        return MOPUBErrorAdapterHasNoInventory;
    }
    else if ( appLovinErrorCode == kALErrorCodeAdRequestNetworkTimeout )
    {
        return MOPUBErrorNetworkTimedOut;
    }
    else if ( appLovinErrorCode == kALErrorCodeInvalidResponse )
    {
        return MOPUBErrorServerError;
    }
    else
    {
        return MOPUBErrorUnknown;
    }
}

- (ALSdk *)SDKFromCustomEventInfo:(NSDictionary *)info
{
    // The SDK key is not returned from the MoPub dashboard, so we statically read it
    // for Unity publishers who don't have access to the project's info.plist.
    NSString *SDKKey = AppLovinAdapterConfiguration.sdkKey;
    if ( SDKKey.length > 0 )
    {
        return [ALSdk sharedWithKey: SDKKey];
    }
    else
    {
        return [ALSdk shared];
    }
}

- (NSString *) getAdNetworkId {
    return self.zoneIdentifier;
}

@end
