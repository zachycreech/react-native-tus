#import "TusNative.h"
#import "react_native_tus-Swift.h"

typedef struct FileUploads {
  NSString *fileUrl;
} FileUpload;

@implementation RNTusClientBridgeInstanceHolder

+ (void)initSession:(int)chunkSize maxConcurrentUploadsWifi:(int)maxConcurrentUploadsWifi
maxConcurrentUploadsNoWifi:(int)maxConcurrentUploadsNoWifi
    completionHandler:(void (^)(void))completionHandler {
  [[RNTusClientInstanceHolder sharedInstance] initSession:(int)chunkSize maxConcurrentUploadsWifi:(int)maxConcurrentUploadsWifi
   maxConcurrentUploadsNoWifi:(int)maxConcurrentUploadsNoWifi
                                        completionHandler:(void (^)(void))completionHandler];
}

+ (void)freeMemory {
  [[RNTusClientInstanceHolder sharedInstance] freeMemory];
}

@end

@interface RCT_EXTERN_MODULE(TusNative, RCTEventEmitter)

RCT_EXTERN_METHOD(getInfo:(RCTPromiseResolveBlock)resolve
                     rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(uploadFiles:(NSArray *)fileUploads
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(start:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
                  
RCT_EXTERN_METHOD(sync:(RCTPromiseResolveBlock)resolve
            rejecter:(RCTPromiseRejectBlock)reject)
             
RCT_EXTERN_METHOD(freeMemory:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(pause:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(cancelByIds:(NSArray *)uploadIds
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(retryByIds:(NSArray *)uploadIds
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
