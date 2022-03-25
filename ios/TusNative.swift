import TUSKit

@objc(TusNative)
class TusNative: NSObject {
  let tusClient: TUSClient

  init() {
    tusClient = TUSClient(
      server: URL(string: "https://tusd.tusdemo.net/files")!,
      sessionIdentifier: "TUS DEMO",
      storageDirectory: URL(string: "TUS")!
    )
    tusClient.delegate = self
  }

  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
    resolve(a*b)
  }

  @objc(createUpload:options:onCreated:)
  func createUpload(fileUrl: String, options: Dictionary) -> Void {

  }

  @objc(resume:withCallback)
  func resume() -> Void {

  }

}
