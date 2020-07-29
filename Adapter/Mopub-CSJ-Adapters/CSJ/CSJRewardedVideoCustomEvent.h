//
//  CSJRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

#import <BUAdSDK/BUAdSDK.h>

///*
// * The CSJ SDK does not provide an "application will leave" callback, thus this custom event
// * will not invoke the rewardedVideoWillLeaveApplicationForCustomEvent: delegate method.
// */
//
//@protocol BURewardedVideoAdDelegate <NSObject>
//
//@optional
///**
// This method is called when video ad material loaded successfully.
// */
//- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad materia failed to load.
// @param error : the reason of error
// */
//- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error;
///**
// This method is called when video ad creatives is cached successfully.
// */
//- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad slot will be showing.
// */
//- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad slot has been shown.
// */
//- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad is about to close.
// */
//- (void)rewardedVideoAdWillClose:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad is closed.
// */
//- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad is clicked.
// */
//- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when video ad play completed or an error occurred.
// @param error : the reason of error
// */
//- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error;
///**
// Server verification which is requested asynchronously is succeeded.
// @param verify :return YES when return value is 2000.
// */
//- (void)rewardedVideoAdServerRewardDidSucceed:(BURewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify;
///**
// Server verification which is requested asynchronously is failed.
// Return value is not 2000.
// */
//- (void)rewardedVideoAdServerRewardDidFail:(BURewardedVideoAd *)rewardedVideoAd;
///**
// This method is called when the user clicked skip button.
// */
//- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd;
//@end

@interface CSJRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

//@property (nonatomic, strong) BURewardedVideoModel *rewardedVideoModel;
//@property (nonatomic,weak, nullable) id<BURewardedVideoAdDelegate> buRewardedVideoAdDelegate;
//@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
//@property (nonatomic,weak, nullable) BURewardedVideoAd* rewardedVideoAd;
@property (nonatomic, copy) NSString *placementId;
@property (nonatomic, assign) BOOL isClick;
//-(instancetype) initWithSlotID:(NSString *)slotID rewardedVideoModel:(BURewardedVideoModel *)model;
//-(void)loadAdData;
//-(BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
@end
