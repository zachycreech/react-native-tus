//
//  RNTusClientInstanceHolder.swift
//
//  Created by Daniel Jones on 4/10/22.
//

import Foundation
import TUSKit

@objcMembers
public final class RNTusClientInstanceHolder : NSObject {

  public static let sharedInstance = RNTusClientInstanceHolder()

  public var tusClient: TUSClient?

    public func initializeBackgroundClient(_ chunkSize: Int) {
    print( "initializing BG Client")
    if tusClient == nil {
      let sessionId = "TUS BG Session"

      // TODO: See if Background URL Session support can be added to TUSKit
      // let bgUrlSessionConfig = URLSessionConfiguration.background(withIdentifier: sessionId)
      // bgUrlSessionConfig.isDiscretionary = false
      // let bgUrlSession = URLSession(configuration: bgUrlSessionConfig)

      let defaultUrlSessionConfig = URLSessionConfiguration.default
      defaultUrlSessionConfig.httpMaximumConnectionsPerHost = 2
      let defaultUrlSession = URLSession(configuration: defaultUrlSessionConfig)

      let tusClient = try! TUSClient(
        server: URL(string: "http://localhost/files")!,
        sessionIdentifier: sessionId,
        storageDirectory: URL(string: "TUS/background")!,
        session: defaultUrlSession,
        chunkSize: chunkSize
      )
  #if DEBUG
      try! tusClient.reset()
  #endif

      if #available(iOS 13, *) {
        print("TUSClient attempting to schedule background tasks")
        tusClient.scheduleBackgroundTasks()
      }

      RNTusClientInstanceHolder.sharedInstance.tusClient = tusClient
    }
  }

  public func scheduleBackgroundTasks() {
    if #available(iOS 13, *) {
      print("TUSClient attempting to schedule background tasks")
      RNTusClientInstanceHolder.sharedInstance.tusClient!.scheduleBackgroundTasks()
    }
  }
}
