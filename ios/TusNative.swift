import Foundation
import TUSKit
import React
import UIKit

@objc(TusNative)
class TusNative: RCTEventEmitter {
  static let uploadStartedEvent = "UploadStarted"
  static let uploadFinishedEvent = "UploadFinished"
  static let uploadFailedEvent = "UploadFailed"
  static let fileErrorEvent = "FileError"
  static let totalProgressEvent = "TotalProgress"
  static let progressForEvent = "ProgressFor"

  let tusClient: TUSClient

  public override init() {
    tusClient = RNTusClientInstanceHolder.sharedInstance.tusClient!
    super.init()
    tusClient.delegate = self
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

  @objc(getRemainingUploads:rejecter:)
  func getRemainingUploads(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let remainingUploads = tusClient.getRemainingUploads()
    resolve(remainingUploads)
  }

  @objc(createUpload:options:resolver:rejecter:)
  func createUpload(fileUrl: String, options: [String : Any], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let fileToBeUploaded: URL
    if (fileUrl.starts(with: "file:///") || fileUrl.starts(with: "/var/") || fileUrl.starts(with: "/private/var/")) {
      fileToBeUploaded = URL(string: fileUrl)!
    } else {
      let fileManager = FileManager.default
      let docUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      let appContainer = docUrl.deletingLastPathComponent()
      fileToBeUploaded = appContainer.appendingPathComponent(fileUrl)
    }

    let endpoint: String = options["endpoint"]! as? String ?? ""
    let headers = options["headers"]! as? [String: String] ?? [:]
    let metadata = options["metadata"]! as? [String: String] ?? [:]

    do {
      let uploadId = try tusClient.uploadFileAt(
        filePath: fileToBeUploaded,
        uploadURL: URL(string: endpoint)!,
        customHeaders: headers,
        context: metadata
      )
      resolve( "\(uploadId)" )
    } catch {
      print("Unable to create upload: \(error)")
      reject("UPLOAD_ERROR", "Unable to create upload", error)
    }
  }

  @objc(startAll:rejecter:)
  func startAll(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let remainingUploads = tusClient.start()
    resolve(remainingUploads)
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

  @objc(pauseById:resolver:rejecter:)
  func pauseById(uploadId: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    do {
      let id = UUID(uuidString: uploadId)!
      try tusClient.cancel(id: id)
      resolve(NSNull())
    } catch {
      reject("PAUSE_ERROR", "Unexpected error", error)
    }
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
      try tusClient.removeCacheFor(id: id)
      resolve(NSNull())
    } catch {
      reject("CANCEL_ERROR", "Unexpected error", error)
    }
  }

  @objc(retryById:resolver:rejecter:)
  func retryById(uploadId: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    do {
      let id = UUID(uuidString: uploadId)!
      try tusClient.retry(id: id)
      resolve(NSNull())
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
