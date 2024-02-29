import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soccerdiary/configs/socials/apple.config.dart';
import 'package:soccerdiary/configs/socials/kakao.config.dart';
import 'package:soccerdiary/configs/socials/naver.config.dart';
import 'package:soccerdiary/controllers/version.controller.dart';
import 'package:soccerdiary/customs/custom.dart';
import 'package:uni_links/uni_links.dart';
import '../configs/config/config.dart';
import '../configs/socials/google.config.dart';
import '../controllers/device.controller.dart';
import '../controllers/inapp-web.controller.dart';
import '../controllers/notification.controller.dart';
import '../controllers/overlay.controller.dart';
import 'package:http/http.dart' as http;

import '../utills/common.dart';

class WebViewPage extends StatefulWidget {

  static const String routeName = '/webViewPage';

  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  late final DeviceController _deviceCtr = DeviceController.of(context);
  late final OverlayController _overlayCtr = OverlayController.of(context);
  late final InAppWebController _inAppWebCtr = InAppWebController.of(context);
  late final NotificationController _notificationCtr = NotificationController.of(context);

  Map<String, String> get _initialHeader => <String, String>{
    "fcm-token": _notificationCtr.fcmToken ?? '',
    "device-code": _deviceCtr.deviceCode ?? "",
    "device-uuid": _deviceCtr.deviceId ?? "",
    "device-type": _deviceCtr.deviceType ?? ""
  };

  final List<String> _allowFiles = <String>[
    ".pdf",
    ".hwp",
    ".docx",
    ".xlsx",
    ".hwpx",
  ];

  Future<void> _deepLinkListener() async{
    uriLinkStream.listen((event) {
      if(event != null) {
        log("DEEP LINK: ${event.toString()}");
        _inAppWebCtr.webViewCtr.loadUrl(urlRequest: URLRequest(url: WebUri.uri(event)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _buildBody(context)
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: InAppWebView(
        onConsoleMessage: _onConsoleMessage,
        onDownloadStartRequest: _onDownloadStartRequest,
        // androidShouldInterceptRequest: _androidShouldInterceptRequest,
        shouldInterceptAjaxRequest: _shouldInterceptAjaxRequest,
        shouldInterceptFetchRequest: _shouldInterceptFetchRequest,
        shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
        onLoadResource: _onLoadResource,
        initialUrlRequest: URLRequest(
            url: WebUri(Config.instance.HOST_NAME),
            headers: _initialHeader
        ),
        initialSettings: InAppWebViewSettings(
            applicationNameForUserAgent: Platform.isIOS ? "TOYOU_IOS" : "TOYOU_ANDROID",
            javaScriptEnabled: true,
            useOnDownloadStart: true,
            useShouldOverrideUrlLoading: true,
            allowFileAccessFromFileURLs: true,
            useHybridComposition: true,
            domStorageEnabled: true,
            cacheMode: CacheMode.LOAD_NO_CACHE,
            cacheEnabled: false,
            allowFileAccess: true,
            allowContentAccess: true,
            mediaPlaybackRequiresUserGesture: true,
            useOnLoadResource: false,
          allowsBackForwardNavigationGestures: false,
        ),
        onWebViewCreated: _onWebViewCreated,
        onLoadStart: _onLoadStart,
        onLoadStop: _onLoadStop,
      ),
    );
  }

  void _onDownloadStartRequest(InAppWebViewController ctr, DownloadStartRequest req) {
    debugPrint("${req.url}");
    _fileDownload(req.url.toString());
  }

  Future<WebResourceResponse> _androidShouldInterceptRequest(InAppWebViewController ctr, WebResourceRequest req) async{
    debugPrint("ANDROID: ${req.url}");
    return WebResourceResponse();
  }

  void _onLoadResource(InAppWebViewController ctr, LoadedResource resource) {
    // debugPrint("resource url: ${resource.url}");
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController ctr, NavigationAction action) async{
    final WebUri? webUri = action.request.url;

    debugPrint("SHOULD OVERRIDE URL : ${webUri.toString()}");
    debugPrint("HOST : ${webUri?.host}");

    if(webUri != null) {
      final String url = webUri.toString();
      if(!url.startsWith(Config.instance.HOST_NAME) && !url.contains("youtube")){
        if(action.isForMainFrame) await openURL(url);
        return NavigationActionPolicy.CANCEL;
      } else if(url.startsWith("${Config.instance.HOST_NAME}/login/submit") && action.request.method == "post"){
        return NavigationActionPolicy.CANCEL;
      } else if(url.endsWith(".pdf") || url.endsWith(".hwp") || url.endsWith(".docx") || url.endsWith(".xlsx") || url.endsWith(".hwpx")){
        return _fileDownload(url);
      } else if(url.startsWith("https://oursoccer.net/mypage/setting") && action.request.url?.queryParameters["version"] == null) {
        final VersionController vc = VersionController.of(context);
        final URLRequest ureq = URLRequest(
          url: WebUri("$url?version=${vc.info?.version}&buildNum=${vc.info?.buildNumber}"),
        );
        ctr.loadUrl(urlRequest: ureq);

        return NavigationActionPolicy.ALLOW;
      } else {
        return NavigationActionPolicy.ALLOW;
      }
    } else {
      return NavigationActionPolicy.CANCEL;
    }
  }

  Future<AjaxRequest?> _shouldInterceptAjaxRequest(InAppWebViewController ctr, AjaxRequest req) async{
    debugPrint("ajaxRequest");
    return req;
  }

  Future<FetchRequest?> _shouldInterceptFetchRequest(InAppWebViewController ctr, FetchRequest req) async{
    debugPrint("fetchRequest");
    return req;
  }

  void _onWebViewCreated(InAppWebViewController ctr) async{
    String javascriptCode = "";
    for(final MapEntry<String, dynamic> map in _initialHeader.entries) {
      javascriptCode += "sessionStorage.setItem('${map.key}', '${map.value}');\n";
    }
    InAppWebController.of(context).webViewCtr = ctr
      ..evaluateJavascript(source: javascriptCode)
      ..reload();
  }

  void _onLoadStart(InAppWebViewController ctr, Uri? uri){
    debugPrint("CURRENT_URI = $uri");
  }

  void _onLoadStop(InAppWebViewController ctr, Uri? uri) async{
    if(!InAppWebController.of(context).firstLoad && VersionController.of(context).isChecked) {
      _overlayCtr.removeOverlay();
      _inAppWebCtr.firstLoad = true;
      _notificationCtr.firebasePushListener(context);
      _deepLinkListener();
    }
  }

  void _onConsoleMessage(InAppWebViewController ctr, ConsoleMessage cm) async{
    final String msg = cm.message;
    log(cm.message);
    switch(msg) {
      case "google-login":
        await CustomOverlay.indicator(context, _googleLogin());
        break;
      case "apple-login":
        await CustomOverlay.indicator(context, _appleLogin());
        break;
      case "naver-login":
        await CustomOverlay.indicator(context, _naverLogin());
        break;
      case "kakao-login":
        await CustomOverlay.indicator(context, _kakaoLogin());
        break;
      case "share":
        if(Platform.isAndroid) {
          final WebUri? curUri = await ctr.getUrl();
          if(curUri != null) {
            await Share.shareUri(curUri.uriValue);
          }
        } else {
          ctr.evaluateJavascript(source: "navigator.share");
        }
        break;
    }
  }

  Future<void> _googleLogin() async {
    final GoogleConfig gc = GoogleConfig();
    final GoogleSignInAccount? ga = await gc.login();
    log(ga);
    if(ga != null) {
      final Map<String, dynamic> body = <String, dynamic>{
        "gg_email": ga.email,
        "channel": "4"
      };
      final String bodyData = Uri(queryParameters: body).query;
      log("${Config.instance.HOST_NAME}/api/sns/login/google.php");
      await _inAppWebCtr.webViewCtr.postUrl(
          url: WebUri("${Config.instance.HOST_NAME}/api/sns/login/google.php"),
          postData: Uint8List.fromList(utf8.encode(bodyData))
      );
    }
  }

  Future<void> _appleLogin() async {
    final AppleConfig ac = AppleConfig();
    final AuthorizationCredentialAppleID? aa = await ac.login();
    log("AuthorizationCredentialAppleID: $aa");

    String? email = aa?.email;
    String name = "";
    if(aa?.givenName != null) name += aa?.givenName ?? "";
    if(aa?.familyName != null) name += aa?.familyName ?? "";

    if(aa != null && email == null) {
      final List<String> jwt = aa.identityToken?.split('.') ?? [];
      String payload = jwt[1];
      payload = base64.normalize(payload);
    
      final List<int> jsonData = base64.decode(payload);
      final userInfo = jsonDecode(utf8.decode(jsonData));
      print(userInfo);

      email = userInfo['email'];
    }

    if(email != null) {
      final Map<String, dynamic> body = <String, dynamic>{
        "apple_email": email,
        "name": name,
        "channel": "5"
      };

      final String bodyData = Uri(queryParameters: body).query;

      await _inAppWebCtr.webViewCtr.postUrl(
          url: WebUri("${Config.instance.HOST_NAME}/api/sns/login/apple.php"),
          postData: Uint8List.fromList(utf8.encode(bodyData))
      );
    }
  }
  Future<void> _naverLogin() async {
    final NaverConfig nc = NaverConfig();
    final NaverAccountResult? na = await nc.login();

    log("NAVER RESULT: ${na}");

    if(na != null) {
      String? email = na?.email;
      String? name = na?.name;

      final Map<String, dynamic> body = <String, dynamic>{
        "email": email,
        "name": name
      };

      final String bodyData = Uri(queryParameters: body).query;

      await _inAppWebCtr.webViewCtr.postUrl(
          url: WebUri("${Config.instance.HOST_NAME}/api/sns/login/naver.php"),
          postData: Uint8List.fromList(utf8.encode(bodyData))
      );
    }
  }

  Future<void> _kakaoLogin() async {
    final KakaoConfig nc = KakaoConfig();
    final User? na = await nc.login();
    final Account? account = na?.kakaoAccount;

    if(account != null) {
      String? email = account.email;
      String? name = account.name;

      final Map<String, dynamic> body = <String, dynamic>{
        "email": email,
        "name": name
      };

      final String bodyData = Uri(queryParameters: body).query;

      await _inAppWebCtr.webViewCtr.postUrl(
          url: WebUri("${Config.instance.HOST_NAME}/api/sns/login/kakao.php"),
          postData: Uint8List.fromList(utf8.encode(bodyData))
      );
    }
  }

  Future<NavigationActionPolicy> _fileDownload(String? url) async {
    if(url != null) {
      final Uri uri = Uri.parse(url);
      final http.Response res = await http.get(uri);
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = "${directory.path}/${url.split("/").last}";
      final File file = File(filePath);
      if(!(await File(filePath).exists())) await file.writeAsBytes(res.bodyBytes.buffer.asUint8List());
      OpenFilex.open(filePath);
      return NavigationActionPolicy.CANCEL;
    } else {
      return NavigationActionPolicy.CANCEL;
    }
  }

}