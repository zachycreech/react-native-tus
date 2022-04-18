#import "TusNative.h"
#import "react_native_tus-Swift.h"

@implementation RNTusClientBridgeInstanceHolder

+ (void)initializeBackgroundClient {
  [[RNTusClientInstanceHolder sharedInstance] initializeBackgroundClient];
}

+ (void)scheduleBackgroundTasks {
  [[RNTusClientInstanceHolder sharedInstance] scheduleBackgroundTasks];
}

@end

@interface RCT_EXTERN_MODULE(TusNative, RCTEventEmitter)

RCT_EXTERN_METHOD(getRemainingUploads:(RCTPromiseResolveBlock)resolve
                     rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createUpload:(NSString *)fileUrl
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startAll:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startSelection:(NSDictionary *)uploadIds
                     resolver:(RCTPromiseResolveBlock)resolve
                     rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(pauseAll:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(pauseById:(NSString *)uploadId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(cancelAll:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(cancelById:(NSString *)uploadId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(retryById:(NSString *)uploadId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getFailedUploadIds:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end
