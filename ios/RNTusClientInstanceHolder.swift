//
//  RNTusClientInstanceHolder.swift
//
//  Created by Daniel Jones on 4/10/22.
//

import Foundation
import TUSKit

@available(iOS 13.4, *)
@objcMembers
public final class RNTusClientInstanceHolder : NSObject {

    public static let sharedInstance = RNTusClientInstanceHolder()

    public var tusClient: TUSClient?

    public func initSession(_ chunkSize: Int, maxConcurrentUploadsWifi: Int, maxConcurrentUploadsNoWifi: Int, completionHandler: (() -> Void)?) {
        print("initializing TUSClient")
        if tusClient == nil {
            let sessionId = "io.tus.uploading"
            let tusClient = try! TUSClient(
                server: URL(string: "http://localhost/files")!,
                sessionIdentifier: sessionId,
                storageDirectory: URL(string: "TUS/background")!,
                chunkSize: chunkSize,
                maxConcurrentUploadsWifi: maxConcurrentUploadsWifi,
                maxConcurrentUploadsNoWifi: maxConcurrentUploadsNoWifi,
                backgroundSessionCompletionHandler: completionHandler
            )
#if DEBUG
            try! tusClient.cancelByIds(uuids: nil)
#endif
            RNTusClientInstanceHolder.sharedInstance.tusClient = tusClient
        } else {
            RNTusClientInstanceHolder.sharedInstance.tusClient?.backgroundSessionCompletionHandler = completionHandler
        }
    }

    public func freeMemory() {
        print("resetting TUSClient session")
        if tusClient != nil {
          tusClient?.freeMemory()
        }
    }
}
