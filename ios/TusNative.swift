import Foundation
import TUSKit
import React
import UIKit


@available(iOS 13.4, *)
@objc(TusNative)
class TusNative: RCTEventEmitter {
    static let uploadFinishedEvent = "UploadFinished"
    static let uploadFailedEvent = "UploadFailed"
    static let fileErrorEvent = "FileError"
    static let totalProgressEvent = "TotalProgress"
    static let progressForEvent = "ProgressFor"
    static let heartbeatEvent = "Heartbeat"
    static let cancelFinishedEvent = "CancelFinished"

    let tusClient: TUSClient
    private var heartbeatTimer: Timer!
    private var preventStallTimer: Timer!

    public override init() {
        tusClient = RNTusClientInstanceHolder.sharedInstance.tusClient!
        super.init()
        tusClient.delegate = self
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

        // Runs every 60 seconds to make sure tasks are running, will retry failed items queue if they are the only items left
        class StallTimerWeakTarget: NSObject {
            weak var tusNative: TusNative?
            @objc func sendWakeUp(timer: Timer) {
                print("Wake up!")
                // Change to .resume() to force uploads to start even if TUSClient is paused
                self.tusNative?.tusClient.startTasks(for: nil, processFailedItemsIfEmpty: true)
            }
        }
        let stallTimerWeakTarget = StallTimerWeakTarget()
        stallTimerWeakTarget.tusNative = self
        self.preventStallTimer = Timer.scheduledTimer(timeInterval: 60.0, target: stallTimerWeakTarget, selector: #selector(StallTimerWeakTarget.sendWakeUp(timer:)), userInfo: nil, repeats: true)
    }

    override func supportedEvents() -> [String]! {
        return [
            TusNative.uploadFinishedEvent,
            TusNative.uploadFailedEvent,
            TusNative.fileErrorEvent,
            TusNative.totalProgressEvent,
            TusNative.progressForEvent,
            TusNative.heartbeatEvent,
            TusNative.cancelFinishedEvent
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

    @objc(generateIds:resolver:rejecter:)
    func generateIds(amountToGenerate: Int, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        var ids: [String] = []
        for _ in 1...amountToGenerate {
            ids.append("\(UUID())")
        }
        resolve(ids)
    }

    @objc(uploadFiles:resolver:rejecter:)
    func uploadFiles(fileUploads: [[String: Any]], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let uploads = tusClient.uploadFiles(fileUploads: fileUploads)
        resolve(uploads)
    }

    @objc(start:rejecter:)
    func start(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        tusClient.resume();
        resolve(true)
    }

    @objc(sync:rejecter:)
    func sync(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        let updates = tusClient.sync()
        resolve(updates)
    }

    @objc(pause:rejecter:)
    func pause(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        tusClient.pause()
        resolve(NSNull())
    }

    @objc(freeMemory:rejecter:)
    func freeMemory(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        tusClient.freeMemory()
        resolve(NSNull())
    }

    @objc(cancelByIds:resolver:rejecter:)
    func cancelByIds(uploadIds: [String], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
        do {
            try tusClient.cancelByIds(uuids: uploadIds)
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
            tusClient.startTasks(for: taskIds)
            resolve(results)
        } catch {
            reject("RETRY_ERROR", "Unexpected error", error)
        }
    }
}

@available(iOS 13.4, *)
extension TusNative: TUSClientDelegate {
    func didFinishUpload(id: UUID) {
        print("TUSClient finished upload, id is \(id)")
        let body: [String:Any] = [
            "uploadId": "\(id)"
        ]
        sendEvent(withName: TusNative.uploadFinishedEvent, body: body)
    }

    func uploadFailed(id: UUID, error: String) {
        print("TUSClient upload failed for \(id) error \(error)")
        let body: [String:Any] = [
            "uploadId": "\(id)",
            "error": error
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

    func cancelFinished(errorMessage: String?) {
        print("TUSClient cancel finished \(errorMessage)")
        let body: [String:Any] = [
            "errorMessage": errorMessage
        ]
        sendEvent(withName: TusNative.cancelFinishedEvent, body: body)
    }


    func totalProgress(bytesUploaded: Int, totalBytes: Int, client: TUSClient) {
        let body: [String:Any] = [
            "bytesUploaded": bytesUploaded,
            "totalBytes": totalBytes,
            "sessionId": "\(client.sessionIdentifier)"
        ]
        sendEvent(withName: TusNative.totalProgressEvent, body: body)
    }


    func progressFor(id: UUID, bytesUploaded: Int, totalBytes: Int) {
        let body: [String:Any] = [
            "uploadId": "\(id)",
            "bytesUploaded": bytesUploaded,
            "totalBytes": totalBytes
        ]
        sendEvent(withName: TusNative.progressForEvent, body: body)
    }

}
