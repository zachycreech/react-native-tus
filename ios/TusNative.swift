import Foundation
import TUSKit
import React

@objc(TusNative)
class TusNative: RCTEventEmitter {
  static let uploadStartedEvent = "UploadStarted"
  static let uploadFinishedEvent = "UploadFinished"
  static let uploadFailedEvent = "UploadFailed"
  static let fileErrorEvent = "FileError"
  static let totalProgressEvent = "TotalProgress"
  static let progressForEvent = "progressFor"

  var tusClients: [String : TUSClient]

  public override init() {
    tusClients = [:]
  }

  override func supportedEvents() -> [String]! {
    return [
      TusNative.uploadStartedEvent,
      TusNative.uploadFinishedEvent,
      TusNative.uploadFailedEvent,
      TusNative.fileErrorEvent,
      TusNative.totalProgressEvent,
      TusNative.progressForEvent
    ]
  }

  override public static func requiresMainQueueSetup() -> Bool {
    return false;
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
      tusClient.delegate = self
      try! tusClient.reset()
      tusClient.start()
      tusClients[sessionId] = tusClient

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

extension TusNative: TUSClientDelegate {
  func didStartUpload(id: UUID, context: [String: String]?, client: TUSClient) {
    print("TUSClient started upload, id is \(id)")
    print("TUSClient remaining is \(client.remainingUploads)")

    let body: [String:String] = [
      "uploadId": "\(id)",
      "sessionId": "\(client.sessionIdentifier)"
    ]
    sendEvent(withName: TusNative.uploadStartedEvent, body: body)
  }

  func didFinishUpload(id: UUID, url: URL, context: [String: String]?, client: TUSClient) {
    print("TUSClient finished upload, id is \(id) url is \(url)")
    print("TUSClient remaining is \(client.remainingUploads)")
    if client.remainingUploads == 0 {
      print("Finished uploading")
    }
    let body: [String:String] = [
      "uploadId": "\(id)",
      "url": "\(url)",
      "sessionId": "\(client.sessionIdentifier)"
    ]
    sendEvent(withName: TusNative.uploadFinishedEvent, body: body)
  }

  func uploadFailed(id: UUID, error: Error, context: [String: String]?, client: TUSClient) {
    print("TUSClient upload failed for \(id) error \(error)")
    let body: [String:Any] = [
      "uploadId": "\(id)",
      "sessionId": "\(client.sessionIdentifier)",
      "error": error
    ]
    sendEvent(withName: TusNative.uploadFailedEvent, body: body)
  }

  func fileError(error: TUSClientError, client: TUSClient) {
    print("TUSClient File error \(error)")
    let body: [String:Any] = [
      "sessionId": "\(client.sessionIdentifier)",
      "error": error
    ]
    sendEvent(withName: TusNative.fileErrorEvent, body: body)
  }


  func totalProgress(bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
    let body: [String:Any] = [
      "bytesUploaded": bytesUploaded,
      "totalBytes": totalBytes,
      "sessionId": "\(client.sessionIdentifier)"
    ]
    sendEvent(withName: TusNative.totalProgressEvent, body: body)
  }


  func progressFor(id: UUID, context: [String: String]?, bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
    let body: [String:Any] = [
      "uploadId": "\(id)",
      "bytesUploaded": bytesUploaded,
      "totalBytes": totalBytes,
      "sessionId": "\(client.sessionIdentifier)"
    ]
    sendEvent(withName: TusNative.progressForEvent, body: body)
  }

}
