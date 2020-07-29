//
//  CSJRewardedVideoCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MPError.h"
    #import "MPRewardedVideoReward.h"
    #import "MPRewardedVideoError.h"
    #import "MoPub.h"
#endif

#import "CSJRewardedVideoCustomEvent.h"
#import "CSJAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#import "BUDMopub_RewardVideoCustomEventDelegate.h"

#import <BUAdSDK/BUAdSDK.h>

@interface CSJRewardedVideoCustomEvent ()<BURewardedVideoAdDelegate>

@property (nonatomic, strong) BURewardedVideoAd *rewardVideoAd;
@property (nonatomic, strong) BUDMopub_RewardVideoCustomEventDelegate *customEventDelegate;


@end

@implementation CSJRewardedVideoCustomEvent

- (void)initializeSdkWithParameters:(NSDictionary *)parameters
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);

}
-(void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup{
    NSLog(@"%@",adMarkup);
    [self requestRewardedVideoWithCustomEventInfo:info];
}
- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    if(![info objectForKey:@"placementId"]){
        NSLog(@"csj reward video invalid app id");
        NSError *error =
        [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                            code:MPRewardedVideoAdErrorInvalidAdUnitID
                        userInfo:@{NSLocalizedDescriptionKey : @"appId Unit ID cannot be nil."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error],nil);
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
    NSString * appId = info[@"appId"];
    [BUAdSDKManager setAppID:appId];
    
    self.placementId = [info objectForKey:@"placementId"];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:YES Channel:@"CSJ"];
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = @"123";
    BURewardedVideoAd *RewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.placementId rewardedVideoModel:model];
    RewardedVideoAd.delegate = self.customEventDelegate;
    self.rewardVideoAd = RewardedVideoAd;
    [RewardedVideoAd loadAdData];
}

//注意 注意 注意
- (BUDMopub_RewardVideoCustomEventDelegate *)customEventDelegate {
    if (!_customEventDelegate) {
        _customEventDelegate = [[BUDMopub_RewardVideoCustomEventDelegate alloc] init];
        _customEventDelegate.adapter = self;
    }
    return _customEventDelegate;
}

- (void) loadCSJAD{
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = @"123";
    
    BURewardedVideoAd *rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.placementId rewardedVideoModel:model];
    rewardedVideoAd.delegate = self;
    [rewardedVideoAd loadAdData];
}

- (BOOL)hasAdAvailable
{
    return self.rewardVideoAd.isAdValid;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
    if([self hasAdAvailable]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"CSJ" forKey:@"hwvideotype"];
        [defaults synchronize];
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
        [self.rewardVideoAd showAdFromRootViewController:viewController ritScene:0 ritSceneDescribe:nil];
        self.isClick = NO;
        [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:YES Channel:@"CSJ"];
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    }else{
        NSError *error = [NSError errorWithCode:MPRewardedVideoAdErrorNoAdsAvailable localizedDescription:@"Failed to show csj rewarded video: csj now claims that there is no available video ad."];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementId);
        [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:YES Channel:@"CSJ"];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)handleCustomEventInvalidated
{
    NSLog(@"handleCustomEventInvalidated");
}

- (void)handleAdPlayedForCustomEventNetwork
{
    //empty implementation
}

- (void)viewDidLoad {

   
}

#pragma mark - CSJ Delegate
/**
 This method is called when video ad material loaded successfully.
 */
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd{
     NSLog(@"csj rewardedVideoAdDidLoad 广告请求成功");
    
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.placementId);
}
/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
     NSLog(@"csj 广告请求失败 %@",error);
    
     MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementId);
}
/**
 This method is called when video ad creatives is cached successfully.
 */
- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd{
    NSLog(@"csj rewardedVideoAdVideoDidLoad 11111");
}
/**
 This method is called when video ad slot will be showing.
 */
- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd{
    NSLog(@"csj rewardedVideoAdWillVisible");
}

/**
 This method is called when video ad is clicked.
 */
- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd{
  NSLog(@"csj rewardedVideoAdDidClick");
     
}
/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    NSLog(@"csj rewardedVideoAdDidPlayFinish");
}
/**
 Server verification which is requested asynchronously is succeeded.
 @param verify :return YES when return value is 2000.
 */
- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify{
    NSLog(@"csj rewardedVideoAdServerRewardDidSucceed");
}
/**
 Server verification which is requested asynchronously is failed.
 Return value is not 2000.
 */
- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd{
    NSLog(@"csj rewardedVideoAdServerRewardDidFail");
}
/**
 This method is called when the user clicked skip button.
 */
- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd{
    NSLog(@"csj rewardedVideoAdDidClickSkip");
}

@end
