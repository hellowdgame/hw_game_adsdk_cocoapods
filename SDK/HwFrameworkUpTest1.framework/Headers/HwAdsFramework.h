//
//  HwAdsFramework.h
//  HwAdsFramework
//
//  Created by game team on 2019/12/4.
//  Copyright © 2019 yjg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HwAds.h"



//! Project version number for HwAdsFramework.
FOUNDATION_EXPORT double HwAdsFrameworkVersionNumber;

//! Project version string for HwAdsFramework.
FOUNDATION_EXPORT const unsigned char HwAdsFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HwAdsFramework/PublicHeader.h>


@interface HwAdsFramework : NSObject

- (void)initHwSDK:(NSString *)serverURL;
- (void)loadInter;
- (void)showInter;
- (BOOL)isInterLoad;
- (void)loadReward;
- (void)showReward:(NSString *)tag;
- (BOOL)isReward;
- (void)hwFbEvent:(NSString *)category
           action:(NSString *)action
            label:(NSString *)label;
@end
