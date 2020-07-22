//
//  GdtInterstitialCustomEvent.m
//  Unity-iPhone
//
//  Created by game team on 2019/12/23.
//

#import "GdtInterstitialCustomEvent.h"
#import "GdtAdapterConfiguration.h"

#import "GDTUnifiedInterstitialAd.h"
#import "GdtInterstitialCustomEvent.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>

#if __has_include("MoPub.h")
#import "MoPub.h"
#import "MPLogging.h"
#import "MPRealTimeTimer.h"
#endif

@interface GdtInterstitialCustomEvent () <GDTUnifiedInterstitialAdDelegate>

@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdtInterstitial;
@property (nonatomic, copy) NSString *placementId;

@end

@implementation GdtInterstitialCustomEvent

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
    self.placementId = info[@"placementId"];
    
    GDTUnifiedInterstitialAd *mInterstitial = [[GDTUnifiedInterstitialAd alloc] initWithAppId:appId placementId:self.placementId];
    mInterstitial.delegate = self;
    self.gdtInterstitial = mInterstitial;
    [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:NO Channel:@"GDT"];
//    self.gdtInterstitial.videoMuted = self.videoMutedSwitch.on; // 设置视频是否Mute
//    self.gdtInterstitial.videoAutoPlayOnWWAN = self.videoAutoPlaySwitch.on; // 设置视频是否在非 WiFi 网络自动播放
//    self.gdtInterstitial.maxVideoDuration = (NSInteger)self.maxVideoDurationSlider.value;  //如果需要设置视频最大时长，可以通过这个参数来进行设置
    [self.gdtInterstitial loadAd];
    
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller {
    if (!self.gdtInterstitial.isAdValid) {
        NSError *error = [self createErrorWith:@"Error in loading csj Interstitial"
                                     andReason:@""
                                 andSuggestion:@""];

        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], self.placementId);
        [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"GDT"];
        [self.delegate interstitialCustomEventDidExpire:self];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"GDT" forKey:@"hwintertype"];
        [defaults synchronize];
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
        
        MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.placementId);
        [self.delegate interstitialCustomEventWillAppear:self];
        [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:NO Channel:@"GDT"];
        [self.gdtInterstitial presentAdFromRootViewController:controller];
        MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], self.placementId);
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

#pragma mark GDTInterstitialAdDelegate methods
/**
 *  插屏2.0广告预加载成功回调
 *  当接收服务器返回的广告数据成功且预加载后调用该函数
 */
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"hlyLog:GTDInterstitial加载成功");
    [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:NO Channel:@"GDT"];
    [self.delegate interstitialCustomEvent:self didLoadAd:self.gdtInterstitial];
}

/**
 *  插屏2.0广告预加载失败回调
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error{
    NSLog(@"hlyLog:GTDInterstitial加载失败");
    [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:NO Channel:@"GDT"];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

/**
 *  插屏2.0广告将要展示回调
 *  插屏2.0广告即将展示回调该函数
 */
- (void)unifiedInterstitialWillPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 *  插屏2.0广告视图展示成功回调
 *  插屏2.0广告展示成功回调该函数
 */
- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 *  插屏2.0广告视图展示失败回调
 *  插屏2.0广告展示失败回调该函数
 */
- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

/**
 *  插屏2.0广告展示结束回调
 *  插屏2.0广告展示结束回调该函数
 */
- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:showSuccess isReward:NO Channel:@"GDT"];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

/**
 *  当点击下载应用时会调用系统程序打开其它App或者Appstore时回调
 */
- (void)unifiedInterstitialWillLeaveApplication:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 *  插屏2.0广告曝光回调
 */
- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    //[self.delegate interstitialCustomEventDidAppear:self];
}

/**
 *  插屏2.0广告点击回调
 */
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:NO Channel:@"GDT"];
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

/**
 *  点击插屏2.0广告以后即将弹出全屏广告页
 */
- (void)unifiedInterstitialAdWillPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 *  点击插屏2.0广告以后弹出全屏广告页
 */
- (void)unifiedInterstitialAdDidPresentFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 *  全屏广告页将要关闭
 */
- (void)unifiedInterstitialAdWillDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
//    [self.delegate interstitialCustomEventDidDisappear:self];
}

/**
 *  全屏广告页被关闭
 */
- (void)unifiedInterstitialAdDidDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    NSLog(@"hlyLog:GTDInterstitial关闭");
    [[HwAds instance]hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:NO Channel:@"GDT"];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

/**
 * 插屏2.0视频广告 player 播放状态更新回调
 */
- (void)unifiedInterstitialAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial playerStatusChanged:(GDTMediaPlayerStatus)status{
    
}

/**
 * 插屏2.0视频广告详情页 WillPresent 回调
 */
- (void)unifiedInterstitialAdViewWillPresentVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 * 插屏2.0视频广告详情页 DidPresent 回调
 */
- (void)unifiedInterstitialAdViewDidPresentVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    
}

/**
 * 插屏2.0视频广告详情页 WillDismiss 回调
 */
- (void)unifiedInterstitialAdViewWillDismissVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

/**
 * 插屏2.0视频广告详情页 DidDismiss 回调
 */
- (void)unifiedInterstitialAdViewDidDismissVideoVC:(GDTUnifiedInterstitialAd *)unifiedInterstitial{
    [self.delegate interstitialCustomEventDidDisappear:self];
}
@end
