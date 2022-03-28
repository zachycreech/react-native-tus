// import TUSKit

@objc(TusNative)
class TusNative: NSObject {
  // let tusClient: TUSClient

  // init() {
    // https://tusd.tusdemo.net/files
    // http://0.0.0.0:1080/files/
    // tusClient = TUSClient(
    //  server: URL(string: "http://0.0.0.0:1080/files/")!,
    //  sessionIdentifier: "TUS DEMO",
    //  storageDirectory: URL(string: "TUS")!
    // )
    // tusClient.delegate = self
  // }

  @objc(createUpload:options:resolve:reject:)
  func createUpload(fileUrl: String, options: [String:Any], resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    let endpoint: String = options["endpoint"]! as? String ?? ""
    let headers = options["headers"]! as? [String: Any] ?? [:]
    let metadata = options["metadata"]! as? [String: Any] ?? [:]

    resolve( "Dummy response: Starting upload with endpoint: \(endpoint) and Headers: \(headers) and metadata: \(metadata)" )
  }

  @objc(resume:resolve:reject:)
  func resume(uploadId: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) -> Void {
    resolve( "Dummy response: Resumed uploadId: \(uploadId)" )
  }

}
