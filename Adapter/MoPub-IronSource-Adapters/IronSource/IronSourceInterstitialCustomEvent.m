//
//  IronSourceInterstitialCustomEvent.m
//

#import "IronSourceInterstitialCustomEvent.h"
#import "IronSourceAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "IronSourceConstants.h"

@interface IronSourceInterstitialCustomEvent()<IronSourceInterstitialDelegate>
@property (nonatomic, copy) NSString *instanceId;

@property (nonatomic, assign)BOOL isClick;

@end

@implementation IronSourceInterstitialCustomEvent

#pragma mark MoPub IronSourceInterstitialCustomEvent Methods

- (NSString *) getAdNetworkId {
    return _instanceId;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    MPLogInfo(@"Attempting to send ad request to IronSource:requestInterstitialWithCustomEventInfo");
    
    // Collect and pass the user's consent from MoPub onto the ironSource SDK
    if ([[MoPub sharedInstance] isGDPRApplicable] == MPBoolYes) {
        BOOL canCollectPersonalInfo = [[MoPub sharedInstance] canCollectPersonalInfo];
        [IronSource setConsent:canCollectPersonalInfo];
    }
    self.instanceId = kDefaultInstanceId;
    @try{
        NSString *appKey = @"";
        if(info == nil) {
            MPLogInfo(@"serverParams is null. Make sure you have entered ironSource's application and instance keys on the MoPub dashboard");
            NSError *error = [IronSourceUtils createErrorWith:@"Can't initialize IronSource Interstitial"
                                         andReason:@"serverParams is null"
                                     andSuggestion:@"make sure that server parameters are added"];
            
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.instanceId);
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            return;
        }
        
        if ([info objectForKey:kIronSourceAppKey] != nil) {
            appKey = [info objectForKey:kIronSourceAppKey];
        }
        
        if (([info objectForKey:kIronSourceInstanceId] != nil) && (![[info objectForKey:kIronSourceInstanceId] isEqualToString:@""])) {
            self.instanceId = [info objectForKey:kIronSourceInstanceId];
        }
        
        if (![IronSourceUtils isEmpty:appKey]) {
            MPLogInfo(@"IronSource Interstitial initialization with appkey %@", appKey);
            // Cache the initialization parameters
            [IronSourceAdapterConfiguration updateInitializationParameters:info];
            [[IronSourceManager sharedManager] initIronSourceSDKWithAppKey:appKey forAdUnits:[NSSet setWithObject:@[IS_INTERSTITIAL]]];
            [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:request isReward:NO Channel:@"Ironsource"];
            [self loadInterstitial:self.instanceId];
        } else {
            MPLogInfo(@"IronSource Interstitial initialization with empty or nil appKey for instance @s",
                      [self getAdNetworkId]);

            NSError *error = [IronSourceUtils createErrorWith:@"IronSource adapter failed to request interstitial"
                                         andReason:@"ApplicationKey parameter is missing"
                                     andSuggestion:@"Make sure that 'applicationKey' server parameter is added"];
            [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:requestFailed isReward:NO Channel:@"Ironsource"];
            MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
    } @catch (NSException *exception) {
        MPLogInfo(@"IronSource Interstitial initialization with error: %@", exception);
        [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:requestFailed isReward:NO Channel:@"Ironsource"];
        NSError *error = [NSError errorWithDomain:@"MoPubInterstitialSDKDomain" code:MOPUBErrorAdapterInvalid userInfo:@{NSLocalizedDescriptionKey: @"Custom event class Interstitial error.", NSLocalizedRecoverySuggestionErrorKey: @"Native Network or Custom Event adapter was configured incorrectly."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error: error], [self getAdNetworkId]);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    MPLogInfo(@"IronSource is attempting to show interstitial ad for instance %@",
              [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:show isReward:NO Channel:@"Ironsource"];
    self.isClick = NO;
    [[IronSourceManager sharedManager] presentInterstitialAdFromViewController:rootViewController instanceID:self.instanceId];
}

#pragma mark IronSource Methods

- (void)loadInterstitial:(NSString *)instanceId {
    
    MPLogInfo(@"IronSource load interstitial ad for instance %@ (current instance %@)",
              instanceId, [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], instanceId);
    [[IronSourceManager sharedManager] requestInterstitialAdWithDelegate:self instanceID:instanceId];
}

#pragma mark IronSource DemandOnly Delegates implementation

/*!
 * @discussion Called each time an ad is available
 */
- (void)interstitialDidLoad:(NSString *)instanceId {
    NSLog(@"hlyLog:IronSource Interstitial加载成功");
    MPLogInfo(@"IronSource interstitial did load for instance %@ (current instance %@)",
              instanceId, [self getAdNetworkId]);
    [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:requestSuccess isReward:NO Channel:@"Ironsource"];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], instanceId);
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

/*!
 * @discussion Called each time an ad is not available
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    NSLog(@"hlyLog:IronSource Interstitial加载失败");
    MPLogInfo(@"IronSource interstitial ad did fail to load with error: %@, instanceId: %@ (current instanceId is %@)",
              error.localizedDescription, instanceId, [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], instanceId);
    [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:requestFailed isReward:NO Channel:@"Ironsource"];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

/*!
 * @discussion Called each time the Interstitial window did open
 */
- (void)interstitialDidOpen:(NSString *)instanceId {
    MPLogInfo(@"IronSource interstitial did open for instance %@ (current instance %@)",
              instanceId, [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], instanceId);
    [self.delegate interstitialCustomEventWillAppear:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Ironsource" forKey:@"hwintertype"];
    [defaults synchronize];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], instanceId);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], instanceId);
    [self.delegate interstitialCustomEventDidAppear:self];
}

/*!
 * @discussion Called each time the Interstitial window did close
 */
- (void)interstitialDidClose:(NSString *)instanceId {
    NSLog(@"hlyLog:IronSource Interstitial关闭");
    MPLogInfo(@"IronSource interstitial did close for instance %@ (current instance %@)",
              instanceId, [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], instanceId);
    [self.delegate interstitialCustomEventWillDisappear:self];
    [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:showSuccess isReward:NO Channel:@"Ironsource"];
    [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:AdClose isReward:NO Channel:@"Ironsource"];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], instanceId);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

/*!
 * @discussion Called if showing the Interstitial for the user has failed.
 *
 *              You can learn about the reason by examining the ‘error’ value
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    MPLogInfo(@"IronSource interstitial did fail to show for instance %@ (current instance %@)",
              instanceId, [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], instanceId);
    [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:showFailed isReward:NO Channel:@"Ironsource"];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];

}

/*!
 * @discussion Called each time the end user has clicked on the Interstitial ad.
 */
- (void)didClickInterstitial:(NSString *)instanceId {
    MPLogInfo(@"IronSource interstitial did click for instance %@ (current instance %@)",
              instanceId, [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], instanceId);
    if (!self.isClick) {
        self.isClick = YES;
        [[HwAds instance] hwAdsEventByPlacementId:self.instanceId hwSdkState:click isReward:NO Channel:@"Ironsource"];
    }
    
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end

