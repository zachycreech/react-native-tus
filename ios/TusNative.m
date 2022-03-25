#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TusNative, NSObject)

RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createUpload:(NSString *)fileUrl
                  options:(NSDictionary *)options
                  onCreated:(RCTResponseSenderBlock)onCreatedCallback)

RCT_EXTERN_METHOD(resume:(NSString *)uploadId
                  withCallback:(RCTResponseSenderBlock)callback)

@end
