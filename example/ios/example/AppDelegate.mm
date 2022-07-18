#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#import <React/RCTAppSetupUtils.h>

#import "TusNative.h"

#if RCT_NEW_ARCH_ENABLED
#import <React/CoreModulesPlugins.h>
#import <React/RCTCxxBridgeDelegate.h>
#import <React/RCTFabricSurfaceHostingProxyRootView.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterBridgeAdapter.h>
#import <ReactCommon/RCTTurboModuleManager.h>

#import <react/config/ReactNativeConfig.h>

@interface AppDelegate () <RCTCxxBridgeDelegate, RCTTurboModuleManagerDelegate> {
  RCTTurboModuleManager *_turboModuleManager;
  RCTSurfacePresenterBridgeAdapter *_bridgeAdapter;
  std::shared_ptr<const facebook::react::ReactNativeConfig> _reactNativeConfig;
  facebook::react::ContextContainer::Shared _contextContainer;
}
@end
#endif

const NSInteger TUS_CHUNK_SIZE_BYTES = 3*1024*1024;
const NSInteger TUS_MAX_CONCURRENT_UPLOADS_WIFI = 15;
const NSInteger TUS_MAX_CONCURRENT_UPLOADS_NO_WIFI = 1;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  RCTAppSetupPrepareApp(application);

  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  const NSInteger TUS_CHUNK_SIZE_BYTES = 5*1024*1024;
  const NSInteger TUS_MAX_CONCURRENT_UPLOADS = 25;
  // [RNTusClientBridgeInstanceHolder initializeBackgroundClient:(int)TUS_CHUNK_SIZE_BYTES maxConcurrentUploads:(int)TUS_MAX_CONCURRENT_UPLOADS];
  [RNTusClientBridgeInstanceHolder initSession:TUS_CHUNK_SIZE_BYTES maxConcurrentUploadsWifi:TUS_MAX_CONCURRENT_UPLOADS maxConcurrentUploadsNoWifi:TUS_MAX_CONCURRENT_UPLOADS completionHandler:(void (^)(void))nil];

#if RCT_NEW_ARCH_ENABLED
  _contextContainer = std::make_shared<facebook::react::ContextContainer const>();
  _reactNativeConfig = std::make_shared<facebook::react::EmptyReactNativeConfig const>();
  _contextContainer->insert("ReactNativeConfig", _reactNativeConfig);
  _bridgeAdapter = [[RCTSurfacePresenterBridgeAdapter alloc] initWithBridge:bridge contextContainer:_contextContainer];
  bridge.surfacePresenter = _bridgeAdapter.surfacePresenter;
#endif

  UIView *rootView = RCTAppSetupDefaultRootView(bridge, @"example", nil);

  if (@available(iOS 13.0, *)) {
    rootView.backgroundColor = [UIColor systemBackgroundColor];
  } else {
    rootView.backgroundColor = [UIColor whiteColor];
  }

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

#if RCT_NEW_ARCH_ENABLED

#pragma mark - RCTCxxBridgeDelegate

- (std::unique_ptr<facebook::react::JSExecutorFactory>)jsExecutorFactoryForBridge:(RCTBridge *)bridge
{
  _turboModuleManager = [[RCTTurboModuleManager alloc] initWithBridge:bridge
                                                             delegate:self
                                                            jsInvoker:bridge.jsCallInvoker];
  return RCTAppSetupDefaultJsExecutorFactory(bridge, _turboModuleManager);
}

#pragma mark RCTTurboModuleManagerDelegate

- (Class)getModuleClassFromName:(const char *)name
{
  return RCTCoreModulesClassProvider(name);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker
{
  return nullptr;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                     initParams:
                                                         (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return nullptr;
}

- (id<RCTTurboModule>)getModuleInstanceFromClass:(Class)moduleClass
{
  return RCTAppSetupDefaultModuleFromClass(moduleClass);
}

#endif

- (void)extracted:(void (^ _Nonnull)())completionHandler {
  [RNTusClientBridgeInstanceHolder initSession:(int)TUS_CHUNK_SIZE_BYTES maxConcurrentUploadsWifi:(int)TUS_MAX_CONCURRENT_UPLOADS_WIFI
                      maxConcurrentUploadsNoWifi:(int)TUS_MAX_CONCURRENT_UPLOADS_NO_WIFI
                             completionHandler:(void (^)(void))completionHandler];
}

// https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622941-application?language=objc
/// If a URL session finishes its work when your app is not running, the system launches your app in the background so that it can process the event. In that situation, use the provided identifier to create a new NSURLSessionConfiguration and NSURLSession object. You must configure the other options of your NSURLSessionConfiguration object in the same way that you did when you started the uploads or downloads. Upon creating and configuring the new NSURLSession object, that object calls the appropriate delegate methods to process the events.
/// If your app already has a session object with the specified identifier and is running or suspended, you do not need to create a new session object using this method. Suspended apps are moved into the background. As soon as the app is running again, the NSURLSession object with the identifier receives the events and processes them normally.
/// At launch time, the app does not call this method if there are uploads or downloads in progress but not yet finished. If you want to display the current progress of those transfers in your app’s user interface, you must recreate the session object yourself. In that situation, cache the identifier value persistently and use it to recreate your session object.
/// https://developer.apple.com/documentation/foundation/urlsessiondelegate/1617185-urlsessiondidfinishevents
/// Save completion handler, recreate URLSession from identifier with same config
/// Events will fire to URLSession delegate and once all have been processed urlSessionDidFinishEvents will fire inside TUSClient which will call this completion handler to let the system know we are done
/// Completion handler is part of UIKit so must be called on main thread
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
  
  // Give completionHandler to TUSClient to call in urlSessionDidFinishEvents so system can take a snapshot of UI to use when showing preview in app switcher
  [self extracted:completionHandler];
  
  NSLog(@"handleEventsForBackgroundURLSession");
}

@end
