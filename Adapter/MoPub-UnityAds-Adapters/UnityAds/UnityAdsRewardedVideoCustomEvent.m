//
//  UnityAdsRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsRewardedVideoCustomEvent.h"
#import "UnityAdsInstanceMediationSettings.h"
#import "UnityAdsAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#import "UnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoError.h"
    #import "MPLogging.h"
#endif

static NSString *const kMPUnityRewardedVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsRewardedVideoCustomEvent () <UnityRouterDelegate>

@property (nonatomic, copy) NSString *placementId;

@property (nonatomic, assign)BOOL isClick;
@end

@implementation UnityAdsRewardedVideoCustomEvent

- (void)dealloc
{
    [[UnityRouter sharedRouter] clearDelegate:self];
}

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    NSString *gameId = [parameters objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        MPLogInfo(@"Initialization parameters did not contain gameId.");
        return;
    }

    [[UnityRouter sharedRouter] initializeWithGameId:gameId];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    NSString *gameId = [info objectForKey:kMPUnityRewardedVideoGameId];
    if (gameId == nil) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain gameId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads gameId."}];

        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        return;
    }

    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];

    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }

    if (self.placementId == nil) {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain placementId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Unity Ads placementId."}];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        return;
    }
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:YES Channel:@"Unityads"];
    [[UnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (BOOL)hasAdAvailable
{
    return [[UnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        UnityAdsInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[UnityAdsInstanceMediationSettings class]];

        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];

        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [[UnityRouter sharedRouter] presentVideoAdFromViewController:viewController customerId:customerId placementId:self.placementId settings:settings delegate:self];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:YES Channel:@"Unityads"];
        self.isClick = NO;
        MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    } else {
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:YES Channel:@"Unityads"];
         MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
    }
}

- (void)handleCustomEventInvalidated
{
    [[UnityRouter sharedRouter] clearDelegate:self];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
        MPLogAdEvent([MPLogEvent adExpiredWithTimeInterval:0], [self getAdNetworkId]);
    }}

#pragma mark - UnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    NSLog(@"hlyLog:Unity Rewarded加载成功");
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:YES Channel:@"Unityads"];
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    
    NSString* unityErrorMessage;
    switch (error) {
        case kUnityAdsErrorNotInitialized:
            unityErrorMessage = @"Unity Ads not initialized";
            break;

        case kUnityAdsErrorInitializedFailed:
            unityErrorMessage = @"Unity Ads initialize failed";
            break;

        case kUnityAdsErrorInvalidArgument:
            unityErrorMessage = @"Unity Ads initialize given an invalid argument";
            break;

        case kUnityAdsErrorVideoPlayerError:
            unityErrorMessage = @"Unity Ads video player failed";
            break;

        case kUnityAdsErrorInitSanityCheckFail:
            unityErrorMessage = @"Unity Ads initialized in an invalid environment";
            break;

        case kUnityAdsErrorAdBlockerDetected:
            unityErrorMessage = @"Unity Ads failed due to presence of ad blocker";
            break;

        case kUnityAdsErrorFileIoError:
            unityErrorMessage = @"Unity Ads file IO error";
            break;

        case kUnityAdsErrorDeviceIdError:
            unityErrorMessage = @"Unity Ads encountered a bad device identifier";
            break;

        case kUnityAdsErrorShowError:
            unityErrorMessage = @"Unity Ads failed while attempting to show an ad";
            break;

        case kUnityAdsErrorInternalError:
            unityErrorMessage = @"Unity Ads experienced an internal failure";
            break;

        default:
            unityErrorMessage = @"Unity Ads unknown error";
            break;
    }
    NSError *adapterError = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorUnknown userInfo:@{NSLocalizedDescriptionKey: unityErrorMessage}];
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:adapterError];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:YES Channel:@"Unityads"];
     MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:adapterError], [self getAdNetworkId]);
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Unityads" forKey:@"hwvideotype"];
    [defaults synchronize];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    NSLog(@"hlyLog:Unity Rewarded关闭");
    if (state == kUnityAdsFinishStateCompleted) {
        MPRewardedVideoReward *rewardd = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showSuccess isReward:YES Channel:@"Unityads"];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:reward isReward:YES Channel:@"Unityads"];
        [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:rewardd];
    }else{
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:YES Channel:@"Unityads"];
    }
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:YES Channel:@"Unityads"];
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void) unityAdsDidClick:(NSString *)placementId
{
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    if (!self.isClick) {
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:YES Channel:@"Unityads"];
        self.isClick = YES;
    }
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    NSLog(@"hlyLog:Unity Rewarded加载失败");
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:YES Channel:@"Unityads"];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
