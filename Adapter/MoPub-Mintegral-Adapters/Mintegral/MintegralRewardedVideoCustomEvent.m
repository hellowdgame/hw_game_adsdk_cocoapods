#import "MintegralRewardedVideoCustomEvent.h"
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKReward/MTGRewardAdManager.h>
#import <MTGSDKReward/MTGBidRewardAdManager.h>
#import "MintegralAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#if __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
#endif
#if __has_include(<MoPubSDKFramework/MPLogging.h>)
    #import <MoPubSDKFramework/MPLogging.h>
#else
    #import "MPLogging.h"
#endif
#if __has_include(<MoPubSDKFramework/MPRewardedVideoReward.h>)
    #import <MoPubSDKFramework/MPRewardedVideoReward.h>
#else
    #import "MPRewardedVideoReward.h"
#endif

@interface MintegralRewardedVideoCustomEvent () <MTGRewardAdLoadDelegate,MTGRewardAdShowDelegate>

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) NSString *adPlacementId;
@property (nonatomic, copy) NSString *adm;

@end

@implementation MintegralRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPLogInfo(@"requestRewardedVideoWithCustomEventInfo for Mintegral");
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appKey = [info objectForKey:@"appKey"];
    NSString *unitId = [info objectForKey:@"unitId"];
    NSString *placementId = [info objectForKey:@"placementId"];
    
    NSString *errorMsg = nil;
    
    if (!appId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appId. Failing ad request. Ensure the app ID is valid on the MoPub dashboard."];
    if (!appKey) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral appKey. Failing ad request. Ensure the app key is valid on the MoPub dashboard."];
    if (!unitId) errorMsg = [errorMsg stringByAppendingString: @"Invalid or missing Mintegral unitId. Failing ad request. Ensure the unit ID is valid on the MoPub dashboard."];
    
    if (errorMsg) {
        NSError *error = [NSError errorWithDomain:kMintegralErrorDomain code:MPRewardedVideoAdErrorInvalidAdUnitID userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
        
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        
        return;
    }
    
    self.adUnitId = unitId;
    self.adPlacementId = placementId;
    self.adm = adMarkup;
    
    [MintegralAdapterConfiguration initializeMintegral:info setAppID:appId appKey:appKey];
    
    if (self.adm) {
        MPLogInfo(@"Loading Mintegral rewarded ad markup for Advanced Bidding");
        [MTGBidRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
        
        [[MTGBidRewardAdManager sharedInstance] loadVideoWithBidToken:self.adm placementId:placementId unitId:unitId delegate:self];
    } else {
        MPLogInfo(@"Loading Mintegral rewarded ad");
        [MTGRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
        [[MTGRewardAdManager sharedInstance] loadVideoWithPlacementId:placementId unitId:unitId delegate:self];
    }
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:request isReward:YES Channel:@"Mintegral"];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.adUnitId);
}

- (BOOL)hasAdAvailable
{
    if (self.adm) {
        return [[MTGBidRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:self.adPlacementId unitId:self.adUnitId];
    } else {
        return [[MTGRewardAdManager sharedInstance] isVideoReadyToPlayWithPlacementId:self.adPlacementId unitId:self.adUnitId];
    }
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        
        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        
        if ([[MTGRewardAdManager sharedInstance] respondsToSelector:@selector(showVideoWithPlacementId:unitId:withRewardId:userId:delegate:viewController:)]) {
            [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:show isReward:YES Channel:@"Mintegral"];
            MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.adUnitId);
            MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.adUnitId);
            
            if (self.adm) {
                [MTGBidRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
                [[MTGBidRewardAdManager sharedInstance] showVideoWithPlacementId:self.adPlacementId unitId:self.adUnitId withRewardId:@"1" userId:customerId delegate:self viewController:viewController];
            } else {
                [MTGRewardAdManager sharedInstance].playVideoMute = [MintegralAdapterConfiguration isMute];
                [[MTGRewardAdManager sharedInstance] showVideoWithPlacementId:self.adPlacementId unitId:self.adUnitId withRewardId:@"1" userId:customerId delegate:self viewController:viewController];
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:showFailed isReward:YES Channel:@"Mintegral"];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)handleAdPlayedForCustomEventNetwork
{
    if (![self hasAdAvailable]) {
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:@"mintegral ad unavailable"], self.adUnitId);
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (void)handleCustomEventInvalidated
{
}

#pragma mark GADRewardBasedVideoAdDelegate
- (void)onVideoAdLoadSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    NSLog(@"hlyLog:Mintergral Reward加载成功");
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:requestSuccess isReward:YES Channel:@"Mintegral"];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)onVideoAdLoadFailed:(NSString *)placementId unitId:(NSString *)unitId error:(NSError *)error {
    NSLog(@"hlyLog:Mintergral Reward加载失败");
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:requestFailed isReward:YES Channel:@"Mintegral"];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)onVideoAdShowSuccess:(NSString *)placementId unitId:(NSString *)unitId {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:showSuccess isReward:YES Channel:@"Mintegral"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Mintegral" forKey:@"hwvideotype"];
    [defaults synchronize];
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    
    if ([self.delegate respondsToSelector:@selector(trackImpression)]) {
        [self.delegate trackImpression];
    } else {
        MPLogWarn(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
}

- (void)onVideoAdShowFailed:(NSString *)placementId unitId:(NSString *)unitId withError:(NSError *)error {
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:showFailed isReward:YES Channel:@"Mintegral"];
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)onVideoAdClicked:(NSString *)placementId unitId:(NSString *)unitId {
    MPLogInfo(@"onVideoAdClicked");
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:click isReward:YES Channel:@"Mintegral"];
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
    
    if ([self.delegate respondsToSelector:@selector(trackClick)]) {
        [self.delegate trackClick];
    } else {
        MPLogWarn(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
}

- (void)onVideoAdDismissed:(NSString *)placementId unitId:(NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(MTGRewardAdInfo *)rewardInfo {    NSLog(@"hlyLog:Mintergral Reward关闭");
    [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:AdClose isReward:YES Channel:@"Mintegral"];
    if (rewardInfo) {
        MPRewardedVideoReward *rewardd = [[MPRewardedVideoReward alloc] initWithCurrencyType:rewardInfo.rewardName amount:[NSNumber numberWithInteger:rewardInfo.rewardAmount]];
        [[HwAds instance] hwAdsEventByPlacementId:self.adUnitId hwSdkState:reward isReward:YES Channel:@"Mintegral"];
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:rewardd];
        
    }else{
        MPLogInfo(@"The rewarded video was not watched until completion. The user will not get rewarded.");
    }
        
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    
}

@end