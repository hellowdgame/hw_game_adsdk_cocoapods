//
//  UnityAdsInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import "UnityAdsInterstitialCustomEvent.h"
#import "UnityAdsInstanceMediationSettings.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>
#import "UnityRouter.h"
#if __has_include("MoPub.h")
    #import "MPLogging.h"
#endif
#import "UnityAdsAdapterConfiguration.h"

static NSString *const kMPUnityInterstitialVideoGameId = @"gameId";
static NSString *const kUnityAdsOptionPlacementIdKey = @"placementId";
static NSString *const kUnityAdsOptionZoneIdKey = @"zoneId";

@interface UnityAdsInterstitialCustomEvent () <UnityRouterDelegate>

@property BOOL loadRequested;
@property (nonatomic, copy) NSString *placementId;

@property (nonatomic, assign) BOOL isClick;
@end

@implementation UnityAdsInterstitialCustomEvent

- (void)dealloc
{
    [[UnityRouter sharedRouter] clearDelegate:self];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.loadRequested = YES;
    NSString *gameId = [info objectForKey:kMPUnityInterstitialVideoGameId];
    self.placementId = [info objectForKey:kUnityAdsOptionPlacementIdKey];
    if (self.placementId == nil) {
        self.placementId = [info objectForKey:kUnityAdsOptionZoneIdKey];
    }
    if (gameId == nil || self.placementId == nil) {
          NSError *error = [self createErrorWith:@"Unity Ads adapter failed to requestInterstitial"
                                       andReason:@"Configured with an invalid placement id"
                                   andSuggestion:@""];
          MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];

        return;
    }
    
    // Only need to cache game ID for SDK initialization
    [UnityAdsAdapterConfiguration updateInitializationParameters:info];

    [[UnityRouter sharedRouter] requestVideoAdWithGameId:gameId placementId:self.placementId delegate:self];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:NO Channel:@"Unityads"];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
}

- (NSError *)createErrorWith:(NSString *)description andReason:(NSString *)reaason andSuggestion:(NSString *)suggestion {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(reaason, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestion, nil)
                               };
    
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

- (BOOL)hasAdAvailable
{
    return [[UnityRouter sharedRouter] isAdAvailableForPlacementId:self.placementId];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        [[UnityRouter sharedRouter] presentVideoAdFromViewController:viewController customerId:nil placementId:self.placementId settings:nil delegate:self];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:NO Channel:@"Unityads"];
        self.isClick = NO;
    } else {
        NSError *error = [self createErrorWith:@"Unity Ads failed to load failed to show Unity Interstitial"
                                 andReason:@"There is no available video ad."
                             andSuggestion:@""];
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"Unityads"];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
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
        [self.delegate interstitialCustomEventDidExpire:self];
    }}

#pragma mark - UnityRouterDelegate

- (void)unityAdsReady:(NSString *)placementId
{
    NSLog(@"hlyLog:Unity Interstitial加载成功");
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:NO Channel:@"Unityads"];
    if (self.loadRequested) {
        [self.delegate interstitialCustomEvent:self didLoadAd:placementId];
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
        self.loadRequested = NO;
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message
{
    
    NSError *errorLoad = [self createErrorWith:@"Unity Ads failed to load an ad"
                                 andReason:@""
                             andSuggestion:@""];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:errorLoad];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:NO Channel:@"Unityads"];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorLoad], [self getAdNetworkId]);
}

- (void) unityAdsDidStart:(NSString *)placementId
{
    [self.delegate interstitialCustomEventWillAppear:self];
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Unityads" forKey:@"hwintertype"];
    [defaults synchronize];
    [self.delegate interstitialCustomEventDidAppear:self];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void) unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state
{
    NSLog(@"hlyLog:Unity Interstitial关闭");
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

    [self.delegate interstitialCustomEventDidDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
    if (state == kUnityAdsFinishStateCompleted) {
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showSuccess isReward:NO Channel:@"Unityads"];
    }else{
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"Unityads"];
    }
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:NO Channel:@"Unityads"];
}

- (void) unityAdsDidClick:(NSString *)placementId
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    if (!self.isClick) {
        self.isClick = YES;
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:NO Channel:@"Unityads"];
    }
    
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
}

- (void)unityAdsDidFailWithError:(NSError *)error
{
    NSLog(@"hlyLog:Unity Interstitial加载失败");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:NO Channel:@"Unityads"];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getAdNetworkId]);
}

- (NSString *) getAdNetworkId {
    return (self.placementId != nil) ? self.placementId : @"";
}

@end
