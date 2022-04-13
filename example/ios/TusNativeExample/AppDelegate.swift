//
//  AppDelegate.swift
//  TusNativeExample
//
//  Created by Daniel Jones on 3/31/22.
//
//  Note: I left comments regarding the Obj-C implementation of React Native to help facilitate future React Native upgrades
import Foundation
import UIKit
import React
import react_native_tus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RCTBridgeDelegate {
  func sourceURL(for bridge: RCTBridge!) -> URL! {
#if DEBUG
    // Obj-C
    // return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackResource: nil)
#else
    // Obj-C
    // return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
#endif
  }
  
  var window: UIWindow?
    var bridge: RCTBridge?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    // Obj-C
    // RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
    bridge = RCTBridge.init(delegate: self, launchOptions: launchOptions)
    
    // Instantiate root view here instead of scene to start the bundler on app launch
    // Obj-C
    // RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
    //                                                  moduleName:@"TusNativeExample"
    //                                           initialProperties:nil];
    let rootView = RCTRootView.init(bridge: bridge!, moduleName: "TusNativeExample", initialProperties: nil)

    RNBridgeInstanceHolder.sharedInstance.bridge = bridge
    RNBridgeInstanceHolder.sharedInstance.rctRootView = rootView
    RNTusClientInstanceHolder.sharedInstance.initializeBackgroundClient()
    
    // Scenes require this block to not run but this is required for under iOS 13
    guard #available(iOS 13, *) else {
      // Obj-C
      // self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
      // UIViewController *rootViewController = [UIViewController new];
      // rootViewController.view = rootView;
      // self.window.rootViewController = rootViewController;
      // [self.window makeKeyAndVisible];
      // return YES;
      print("iOS 12 or lower: Initializing UI in AppDelegate")
      self.window = UIWindow(frame: UIScreen.main.bounds)
      let rootViewController = UIViewController()
      rootViewController.view = rootView
      self.window?.rootViewController = rootViewController
      self.window?.makeKeyAndVisible()
      return true
    }

    return true
  }
  
  @available(iOS 13, *)
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
    // Uses the configuration in Info.plist to
    let scene =  UISceneConfiguration(name: "Phone", sessionRole: connectingSceneSession.role)
              
    return scene
  }

  @available(iOS 13, *)
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}
