//
//  SceneDelegate.swift
//  TusNativeExample
//
//  Created by Daniel Jones on 4/1/22.
//

import Foundation
import UIKit
import SwiftUI
import React

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    print("iOS 13 or higher: Initializing Scene")
    let rootViewController = UIViewController()
    rootViewController.view = RNBridgeInstanceHolder.sharedInstance.rctRootView!

    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = rootViewController
      self.window = window
      window.makeKeyAndVisible()
    }
  }
}
