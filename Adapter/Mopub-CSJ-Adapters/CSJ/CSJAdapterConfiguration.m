//
//  CSJAdapterConfiguration.m
//  Unity-iPhone
//
//  Created by game team on 2019/12/17.
//

#import "CSJAdapterConfiguration.h"

#import <BUAdSDK/BUAdSDK.h>

#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

// Errors
static NSString * const kAdapterErrorDomain = @"com.mopub.mopub-ios-sdk.mopub-csj-adapters";

typedef NS_ENUM(NSInteger, CSJAdapterErrorCode) {
    CSJAdapterErrorCodeMissingAppId,
};

@implementation CSJAdapterConfiguration

#pragma mark - Caching
//3.从服务端解析配置的值，注意 key值 需要对应
+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSLog(@"yjg csj 解析服务端参数");
    
    NSString * appId = parameters[@"appId"];
    
    if (appId != nil) {
        NSDictionary * configuration = @{ @"appId": appId };
        [CSJAdapterConfiguration setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration
//版本号
- (NSString *)adapterVersion {
//    return @"2.5.1.5";
    return @"3.1.0.0";
}
//是否支持bidding
- (NSString *)biddingToken {
    return nil;
}
//返回渠道的名字，必须小写，不能空格
- (NSString *)moPubNetworkName {
    // ⚠️ Do not change this value! ⚠️
    return @"CSJ";
}
//返回sdk的版本
- (NSString *)networkSdkVersion {
    return @"3.1.0.0";
}
//4.初始化逻辑

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete{
    NSString * appId = configuration[@"appId"];
    if (appId == nil) {
        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:CSJAdapterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"Missing the appId parameter when configuring your network in the MoPub website." }];
        MPLogEvent([MPLogEvent error:error message:nil]);
        
        if (complete != nil) {
            complete(error);
        }
        return;
    }
    //    [BUAdSDKManager setAppID:appId];
    
    if (complete != nil) {
        complete(nil);
    }
}

//- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
//                                  complete:(void(^)(NSError *))complete {
//
//    NSString * appId = configuration[@"appId"];
//    if (appId == nil) {
//        NSError * error = [NSError errorWithDomain:kAdapterErrorDomain code:CSJAdapterErrorCodeMissingAppId userInfo:@{ NSLocalizedDescriptionKey: @"Missing the appId parameter when configuring your network in the MoPub website." }];
//        MPLogEvent([MPLogEvent error:error message:nil]);
//
//        if (complete != nil) {
//            complete(error);
//        }
//        return;
//    }
////    [BUAdSDKManager setAppID:appId];
//
//    if (complete != nil) {
//        complete(nil);
//    }
//}

@end
