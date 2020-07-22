//
//  BURewardVideoCustomEventDelegate.h
//  mopub_adaptor
//
//  Created by bytedance_yuanhuan on 2018/9/18.
//  Copyright © 2018年 Siwant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
#import "CSJRewardedVideoCustomEvent.h"

@interface BUDMopub_RewardVideoCustomEventDelegate : NSObject<BURewardedVideoAdDelegate>
@property (nonatomic, weak) CSJRewardedVideoCustomEvent *adapter;
@end
