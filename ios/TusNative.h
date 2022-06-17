#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNTusClientBridgeInstanceHolder : NSObject
+ (void)initializeBackgroundClient:(int)chunkSize maxConcurrentUploads:(int)maxConcurrentUploads;
+ (void)scheduleBackgroundTasks;
@end
