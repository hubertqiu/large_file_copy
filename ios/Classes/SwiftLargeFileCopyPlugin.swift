import Flutter
import UIKit

public class SwiftLargeFileCopyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ch.ideenkaffee.largefilecopy", binaryMessenger: registrar.messenger())
    let instance = SwiftLargeFileCopyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    // flutter cmds dispatched on iOS device :
    switch(call.method) {
      case "copyLargeFile":
        guard let args = call.arguments else {
          result(false)
          return
        }
        if let myArgs = args as? [String: Any],
          let sourceFilePath = myArgs["sourceFilePath"] as? String,
          let distFilePath = myArgs["distFilePath"] as? String {
            result(copyFileIfNeeded(sourceFilePath: sourceFilePath, distFilePath: distFilePath))
        } else {
          result(false)
        } 
      case "getPlatformVersion":
        result("Running on iOS: " + UIDevice.current.systemVersion)
      default:
        result("iOS calling method not recognized")
    }
  }
}

// Copy file from bundle to documents folder and return its destination path
// (only copy if not existing already with same name)
private func copyFileIfNeeded(sourceFilePath: String, distFilePath: String) -> Bool {
    let fileManager = FileManager.default
    let documentDirectoryUrls = fileManager.urls(for: .documentDirectory,
                                        in: .userDomainMask)
    guard documentDirectoryUrls.count != 0 else {
      return false
    }
    let outputFileFullUrl = URL(fileURLWithPath: distFilePath)
    if ( (try? outputFileFullUrl.checkResourceIsReachable()) ?? false) {
        return true
    }
    do {
      let sourceFileFullUrl = Bundle.main.resourceURL?.appendingPathComponent(sourceFilePath)
      try fileManager.createDirectory(atPath: NSString(string:distFilePath).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
      try fileManager.copyItem(atPath: (sourceFileFullUrl?.path)!, toPath: distFilePath)
      return true
    } catch _ as NSError {
      return false
    }
}
