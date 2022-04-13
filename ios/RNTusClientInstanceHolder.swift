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
  
  public func initializeBackgroundClient() {
    print( "initializing BG Client")
    if tusClient == nil {
      let tusClient = try! TUSClient(
        server: URL(string: "http://localhost/files")!,
        sessionIdentifier: "TUS BG Session",
        storageDirectory: URL(string: "TUS/background")!
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
}
