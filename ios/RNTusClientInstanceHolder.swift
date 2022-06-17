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
    
    public func initializeBackgroundClient(_ chunkSize: Int, maxConcurrentUploads: Int) {
        print( "initializing BG Client")
        if tusClient == nil {
            let sessionId = "TUS BG Session"
            
            // TODO: See if Background URL Session support can be added to TUSKit
            // let bgUrlSessionConfig = URLSessionConfiguration.background(withIdentifier: sessionId)
            // bgUrlSessionConfig.isDiscretionary = false
            // let bgUrlSession = URLSession(configuration: bgUrlSessionConfig)
            
            let urlSessionConfig = URLSessionConfiguration.ephemeral
            // Restrict maximum parallel connections to 2
            urlSessionConfig.httpMaximumConnectionsPerHost = 2
            // 60 Second timeout (resets if data transmitted)
            urlSessionConfig.timeoutIntervalForRequest = 60
            // Wait for connection instead of failing immediately
            urlSessionConfig.waitsForConnectivity = true
            // Dont' let system decide when to start the task
            urlSessionConfig.isDiscretionary = false
            // Disable storing all cookies in one shared container so we can pass over AWS ALB cookie manually
            let urlSession = URLSession(configuration: urlSessionConfig)
            
            let tusClient = try! TUSClient(
                server: URL(string: "http://localhost/files")!,
                sessionIdentifier: sessionId,
                storageDirectory: URL(string: "TUS/background")!,
                session: urlSession,
                chunkSize: chunkSize,
                maxConcurrentUploads: maxConcurrentUploads
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
