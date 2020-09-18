//
//  MPGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "GoogleAdMobAdapterConfiguration.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#if __has_include("MoPub.h")
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#endif
#import <CoreLocation/CoreLocation.h>
//#import <HwFrameworkUpTest1.framework/Headers/HwAds.h>
#import <HwAdsFramework/HwAds.h>

@interface MPGoogleAdMobInterstitialCustomEvent () <GADInterstitialDelegate>

@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, copy) NSString *admobAdUnitId;

@end

@implementation MPGoogleAdMobInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.admobAdUnitId = [info objectForKey:@"adUnitID"];
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.admobAdUnitId];
    self.interstitial.delegate = self;
    GADRequest *requestt = [GADRequest request];
    
    if ([self.localExtras objectForKey:@"contentUrl"] != nil) {
        NSString *contentUrl = [self.localExtras objectForKey:@"contentUrl"];
        if ([contentUrl length] != 0) {
            requestt.contentURL = contentUrl;
        }
    }

    CLLocation *location = self.delegate.location;
    if (location) {
        [requestt setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }
    
    // Here, you can specify a list of device IDs that will receive test ads.
    // Running in the simulator will automatically show test ads.
    if ([self.localExtras objectForKey:@"testDevices"]) {
      requestt.testDevices = self.localExtras[@"testDevices"];
    }
    if ([self.localExtras objectForKey:@"tagForChildDirectedTreatment"]) {
      [GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:self.localExtras[@"tagForChildDirectedTreatment"]];
    }
    if ([self.localExtras objectForKey:@"tagForUnderAgeOfConsent"]) {
      [GADMobileAds.sharedInstance.requestConfiguration
       tagForUnderAgeOfConsent:self.localExtras[@"tagForUnderAgeOfConsent"]];
    }

    requestt.requestAgent = @"MoPub";
    
    // Consent collected from the MoPub’s consent dialogue should not be used to set up Google's
    // personalization preference. Publishers should work with Google to be GDPR-compliant.
    
    NSString *npaValue = GoogleAdMobAdapterConfiguration.npaString;
    
    if (npaValue.length > 0) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": npaValue};
        [requestt registerAdNetworkExtras:extras];
    }
    
    // Cache the network initialization parameters
    [GoogleAdMobAdapterConfiguration updateInitializationParameters:info];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:request isReward:NO Channel:@"Admob"];
    [self.interstitial loadRequest:requestt];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Admob" forKey:@"hwintertype"];
    [defaults synchronize];
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:show isReward:NO Channel:@"Admob"];
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)dealloc {
    self.interstitial.delegate = nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
//    NSLog(@"hlyLog:Google InterstitialAd%@",interstitial.adUnitID);
    NSLog(@"hlyLog:Google InterstitialAd加载成功");
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:requestSuccess isReward:NO Channel:@"Admob"];
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"hlyLog:Google InterstitialAd加载失败");
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:requestFailed isReward:NO Channel:@"Admob"];
    NSString *failureReason = [NSString stringWithFormat: @"Google AdMob Interstitial failed to load with error: %@", error.localizedDescription];
    NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:failureReason];
    
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mopubError], [self getAdNetworkId]);
    
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial {
    MPLogAdEvent(MPLogEvent.adShowSuccess, self.admobAdUnitId);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
    [self.delegate trackImpression];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"hlyLog:Google InterstitialAd关闭");
    [[HwAds instance] hwAdsEventByPlacementId:self.admobAdUnitId hwSdkState:AdClose isReward:NO Channel:@"Admob"];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    //将要离开app
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
    [self.delegate trackClick];
}

- (NSString *) getAdNetworkId {
    return self.admobAdUnitId;
}

@end
