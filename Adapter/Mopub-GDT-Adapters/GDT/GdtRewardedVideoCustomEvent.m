//
//  GdtRewardedVideoCustomEvent.m
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



#import "GdtRewardedVideoCustomEvent.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwAdsFramework/HwAds.h>
#import "GDTRewardVideoAd.h"

@interface GdtRewardedVideoCustomEvent () <GDTRewardedVideoAdDelegate>

@property (nonatomic, strong) GDTRewardVideoAd *gdtRewardVideoAd;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, assign) BOOL rewaredLoaded;
@end

@implementation GdtRewardedVideoCustomEvent

//BOOL *isRewardLoaded;

- (void)initializeSdkWithParameters:(NSDictionary *)parameters
{
//    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
}
-(void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup{
    NSLog(@"%@",adMarkup);
    [self requestRewardedVideoWithCustomEventInfo:info];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    if(![info objectForKey:@"appId"]){
        NSLog(@"Gdt reward video invalid app id");
        NSError *error =
        [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                            code:MPRewardedVideoAdErrorInvalidAdUnitID
                        userInfo:@{NSLocalizedDescriptionKey : @"appId Unit ID cannot be nil."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error],nil);
        
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    NSLog(@"hlyLog:GTDRewardedVideoCustomEvent初始化");
    NSString * appId = info[@"appId"];
    self.placementId = info[@"placementId"];
    
//    self.gdtRewardVideoAd = [[GDTRewardVideoAd alloc] initWithAppId:appId placementId:self.placementId];
    self.gdtRewardVideoAd = [[GDTRewardVideoAd alloc]initWithPlacementId:self.placementId];
    self.gdtRewardVideoAd.delegate = self;
    if(appId==nil){
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidAdUnitID userInfo:@{NSLocalizedDescriptionKey: @"Custom event class data did not contain appId.", NSLocalizedRecoverySuggestionErrorKey: @"Update your MoPub custom event class data to contain a valid Sigmob Appid."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], nil);
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:YES Channel:@"GDT"];
    [self.gdtRewardVideoAd loadAd];
}

- (BOOL)hasAdAvailable
{
//    BOOL isReady = self.rewaredLoaded;
    return (self.gdtRewardVideoAd != nil && self.rewaredLoaded);
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
    if([self hasAdAvailable]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"GDT" forKey:@"hwvideotype"];
        [defaults synchronize];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:YES Channel:@"GDT"];
        self.isClick = NO;
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
        [self.gdtRewardVideoAd showAdFromRootViewController:viewController];
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    }else{
        NSError *error = [NSError errorWithCode:MPRewardedVideoAdErrorNoAdsAvailable localizedDescription:@"Failed to show gdt rewarded video: gdt now claims that there is no available video ad."];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementId);
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:YES Channel:@"GDT"];
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

#pragma mark - GDT Delegate

- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd:(NSString *)placementId{
    NSLog(@"gdt_rewardVideoAdDidLoad");
    self.rewaredLoaded = true;
   
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

/**
 广告数据加载成功回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd{
    NSLog(@"gdt_rewardVideoAdDidLoad 1111111");
//    NSLog(@"hlyLog:GTDrewardVideo加载成功");
}

/**
 视频数据下载成功回调，已经下载过的视频会直接回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd{
    NSLog(@"gdt_rewardVideoAdDidLoad 222222");
    NSLog(@"hlyLog:GTDrewardVideo加载成功");
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:YES Channel:@"GDT"];
    self.rewaredLoaded = true;
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

/**
 
 视频播放页即将展示回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd{
    NSLog(@"gdt_rewardVideoAdWillVisible");
    //[self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

/**
 视频广告曝光回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd{
    NSLog(@"gdt_rewardVideoAdDidExposed");
    //[self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

/**
 视频播放页关闭回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd{
    self.rewaredLoaded = false;
    NSLog(@"hlyLog:GTDrewardVideo关闭");
     [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:YES Channel:@"GDT"];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

/**
 视频广告信息点击回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd{
    if (!self.isClick) {
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:YES Channel:@"GDT"];
        self.isClick = YES;
    }
     
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

/**
 视频广告各种错误信息回调
 @param rewardedVideoAd GDTRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    NSLog(@"Error %d",error.code);
    NSLog(@"hlyLog:GTDrewardVideo加载失败");
     [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:YES Channel:@"GDT"];
    self.rewaredLoaded = false;
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
}

/**
 视频广告播放达到激励条件回调
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd{
    MPRewardedVideoReward *rewardd = [[MPRewardedVideoReward alloc] initWithCurrencyType:kMPRewardedVideoRewardCurrencyTypeUnspecified amount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)];
     [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:reward isReward:YES Channel:@"GDT"];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:rewardd];
}

/**
 视频广告视频播放完成
 
 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd{
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showSuccess isReward:YES Channel:@"GDT"];
    //[self.delegate rewardedVideo];
}
@end
