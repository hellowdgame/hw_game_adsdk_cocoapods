//
//  BURewardVideoCustomEventDelegate.m
//  mopub_adaptor
//
//  Created by bytedance_yuanhuan on 2018/9/18.
//  Copyright © 2018年 Siwant. All rights reserved.
//

#import "BUDMopub_RewardVideoCustomEventDelegate.h"
#import <BUAdSDK/BUAdSDK.h>
#import "MPRewardedVideoReward.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwAdsFramework/HwAds.h>
@implementation BUDMopub_RewardVideoCustomEventDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"csj rewardedVideoAdDidLoad");
    NSLog(@"hlyLog:CSJ rewardedVideo加载成功");
    [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:requestSuccess isReward:YES Channel:@"CSJ"];
    [self.adapter.delegate rewardedVideoDidLoadAdForCustomEvent:self.adapter];
}
    
- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
//    BUD_Log(@"%s", __func__);
}
    
- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
     NSLog(@"hlyLog:CSJ rewardedVideo加载失败");
    [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:requestFailed isReward:YES Channel:@"CSJ"];
    [self.adapter.delegate rewardedVideoDidFailToPlayForCustomEvent:self.adapter error:error];
}
    
- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self.adapter.delegate rewardedVideoWillAppearForCustomEvent:self.adapter];
    [self.adapter.delegate rewardedVideoDidAppearForCustomEvent:self.adapter];
    [self.adapter.delegate trackImpression];
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
     NSLog(@"hlyLog:CSJ rewardedVideo关闭");
    [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:AdClose isReward:YES Channel:@"CSJ"];
    [self.adapter.delegate rewardedVideoDidDisappearForCustomEvent:self.adapter];
}
    
- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    [self.adapter.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self.adapter];
    if (!self.adapter.isClick) {
        [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:click isReward:YES Channel:@"CSJ"];
    }
    self.adapter.isClick = YES;
    [self.adapter.delegate trackClick];
}
    
- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"csj rewardedVideoAdDidPlayFinish");
    if (error) {
        [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:showFailed isReward:YES Channel:@"CSJ"];
    }else{
        [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:showSuccess isReward:YES Channel:@"CSJ"];
    }
//    BUD_Log(@"%s", __func__);
}
    
- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    NSLog(@"csj rewardedVideoAdServerRewardDidSucceed");
    [[HwAds instance]hwAdsEventByPlacementId:self.adapter.placementId hwSdkState:reward isReward:YES Channel:@"CSJ"];
    MPRewardedVideoReward *reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
    
    [self.adapter.delegate rewardedVideoShouldRewardUserForCustomEvent:self.adapter reward:reward];
}
    
- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd {
//    BUD_Log(@"%s", __func__);
}

@end
