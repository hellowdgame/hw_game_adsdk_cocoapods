//
//  VungleRewardedVideoCustomEvent.h
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

#import <WindSDK/WindSDK.h>

@interface SigmobRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

//@property (nonatomic, weak) id<WindRewardedVideoAdDelegate> sigmobDelegate;

@end
