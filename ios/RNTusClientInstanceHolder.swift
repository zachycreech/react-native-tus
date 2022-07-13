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

    public func initSession(_ chunkSize: Int, maxConcurrentUploads: Int) {
        print("initializing TUSClient")
        if tusClient == nil {
            let sessionId = "io.tus.uploading"
            let tusClient = try! TUSClient(
                server: URL(string: "http://localhost/files")!,
                sessionIdentifier: sessionId,
                storageDirectory: URL(string: "TUS/background")!,
                chunkSize: chunkSize,
                maxConcurrentUploads: maxConcurrentUploads
            )
#if DEBUG
            try! tusClient.reset()
#endif
            RNTusClientInstanceHolder.sharedInstance.tusClient = tusClient
        }
    }
}
