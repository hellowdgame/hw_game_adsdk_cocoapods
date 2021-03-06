//
//  CSJAdapterConfiguration.m
//  Unity-iPhone
//
//  Created by game team on 2019/12/17.
//

#import "SigmobAdapterConfiguration.h"

#import <WindSDK/WindSDK.h>

#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-sigmob-adapters";

typedef NS_ENUM(NSInteger, SigmobAdapterErrorCode) {
    SigmobAdapterErrorCodeMissingAppId,
};

@implementation SigmobAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[@"appId"];
    
    if (appId != nil) {
        NSDictionary * configuration = @{ @"appId": appId };
        [SigmobAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
//    return @"2.15.1";
    return @"2.18.2";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"sigmob";
}

- (NSString *)networkSdkVersion {
//    return @"2.15.1";
    return @"2.18.2";
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    
    NSString * appId = configuration[@"appId"];
    
    if (appId == nil) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:SigmobAdapterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"Missing the appId parameter when configuring your network in the MoPub website." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    
//    [[WindRewardedVideoAd sharedInstance] setDelegate:self];
    
    if (complete != nil) {
        complete(nil);
    }
}

@end
