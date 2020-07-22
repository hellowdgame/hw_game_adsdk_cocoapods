//
//  GdtInterstitialCustomEvent.h
//  Unity-iPhone
//
//  Created by game team on 2019/12/23.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPInterstitialCustomEvent.h"
#endif

@interface GdtInterstitialCustomEvent : MPInterstitialCustomEvent

@end
