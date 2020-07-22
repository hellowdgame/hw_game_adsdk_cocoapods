#import "MPGoogleAdMobRewardedVideoCustomEvent.h"
#import "GoogleAdMobAdapterConfiguration.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#if __has_include("MoPub.h")
#import "MPLogging.h"
#import "MPRewardedVideoError.h"
#import "MPRewardedVideoReward.h"
#endif

@interface MPGoogleAdMobRewardedVideoCustomEvent () <GADRewardedAdDelegate>
@property(nonatomic, copy) NSString *admobAdUnitId;
@property(nonatomic, strong) GADRewardedAd *rewardedAd;
@end

@implementation MPGoogleAdMobRewardedVideoCustomEvent

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status){
        MPLogInfo(@"Google Mobile Ads SDK initialized succesfully.");
      }];
    });
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    [self initializeSdkWithParameters:info];
    
    // Cache the network initialization parameters
    [GoogleAdMobAdapterConfiguration updateInitializationParameters:info];
    self.admobAdUnitId = [info objectForKey:@"adunit"];
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:request isReward:YES Channel:@"Admob"];
    if (self.admobAdUnitId == nil) {
        NSError *error =
        [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                            code:MPRewardedVideoAdErrorInvalidAdUnitID
                        userInfo:@{NSLocalizedDescriptionKey : @"Ad Unit ID cannot be nil."}];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:requestFailed isReward:YES Channel:@"Admob"];
        return;
    }
    
    GADRequest *request = [GADRequest request];
    if ([self.localExtras objectForKey:@"testDevices"]) {
      request.testDevices = self.localExtras[@"testDevices"];
    }

    if ([self.localExtras objectForKey:@"tagForChildDirectedTreatment"]) {
      [GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:self.localExtras[@"tagForChildDirectedTreatment"]];
    }

    if ([self.localExtras objectForKey:@"tagForUnderAgeOfConsent"]) {
      [GADMobileAds.sharedInstance.requestConfiguration
          tagForUnderAgeOfConsent:self.localExtras[@"tagForUnderAgeOfConsent"]];
    }

    request.requestAgent = @"MoPub";

    if ([self.localExtras objectForKey:@"contentUrl"] != nil) {
        NSString *contentUrl = [self.localExtras objectForKey:@"contentUrl"];
        if ([contentUrl length] != 0) {
            request.contentURL = contentUrl;
        }
    }
    
    // Consent collected from the MoPub’s consent dialogue should not be used to set up Google's
    // personalization preference. Publishers should work with Google to be GDPR-compliant.
    
    NSString *npaValue = GoogleAdMobAdapterConfiguration.npaString;
    
    if (npaValue.length > 0) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": npaValue};
        [request registerAdNetworkExtras:extras];
    }

    self.rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:self.admobAdUnitId];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    [self.rewardedAd loadRequest:request completionHandler:^(GADRequestError *error){
      if (error) {
          NSLog(@"hlyLog:Google RewardedAd加载失败");
          [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:requestFailed isReward:YES Channel:@"Admob"];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
      } else {
          NSLog(@"hlyLog:%@*****%@",info,adMarkup);
          NSLog(@"hlyLog:Google RewardedAd加载成功");
          [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:requestSuccess isReward:YES Channel:@"Admob"];
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
      }
    }];
}

- (BOOL)hasAdAvailable {
    return self.rewardedAd.isReady;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (self.rewardedAd.isReady) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Admob" forKey:@"hwvideotype"];
        [defaults synchronize];
        [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:show isReward:YES Channel:@"Admob"];
        [self.rewardedAd presentFromRootViewController:viewController delegate:self];
    } else {
        // We will send the error if the rewarded ad has already been presented.
        NSError *error = [NSError
                          errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                          code:MPRewardedVideoAdErrorNoAdReady
                          userInfo:@{NSLocalizedDescriptionKey : @"Rewarded ad is not ready to be presented."}];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:showFailed isReward:YES Channel:@"Admob"];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

// MoPub's API includes this method because it's technically possible for two MoPub custom events or
// adapters to wrap the same SDK and therefore both claim ownership of the same cached ad. The
// method will be called if 1) this custom event has already invoked
// rewardedVideoDidLoadAdForCustomEvent: on the delegate, and 2) some other custom event plays a
// rewarded video ad. It's a way of forcing this custom event to double-check that its ad is
// definitely still available and is not the one that just played. If the ad is still available, no
// action is necessary. If it's not, this custom event should call
// rewardedVideoDidExpireForCustomEvent: to let the MoPub SDK know that it's no longer ready to play
// and needs to load another ad. That event will be passed on to the publisher app, which can then
// trigger another load.
- (void)handleAdPlayedForCustomEventNetwork {
    if (!self.rewardedAd.isReady) {
        // Sending rewardedVideoDidExpireForCustomEvent: callback because the reward-based video ad will
        // not be available once its been presented.
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

#pragma mark - GADRewardedAdDelegate methods

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    MPRewardedVideoReward *moPubReward =
    [[MPRewardedVideoReward alloc] initWithCurrencyType:reward.type amount:reward.amount];
    [self toReward];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:moPubReward];
}
-(void)toReward{
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:showSuccess isReward:YES Channel:@"Admob"];
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:reward isReward:YES Channel:@"Admob"];
}
- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"HW_SCENETAG"];
    NSLog(@"hlyLog:GoogleShow:%@",str);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    // Recording an impression after the reward-based video ad appears on the screen.
    [self.delegate trackImpression];
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:showFailed isReward:YES Channel:@"Admob"];
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    NSLog(@"hlyLog:Google RewardedAd关闭");
  MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
  [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:AdClose isReward:YES Channel:@"Admob"];
  MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
  [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (NSString *) getAdNetworkId {
    return self.admobAdUnitId;
}

@end
