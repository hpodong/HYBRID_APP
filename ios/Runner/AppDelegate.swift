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

                if url.scheme != "http" && url.scheme != "https" {
                    UIApplication.shared.open(url, options: [:], completionHandler:{ (success) in
                        if !(success){
                            if let scheme = url.scheme,
                               let appStoreURLString = Constant.appStoreURL[scheme],
                               let appStoreURL = URL(string: appStoreURLString) {
                                UIApplication.shared.open(appStoreURL)
                            } else {
                                result(FlutterError(code: "UNAVAILABLE", message: "URL cannot be opened", details: nil))
                            }
                        }
                    })
                    // `decisionHandler`를 제거한 부분입니다.
                } else {
                    // 웹뷰에서 링크로 이동하는 경우
                    result(true) // 링크가 허용되면 `true`를 반환
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

enum Constant {
  static let appStoreURL: [String: String] = [
    "supertoss": "https://apps.apple.com/app/id839333328",
    "kb-acp": "https://apps.apple.com/app/id695436326",
    "liivbank": "https://apps.apple.com/app/id1126232922",
    "newliiv": "https://apps.apple.com/app/id1243688572",
    "kbbank": "https://apps.apple.com/app/id478746917",
    "nhappcardansimclick": "https://apps.apple.com/app/id904463701",
    "nhallonepayansimclick": "https://apps.apple.com/app/id1177889176",
    "nonghyupcardansimclick": "https://apps.apple.com/app/id905181935",
    "lottesmartpay": "https://apps.apple.com/app/id668497947",
    "lotteappcard": "https://apps.apple.com/app/id688047200",
    "mpocket.online.ansimclick": "https://apps.apple.com/app/id535125356",
    "ansimclickscard": "https://apps.apple.com/app/id1085225364",
    "tswansimclick": "https://apps.apple.com/app/id1025269634",
    "ansimclickipcollect": "https://apps.apple.com/app/id1072078532",
    "vguardstart": "https://apps.apple.com/app/id964672118",
    "samsungpay": "https://apps.apple.com/app/id1144937034",
    "scardcertiapp": "https://apps.apple.com/app/id734097122",
    "shinhan-sr-ansimclick": "https://apps.apple.com/app/id572462317",
    "smshinhanansimclick": "https://apps.apple.com/app/id998358874",
    "com.wooricard.wcard": "https://apps.apple.com/app/id1499598869",
    "newsmartpib": "https://apps.apple.com/app/id1470181651",
    "citispay": "https://apps.apple.com/app/id1179759666",
    "citicardappkr": "https://apps.apple.com/app/id1179759666",
    "citimobileapp": "https://apps.apple.com/app/id1179759666",
    "cloudpay": "https://apps.apple.com/app/id847268987",
    "hanawalletmembers": "https://apps.apple.com/app/id1038288833",
    "hdcardappcardansimclick": "https://apps.apple.com/app/id702653088",
    "smhyundaiansimclick": "https://apps.apple.com/app/id988674952",
    "shinsegaeeasypayment": "https://apps.apple.com/app/id666237916",
    "payco": "https://apps.apple.com/app/id924292102",
    "lpayapp": "https://apps.apple.com/app/id1036098908",
    "ispmobile": "https://apps.apple.com/app/id369125087",
    "tauthlink": "https://apps.apple.com/app/id1021447675",
    "ktauthexternalcall": "https://apps.apple.com/app/id1021447675",
    "upluscorporation": "https://apps.apple.com/app/id1091851329",
    "kftc-bankpay": "https://apps.apple.com/app/id398456030",
    "kakaotalk": "https://apps.apple.com/app/id362057947",
    "wooripay": "https://apps.apple.com/app/id1201113419",
    "lmslpay": "https://apps.apple.com/app/id473250588",
    "naversearchthirdlogin": "https://apps.apple.com/app/id393499958",
    "hanaskcardmobileportal": "https://apps.apple.com/app/id910573397",
    "kb-bankpay": "https://apps.apple.com/app/id988674897"
  ]
}
