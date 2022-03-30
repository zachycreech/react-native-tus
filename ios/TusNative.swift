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
    let sessionId: String = options["sessionId"]! as? String ?? "TUS Session"
    let storageDir: String = options["storageDir"]! as? String ?? "TUS"
    if tusClients[sessionId] != nil {
      // Client already initialized
      resolve(NSNull())
    } else {
      let tusClient = try! TUSClient(
        server: URL(string: serverUrl)!,
        sessionIdentifier: sessionId,
        storageDirectory: URL(string: storageDir)!
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
    let sessionId: String = options["sessionId"]! as? String ?? "TUS Session"

    if let tusClient = tusClients[sessionId] {
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

}
