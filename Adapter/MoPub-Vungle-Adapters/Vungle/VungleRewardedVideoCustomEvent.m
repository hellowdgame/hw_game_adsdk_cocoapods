//
//  VungleRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "VungleRewardedVideoCustomEvent.h"
#import "VungleAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwAdsFramework/HwAds.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPError.h"
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoError.h"
    #import "MoPub.h"
#endif
#import <VungleSDK/VungleSDK.h>
#import "VungleRouter.h"
#import "VungleInstanceMediationSettings.h"

@interface VungleRewardedVideoCustomEvent ()  <VungleRouterDelegate>

@property (nonatomic, copy) NSString *placementId;

@property (nonatomic, assign) BOOL isClick;

@end

@implementation VungleRewardedVideoCustomEvent


- (void)initializeSdkWithParameters:(NSDictionary *)parameters
{
    [[VungleRouter sharedRouter] initializeSdkWithInfo:parameters];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.placementId = [info objectForKey:kVunglePlacementIdKey];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:YES Channel:@"Vungle"];
    // Cache the initialization parameters
    [VungleAdapterConfiguration updateInitializationParameters:info];

    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.placementId);
    [[VungleRouter sharedRouter] requestRewardedVideoAdWithCustomEventInfo:info delegate:self];
}

- (BOOL)hasAdAvailable
{
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementId];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
    if ([[VungleRouter sharedRouter] isAdAvailableForPlacementId:self.placementId]) {
        VungleInstanceMediationSettings *settings = [self.delegate instanceMediationSettingsForClass:[VungleInstanceMediationSettings class]];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:YES Channel:@"Vungle"];
        self.isClick = NO;
        NSString *customerId = [self.delegate customerIdForRewardedVideoCustomEvent:self];
        [[VungleRouter sharedRouter] presentRewardedVideoAdFromViewController:viewController customerId:customerId settings:settings forPlacementId:self.placementId];
    } else {
        NSError *error = [NSError errorWithCode:MPRewardedVideoAdErrorNoAdsAvailable localizedDescription:@"Failed to show Vungle rewarded video: Vungle now claims that there is no available video ad."];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:YES Channel:@"Vungle"];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    [[VungleRouter sharedRouter] clearDelegateForPlacementId:self.placementId];
}

- (void)handleAdPlayedForCustomEventNetwork
{
    //empty implementation
}

#pragma mark - MPVungleDelegate

- (void)vungleAdDidLoad
{
    NSLog(@"hlyLog:vungle Reward加载成功");
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:YES Channel:@"Vungle"];
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)vungleAdWillAppear
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (void)vungleAdDidAppear {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Vungle" forKey:@"hwvideotype"];
    [defaults synchronize];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)vungleAdWillDisappear
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    //
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showSuccess isReward:YES Channel:@"Vungle"];
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

- (void)vungleAdDidDisappear
{
    NSLog(@"hlyLog:vungle Reward关闭");
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:YES Channel:@"Vungle"];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)vungleAdWasTapped
{
    if (!self.isClick) {
        self.isClick = YES;
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:YES Channel:@"Vungle"];
    }
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)vungleAdShouldRewardUser
{
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:reward isReward:YES Channel:@"Vungle"];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)]];
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    NSLog(@"hlyLog:vungle Reward加载失败");
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:YES Channel:@"Vungle"];
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:YES Channel:@"Vungle"];
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (NSString *)getPlacementID {
    return self.placementId;
}

@end
