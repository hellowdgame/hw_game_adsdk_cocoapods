//
//  SigmobInterstitialCustomEvent.m
//  Unity-iPhone
//
//  Created by game team on 2019/12/23.
//

#import "SigmobInterstitialCustomEvent.h"
#import "SigmobAdapterConfiguration.h"
#import <WindSDK/WindSDK.h>
#import <WindSDK/WindFullscreenVideoAd.h>
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>

#if __has_include("MoPub.h")
#import "MoPub.h"
#import "MPLogging.h"
#import "MPRealTimeTimer.h"
#endif

@interface SigmobInterstitialCustomEvent () <WindFullscreenVideoAdDelegate>

@property (nonatomic, copy) NSString *placementId;

@end

@implementation SigmobInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    [self requestInterstitialWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    if(![info objectForKey:@"placementId"]){
        NSLog(@"sigmob interstitial fullscreen video invalid app id");
        NSError *error =
        [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain
                            code:MPRewardedVideoAdErrorInvalidAdUnitID
                        userInfo:@{NSLocalizedDescriptionKey : @"appId Unit ID cannot be nil."}];
        MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error],nil);
        
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    NSString * appId = info[@"appId"];
    NSString * apiKey = info[@"apiKey"];

    WindAdOptions *options = [WindAdOptions options];
    options.appId = appId;
    options.apiKey = apiKey;
    [WindAds startWithOptions:options];
    
    self.placementId = info[@"placementId"];
    
    WindAdRequest *requestt = [WindAdRequest request];
    [WindFullscreenVideoAd sharedInstance].delegate = self;
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:NO Channel:@"Sigmob"];
    [[WindFullscreenVideoAd sharedInstance] loadRequest:requestt withPlacementId:self.placementId];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller {
    BOOL isInterReady = [[WindFullscreenVideoAd sharedInstance] isReady:self.placementId];
    if (!isInterReady) {
        NSLog(@"sigmob inter not ready");
        NSError *error = [self createErrorWith:@"Error in loading sigmob Interstitial"
                                     andReason:@""
                                 andSuggestion:@""];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementId);
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"Sigmob"];
        [self.delegate interstitialCustomEventDidExpire:self];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"Sigmob" forKey:@"hwintertype"];
        [defaults synchronize];
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);

        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.placementId);
//        [self.delegate interstitialCustomEventWillAppear:self];
        NSError *error = nil;
        [[WindFullscreenVideoAd sharedInstance] playAd:controller withPlacementId:self.placementId options:nil error:&error];
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.placementId);
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:NO Channel:@"Sigmob"];
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (void)dealloc
{
    
}

#pragma mark SigmobInterstitialAdDelegate methods
/**
 激励视频广告物料加载成功（此时isReady=YES）
 广告是否ready请以当前回调为准
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdLoadSuccess:(NSString *)placementId{
    NSLog(@"hlyLog:SigmobInterstitialAd加载成功");
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:NO Channel:@"Sigmob"];
    [self.delegate interstitialCustomEvent:self didLoadAd:[WindFullscreenVideoAd sharedInstance]];
}

/**
 激励视频广告加载时发生错误
 @param error 发生错误时会有相应的code和message
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdError:(NSError *)error placementId:(NSString *)placementId{
    NSLog(@"hlyLog:SigmobInterstitialAd加载失败");
    NSLog(@"sigmob error %@",error);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:NO Channel:@"Sigmob"];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

/**
 激励视频广告关闭
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdClosed:(NSString *)placementId{
    NSLog(@"hlyLog:SigmobInterstitialAd关闭");
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:NO Channel:@"Sigmob"];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

/**
 激励视频广告开始播放
 
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdPlayStart:(NSString *)placementId{
//    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate interstitialCustomEventWillAppear:self];
}

/**
 激励视频广告发生点击
 
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdClicked:(NSString *)placementId{
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:NO Channel:@"Sigmob"];
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

/**
 激励视频广告调用播放时发生错误
 @param error 发生错误时会有相应的code和message
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdPlayError:(NSError *)error placementId:(NSString *)placementId{
    //播放失败，这里传关闭的回调
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"Sigmob"];
    [self.delegate interstitialCustomEventDidDisappear:nil];
}

/**
 激励视频广告视频播关闭
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdPlayEnd:(NSString *)placementId{
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showSuccess isReward:NO Channel:@"Sigmob"];
//    [self.delegate interstitialCustomEventDidDisappear:self];
}

/**
 激励视频广告AdServer返回广告(表示渠道有广告填充)
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdServerDidSuccess:(NSString *)placementId{
    
}

/**
 激励视频广告AdServer无广告返回(表示渠道无广告填充)
 @param placementId 广告位Id
 */
- (void)onFullscreenVideoAdServerDidFail:(NSString *)placementId{
    
}
@end
