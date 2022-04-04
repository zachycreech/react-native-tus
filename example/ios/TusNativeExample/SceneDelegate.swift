//
//  SceneDelegate.swift
//  TusNativeExample
//
//  Created by Daniel Jones on 4/1/22.
//

import Foundation
import UIKit
import SwiftUI
import TUSKit
import React

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let sessionConfig = URLSessionConfiguration.background(withIdentifier: "TUS Session")
    sessionConfig.isDiscretionary = false
    let bgSession = URLSession(configuration: sessionConfig)
    let tusClient = try! TUSClient(
      server: URL(string: "http://localhost/files")!,
      sessionIdentifier: "TUS Session",
      storageDirectory: URL(string: "TUS")!,
      session: bgSession
    )
    try! tusClient.reset()
    tusClient.start()
    print("TUSClient attempting to schedule background tasks")
    tusClient.scheduleBackgroundTasks()
    tusClient.delegate = self
    // UrlSessionInstanceHolder.sharedInstance.tusClient = tusClient
    
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

@available(iOS 13, *)
extension SceneDelegate: TUSClientDelegate {
  func getTusNativeInstance() {
    // return RNBridgeInstanceHolder.sharedInstance.bridge?.module(for: TusNative.self)! as! TusNative
    //return RNBridgeInstanceHolder.sharedInstance.bridge?.module(forName: "TusNative") as! TusNative
  }
  func didStartUpload(id: UUID, context: [String: String]?, client: TUSClient) {
    //let tusNative: TusNative = getTusNativeInstance()
    //tusNative.didStartUpload(id: id, context: context, client: client);
  }

  func didFinishUpload(id: UUID, url: URL, context: [String: String]?, client: TUSClient) {
    //let tusNative: TusNative = getTusNativeInstance()
    //tusNative.didFinishUpload(id: id, url: url, context: context, client: client)
  }

  func uploadFailed(id: UUID, error: Error, context: [String: String]?, client: TUSClient) {
    //let tusNative: TusNative = getTusNativeInstance()
    //tusNative.uploadFailed(id: id, error: error, context: context, client: client)
  }

  func fileError(error: TUSClientError, client: TUSClient) {
    //let tusNative: TusNative = getTusNativeInstance()
    //tusNative.fileError(error: error, client: client)
  }

  func totalProgress(bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
    //let tusNative: TusNative = getTusNativeInstance()
    //tusNative.totalProgress(bytesUploaded: bytesUploaded, totalBytes: totalBytes, client: client)
  }

  func progressFor(id: UUID, context: [String: String]?, bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
    //let tusNative: TusNative = getTusNativeInstance()
    //tusNative.progressFor(id: id, context: context, bytesUploaded: bytesUploaded, totalBytes: totalBytes, client: client)
  }

}
