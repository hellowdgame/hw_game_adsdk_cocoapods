//
//  MPMoPubRewardedVideoCustomEvent.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMoPubRewardedVideoCustomEvent.h"
#import "MPMRAIDInterstitialViewController.h"
#import "MPError.h"
#import "MPLogging.h"
#import "MPRewardedVideoReward.h"
#import "MPAdConfiguration.h"
#import "MPRewardedVideoAdapter.h"
#import "MPRewardedVideoReward.h"
#import "MPRewardedVideoError.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwFrameworkUpTest1/HwAds.h>

@interface MPMoPubRewardedVideoCustomEvent()

@property (nonatomic) MPMRAIDInterstitialViewController *interstitial;
@property (nonatomic) BOOL adAvailable;

@end

@interface MPMoPubRewardedVideoCustomEvent (MPInterstitialViewControllerDelegate) <MPInterstitialViewControllerDelegate>
@end

@implementation MPMoPubRewardedVideoCustomEvent

@dynamic delegate;

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    MPAdConfiguration * configuration = self.delegate.configuration;
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(configuration.customEventClass) dspCreativeId:configuration.dspCreativeId dspName:nil], self.adUnitId);

    self.interstitial = [[MPMRAIDInterstitialViewController alloc] initWithAdConfiguration:configuration];
    self.interstitial.delegate = self;
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:request isReward:YES Channel:@"Mopub"];
    [self.interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAlwaysHidden];
    [self.interstitial startLoading];
}

- (BOOL)hasAdAvailable
{
    return self.adAvailable;
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // no-op
}

- (void)handleCustomEventInvalidated
{
    // no-op
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.adUnitId);

    // Error handling block.
    __typeof__(self) __weak weakSelf = self;
    void (^onShowError)(NSError *) = ^(NSError * error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf != nil) {
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(strongSelf.class) error:error], strongSelf.adUnitId);
            [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:showFailed isReward:YES Channel:@"Mopub"];
            [strongSelf.delegate rewardedVideoDidFailToPlayForCustomEvent:strongSelf error:error];
        }
    };

    // No ad available to show.
    if (!self.hasAdAvailable) {
        NSError * error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        onShowError(error);
        return;
    }
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:show isReward:YES Channel:@"Mopub"];
    [self.interstitial presentInterstitialFromViewController:viewController complete:^(NSError * error) {
        if (error != nil) {
            onShowError(error);
        }
        else {
            MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
        }
    }];
}

@end

#pragma mark - MPInterstitialViewControllerDelegate

@implementation MPMoPubRewardedVideoCustomEvent (MPInterstitialViewControllerDelegate)

- (void)interstitialDidLoadAd:(id<MPInterstitialViewController>)interstitial
{
    NSLog(@"hlyLog:MoPub Reward加载成功");
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], self.adUnitId);
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:requestSuccess isReward:YES Channel:@"Mopub"];
    self.adAvailable = YES;
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)interstitialDidAppear:(id<MPInterstitialViewController>)interstitial
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Mopub" forKey:@"hwvideotype"];
    [defaults synchronize];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)interstitialWillAppear:(id<MPInterstitialViewController>)interstitial
{
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
}

- (void)interstitialDidFailToLoadAd:(id<MPInterstitialViewController>)interstitial
{
    NSLog(@"hlyLog:MoPub Reward加载失败");
    NSString * message = [NSString stringWithFormat:@"Failed to load creative:\n%@", self.delegate.configuration.adResponseHTMLString];
    NSError * error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:message];
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:requestFailed isReward:YES Channel:@"Mopub"];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], self.adUnitId);

    self.adAvailable = NO;
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
}

- (void)interstitialWillDisappear:(id<MPInterstitialViewController>)interstitial
{
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
}

- (void)interstitialDidDisappear:(id<MPInterstitialViewController>)interstitial
{
    NSLog(@"hlyLog:MoPub Reward关闭");
    self.adAvailable = NO;
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:AdClose isReward:YES Channel:@"Mopub"];
    // Get rid of the interstitial view controller when done with it so we don't hold on longer than needed
    self.interstitial = nil;
}

- (void)interstitialDidReceiveTapEvent:(id<MPInterstitialViewController>)interstitial
{
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:click isReward:YES Channel:@"Mopub"];
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}

- (void)interstitialWillLeaveApplication:(id<MPInterstitialViewController>)interstitial
{
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}

- (void)interstitialRewardedVideoEnded
{
    MPLogInfo(@"MoPub rewarded video finished playing.");
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:reward isReward:YES Channel:@"Mopub"];
    [[HwAds instance]hwAdsEventByPlacementId:@"mopub" hwSdkState:showSuccess isReward:YES Channel:@"Mopub"];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:self.delegate.configuration.selectedReward];
}

@end
