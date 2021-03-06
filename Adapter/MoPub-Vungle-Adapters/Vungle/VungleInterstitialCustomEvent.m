//
//  VungleInterstitialCustomEvent.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <VungleSDK/VungleSDK.h>
#import "VungleInterstitialCustomEvent.h"
#import "VungleAdapterConfiguration.h"
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwAdsFramework/HwAds.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif
#import "VungleRouter.h"

// If you need to play ads with vungle options, you may modify playVungleAdFromRootViewController and create an options dictionary and call the playAd:withOptions: method on the vungle SDK.

@interface VungleInterstitialCustomEvent () <VungleRouterDelegate>

@property (nonatomic, assign) BOOL handledAdAvailable;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, copy) NSDictionary *options;

@property (nonatomic, assign) BOOL isClick;

@end

@implementation VungleInterstitialCustomEvent


#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup
{
    self.placementId = [info objectForKey:kVunglePlacementIdKey];

    self.handledAdAvailable = NO;
    
    // Cache the initialization parameters
    [VungleAdapterConfiguration updateInitializationParameters:info];
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:request isReward:NO Channel:@"Vungle"];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getPlacementID]);
    [[VungleRouter sharedRouter] requestInterstitialAdWithCustomEventInfo:info delegate:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([[VungleRouter sharedRouter] isAdAvailableForPlacementId:self.placementId]) {
        
        if (self.options) {
            // In the event that options have been updated
            self.options = nil;
        }
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
        if (self.localExtras != nil && [self.localExtras count] > 0) {
            NSString *ordinal = [self.localExtras objectForKey:kVungleOrdinal];
            if (ordinal != nil) {
                NSNumber *ordinalPlaceholder = [NSNumber numberWithLongLong:[ordinal longLongValue]];
                NSUInteger ordinal = ordinalPlaceholder.unsignedIntegerValue;
                if (ordinal > 0) {
                    options[VunglePlayAdOptionKeyOrdinal] = @(ordinal);
                }
            }
            
            NSString *flexViewAutoDismissSeconds = [self.localExtras objectForKey:kVungleFlexViewAutoDismissSeconds];
            if (flexViewAutoDismissSeconds != nil) {
                NSTimeInterval flexDismissTime = [flexViewAutoDismissSeconds floatValue];
                if (flexDismissTime > 0) {
                    options[VunglePlayAdOptionKeyFlexViewAutoDismissSeconds] = @(flexDismissTime);
                }
            }
            
            NSString *muted = [self.localExtras objectForKey:kVungleStartMuted];
            if ( muted != nil) {
                BOOL startMutedPlaceholder = [muted boolValue];
                options[VunglePlayAdOptionKeyStartMuted] = @(startMutedPlaceholder);
            }
            
            NSString *supportedOrientation = [self.localExtras objectForKey:kVungleSupportedOrientations];
            if ( supportedOrientation != nil) {
                int appOrientation = [supportedOrientation intValue];
                NSNumber *orientations = @(UIInterfaceOrientationMaskAll);
                
                if (appOrientation == 1) {
                    orientations = @(UIInterfaceOrientationMaskLandscape);
                } else if (appOrientation == 2) {
                    orientations = @(UIInterfaceOrientationMaskPortrait);
                }
                
                options[VunglePlayAdOptionKeyOrientations] = orientations;
            }
        }

        self.options = options.count ? options : nil;
        
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.placementId);
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:show isReward:NO Channel:@"Vungle"];
        self.isClick = NO;
        [[VungleRouter sharedRouter] presentInterstitialAdFromViewController:rootViewController options:self.options forPlacementId:self.placementId];
    } else {
        NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:@"Failed to show Vungle video interstitial: Vungle now claims that there is no available video ad."];
        MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"Vungle"];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)invalidate
{
    [[VungleRouter sharedRouter] clearDelegateForPlacementId:self.placementId];
}

#pragma mark - VungleRouterDelegate

- (void)vungleAdDidLoad
{
    NSLog(@"hlyLog:vungle Interstitial加载成功");
    if (!self.handledAdAvailable) {
        self.handledAdAvailable = YES;
        MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestSuccess isReward:NO Channel:@"Vungle"];
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
}

- (void)vungleAdWillAppear
{
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)vungleAdDidAppear {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Vungle" forKey:@"hwintertype"];
    [defaults synchronize];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)vungleAdWillDisappear
{
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)vungleAdDidDisappear
{
    NSLog(@"hlyLog:vungle Interstitial关闭");
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:AdClose isReward:NO Channel:@"Vungle"];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)vungleAdWasTapped
{
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getPlacementID]);
    if (!self.isClick) {
        self.isClick = YES;
        [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:click isReward:NO Channel:@"Vungle"];
    }
    
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)vungleAdDidFailToLoad:(NSError *)error
{
    NSLog(@"hlyLog:vungle Interstitial加载失败");
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:requestFailed isReward:NO Channel:@"Vungle"];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)vungleAdDidFailToPlay:(NSError *)error
{
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], [self getPlacementID]);
    [[HwAds instance] hwAdsEventByPlacementId:self.placementId hwSdkState:showFailed isReward:NO Channel:@"Vungle"];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (NSString *)getPlacementID {
    return self.placementId;
}
@end
