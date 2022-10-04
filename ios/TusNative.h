#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNTusClientBridgeInstanceHolder : NSObject

+ (void)initSession:(int)chunkSize maxConcurrentUploadsWifi:(int)maxConcurrentUploadsWifi
 maxConcurrentUploadsNoWifi:(int)maxConcurrentUploadsNoWifi
  completionHandler:(void (^)(void))completionHandler;

+ (void)freeMemory;

@end
