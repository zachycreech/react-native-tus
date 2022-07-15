import Foundation
import TUSKit
import React
import UIKit


@available(iOS 13.0, *)
@objc(TusNative)
class TusNative: RCTEventEmitter {
  static let uploadFinishedEvent = "UploadFinished"
  static let uploadFailedEvent = "UploadFailed"
  static let fileErrorEvent = "FileError"
  static let progressForEvent = "ProgressFor"
  static let heartbeatEvent = "Heartbeat"

  let tusClient: TUSClient
  private var heartbeatTimer: Timer!

  public override init() {
    tusClient = RNTusClientInstanceHolder.sharedInstance.tusClient!
    super.init()
    tusClient.delegate = self
    // print("Timer initialized: ", timer)
    // https://medium.com/fueled-engineering/memory-management-in-swift-common-issues-90dd7c08b77
    // TLDR: it is necessary to create a weak reference to self inside of timer so that
    // garbage collection knows that TusNative owns the timer and the timer does not own TusNative
    class WeakTarget: NSObject {
      weak var tusNative: TusNative?
      @objc func sendHeartbeat(timer: Timer) {
        self.tusNative?.sendHeartbeat()
      }
    }
    let weakTarget = WeakTarget()
    weakTarget.tusNative = self
    self.heartbeatTimer = Timer.scheduledTimer(timeInterval: 1.0, target: weakTarget, selector: #selector(WeakTarget.sendHeartbeat(timer:)), userInfo: nil, repeats: true)
  }

  override func supportedEvents() -> [String]! {
    return [
      TusNative.uploadFinishedEvent,
      TusNative.uploadFailedEvent,
      TusNative.fileErrorEvent,
      TusNative.progressForEvent,
      TusNative.heartbeatEvent
    ]
  }

  override public static func requiresMainQueueSetup() -> Bool {
    return false;
  }

  @objc func sendHeartbeat() {
    self.sendEvent(withName: TusNative.heartbeatEvent, body: "")
  }

  @objc(getInfo:rejecter:)
  func getInfo(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let info = tusClient.getInfo()
    resolve(info)
  }

  func buildFileUrl(fileUrl: String) -> URL {
    let fileToBeUploaded: URL
    if (fileUrl.starts(with: "file:///") || fileUrl.starts(with: "/var/") || fileUrl.starts(with: "/private/var/")) {
      fileToBeUploaded = URL(string: fileUrl)!
    } else {
      let fileManager = FileManager.default
      let docUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      let appContainer = docUrl.deletingLastPathComponent()
      fileToBeUploaded = appContainer.appendingPathComponent(fileUrl)
    }
    return fileToBeUploaded
  }

  @objc(createUpload:options:resolver:rejecter:)
  func createUpload(fileUrl: String, options: [String : Any], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let fileToBeUploaded: URL = buildFileUrl(fileUrl: fileUrl)
    let endpoint: String = options["endpoint"]! as? String ?? ""
    let headers = options["headers"]! as? [String: String] ?? [:]
    let metadata = options["metadata"]! as? [String: String] ?? [:]
    let startNow = options["startNow"]! as? Bool ?? true

    do {
      let uploadId = try tusClient.uploadFileAt(
        filePath: fileToBeUploaded,
        uploadURL: URL(string: endpoint)!,
        customHeaders: headers,
        context: metadata,
        startNow: startNow
      )
      resolve( "\(uploadId)" )
    } catch {
      print("Unable to create upload: \(error)")
      reject("UPLOAD_ERROR", "Unable to create upload", error)
    }
  }

  @objc(createMultipleUploads:resolver:rejecter:)
  func createMultipleUploads(fileUploads: [[String: Any]], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    var uploads: [[String:Any]] = []
    for fileUpload in fileUploads {
      let fileUrl = fileUpload["fileUrl"] ?? ""
      let options = fileUpload["options"] as? [String: Any] ?? [:]
      let fileToBeUploaded: URL = buildFileUrl(fileUrl: fileUrl as! String)
      let endpoint: String = options["endpoint"]! as? String ?? ""
      let headers = options["headers"]! as? [String: String] ?? [:]
      let metadata = options["metadata"]! as? [String: String] ?? [:]

      do {
        let uploadId = try tusClient.uploadFile(
          filePath: fileToBeUploaded,
          uploadURL: URL(string: endpoint)!,
          customHeaders: headers,
          context: metadata,
          startNow: false
        )
        let uploadResult = [
          "status": "success",
          "uploadId":"\(uploadId)",
          "fileUrl": fileUrl
        ]
        uploads += [uploadResult]
      } catch {
        print("Unable to create upload: \(error)")
        let uploadResult = [
          "status": "failure",
          "err": error,
          "uploadId": "",
          "fileUrl": fileUrl
        ]
        uploads += [uploadResult]
      }
    }
    resolve(uploads)
  }

  @objc(startAll:rejecter:)
  func startAll(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    tusClient.startTasks(for: nil)
    resolve(true)
  }

  @objc(sync:rejecter:)
  func sync(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let updates = tusClient.sync()
    resolve(updates)
  }

  @objc(startSelection:resolver:rejecter:)
  func startSelection(uploadIds: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let taskIds = uploadIds.map { UUID(uuidString: $0)! }
    tusClient.start(taskIds: taskIds)
    resolve(NSNull())
  }

  @objc(pauseAll:rejecter:)
  func pauseAll(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    tusClient.stopAndCancelAll()
    resolve(NSNull())
  }

  @objc(cancelAll:rejecter:)
  func cancelAll(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    do {
      try tusClient.reset()
      resolve(NSNull())
    } catch {
      reject("CANCEL_ALL_ERROR", "Unexpected error", error)
    }
  }

  @objc(cancelById:resolver:rejecter:)
  func cancelById(uploadId: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    do {
      let id = UUID(uuidString: uploadId)!
      try tusClient.cancel(id: id)
      try tusClient.removeCacheFor(id: id)
      resolve(NSNull())
    } catch {
      reject("CANCEL_ERROR", "Unexpected error", error)
    }
  }

  @objc(cancelByIds:resolver:rejecter:)
  func cancelByIds(uploadIds: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    do {
      for uploadId in uploadIds {
        let id = UUID(uuidString: uploadId)!
        try tusClient.cancel(id: id)
        try tusClient.removeCacheFor(id: id)
      }
      resolve(NSNull())
    } catch {
      reject("CANCEL_ERROR", "Unexpected error", error)
    }
  }
  
  /**
    @returns an array of the uploads that were retried and if they were successfully retried or not
   */
  @objc(retryByIds:resolver:rejecter:)
  func retryByIds(uploadIds: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    var results: [[String:Any]] = [];
    var taskIds: [UUID] = [];
    do {
      for uploadId in uploadIds {
        let id = UUID(uuidString: uploadId)!
        let result = try tusClient.retry(id: id)
        results += [[
          "uploadId": "\(uploadId)",
          "didRetry": result.didRetry,
          "reason": result.reason
        ]];
        taskIds.append(id);
      }
      tusClient.start(taskIds: taskIds)
      resolve(results)
    } catch {
      reject("RETRY_ERROR", "Unexpected error", error)
    }
  }

  @objc(getFailedUploadIds:rejecter:)
  func getFailedUploadIds(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    do {
      let failedUploads = try tusClient.failedUploadIDs()
      resolve( failedUploads )
    } catch {
      reject("GET_FAILED_IDS_ERROR", "Unexpected error", error)
    }
  }
}

@available(iOS 13.0, *)
extension TusNative: TUSClientDelegate {
    func didFinishUpload(id: UUID, context: [String: String]?) {
        print("TUSClient finished upload, id is \(id)")
        let body: [String:Any] = [
            "uploadId": "\(id)",
            "context": context!
        ]
        sendEvent(withName: TusNative.uploadFinishedEvent, body: body)
    }
    
    func uploadFailed(id: UUID, error: Error, context: [String: String]?) {
        print("TUSClient upload failed for \(id) error \(error)")
        let body: [String:Any] = [
            "uploadId": "\(id)",
            "error": error,
            "context": context!
        ]
        sendEvent(withName: TusNative.uploadFailedEvent, body: body)
    }

   func fileError(id: String, errorMessage: String) {
        print("TUSClient File error \(errorMessage)")
        let body: [String:Any] = [
           "uploadId": "\(id)",
            "errorMessage": errorMessage
        ]
        sendEvent(withName: TusNative.fileErrorEvent, body: body)
    }

  func progressFor(id: UUID, context: [String: String]?, bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
    let body: [String:Any] = [
      "uploadId": "\(id)",
      "bytesUploaded": bytesUploaded,
      "totalBytes": totalBytes,
      "sessionId": "\(client.sessionIdentifier)",
      "context": context!
    ]
    sendEvent(withName: TusNative.progressForEvent, body: body)
  }

}
