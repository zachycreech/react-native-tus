import Foundation
import TUSKit

@objc(TusNative)
class TusNative: NSObject {
  var tusClients: [String : TUSClient]

  public override init() {
    tusClients = [:]
  }
  /**
   * initializeClient
   * This has been broken out of the init function to allow clients to be initialized from inside of JS.
   */
  @objc(initializeClient:options:resolver:rejecter:)
  func initializeClient(serverUrl: String, options: [String : Any], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let sessionIdentifier: String = options["sessionIdentifier"]! as? String ?? "TUS Session"
    let storageDirectory: String = options["storageDirectory"]! as? String ?? "TUS"
    if tusClients[sessionIdentifier] != nil {
      // Client already initialized
      resolve(NSNull())
    } else {
      let tusClient = try! TUSClient(
        server: URL(string: serverUrl)!,
        sessionIdentifier: sessionIdentifier,
        storageDirectory: URL(string: storageDirectory)!
      )
      tusClient.start()
      tusClients[sessionIdentifier] = tusClient

      resolve(NSNull())
    }
  }

  @objc(createUpload:options:resolver:rejecter:)
  func createUpload(fileUrl: String, options: [String : Any], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let fileToBeUploaded:URL = URL(string: fileUrl)!
    let endpoint: String = options["endpoint"]! as? String ?? ""
    let headers = options["headers"]! as? [String: String] ?? [:]
    let metadata = options["metadata"]! as? [String: String] ?? [:]

    if let tusClient = tusClients[endpoint] {
      let uploadId = try! tusClient.uploadFileAt(
        filePath: fileToBeUploaded,
        uploadURL: URL(string: endpoint)!,
        customHeaders: headers,
        context: metadata
      )
      resolve( "\(uploadId)" )
    } else {
      let error = NSError(domain: "TUS_IOS_BRIDGE", code: 200, userInfo: nil)
      reject( "CLIENT_NOT_INITIALIZED", "TUS Client is not initialized", error )
    }
  }

  @objc(resume:sessionId:resolver:rejecter:)
  func resume(uploadId: String, sessionId: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    if let tusClient = tusClients[endpoint] {
      let uploadId = try! tusClient.uploadFileAt(filePath: fileToBeUploaded)
      resolve( "Starting upload \(uploadId) with endpoint: \(endpoint) headers: \(headers) metadata: \(metadata)" )
    } else {
      let error = NSError(domain: "TUS_IOS_BRIDGE", code: 200, userInfo: nil)
      reject( "CLIENT_NOT_INITIALIZED", "TUS Client is not initialized", error )
    }
    resolve(NSNull())
  }

}
