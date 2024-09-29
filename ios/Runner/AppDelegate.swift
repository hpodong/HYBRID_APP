import UIKit
import Flutter
import FirebaseCore
import NaverThirdPartyLogin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
  FirebaseApp.configure();
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let LAUNCH_CHANNEL = "method_channel"
    let launchMethodChannel = FlutterMethodChannel(name: LAUNCH_CHANNEL, binaryMessenger: controller.binaryMessenger)

    launchMethodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          if call.method == "openURL" {
            if let args = call.arguments as? Dictionary<String, Any>,
               let urlStr = args["url"] as? String,
               let url = URL(string: urlStr) {
              if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                result(true)
              } else {
                result(FlutterError(code: "UNAVAILABLE", message: "URL cannot be opened", details: nil))
              }
            } else {
              result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid URL", details: nil))
            }
          } else {
            result(FlutterMethodNotImplemented)
          }
        }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      var applicationResult = false
      if (!applicationResult) {
         applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
      }
      // if you use other application url process, please add code here.

      if (!applicationResult) {
         applicationResult = super.application(app, open: url, options: options)
      }
      return applicationResult
  }
}
