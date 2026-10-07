import Flutter
import ImageIO
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "KidpoolFaceDetection") {
      FaceDetectionChannel.register(with: registrar)
    }
  }
}

/// `kidpool/face_detection`: finds faces in a photo file with Apple's Vision
/// framework (on-device, no network). Android does the same with ML Kit in
/// MainActivity.kt; the Dart side decides whether a selfie passes.
enum FaceDetectionChannel {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "kidpool/face_detection",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "detectFaces",
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let faces = try detectFaces(path: path)
          DispatchQueue.main.async { result(faces) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(
              code: "detection_failed",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
      }
    }
  }

  /// Each face as a box normalised to 0...1 (top-left origin) of the upright
  /// photo, plus head yaw/roll in degrees when Vision provides them.
  private static func detectFaces(path: String) throws -> [[String: Double]] {
    let url = URL(fileURLWithPath: path)
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
      throw NSError(
        domain: "FaceDetection",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Couldn't read the photo"]
      )
    }
    // Camera photos are stored sideways with an EXIF orientation tag.
    let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    let rawOrientation = properties?[kCGImagePropertyOrientation] as? UInt32 ?? 1
    let orientation = CGImagePropertyOrientation(rawValue: rawOrientation) ?? .up

    let request = VNDetectFaceRectanglesRequest()
    try VNImageRequestHandler(cgImage: image, orientation: orientation).perform([request])

    return (request.results ?? []).map { face in
      // Vision's origin is bottom-left; flip to top-left like Android.
      let box = face.boundingBox
      var out: [String: Double] = [
        "left": Double(box.minX),
        "top": Double(1 - box.maxY),
        "width": Double(box.width),
        "height": Double(box.height),
      ]
      if let yaw = face.yaw?.doubleValue { out["yaw"] = yaw * 180 / .pi }
      if let roll = face.roll?.doubleValue { out["roll"] = roll * 180 / .pi }
      return out
    }
  }
}
