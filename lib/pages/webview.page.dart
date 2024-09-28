import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uni_links/uni_links.dart';
import '../configs/config/config.dart';
import '../configs/socials/apple.config.dart';
import '../configs/socials/kakao.config.dart';
import '../configs/socials/naver.config.dart';
import '../controllers/device.controller.dart';
import '../controllers/inapp-web.controller.dart';
import '../controllers/notification.controller.dart';
import '../controllers/overlay.controller.dart';
import 'package:http/http.dart' as http;

import '../controllers/version.controller.dart';
import '../utills/common.dart';

class WebViewPage extends StatefulWidget {

  static const String routeName = '/webViewPage';

  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  late final DeviceController _deviceCtr = DeviceController.of(context);
  late final OverlayController _overlayCtr = OverlayController.of(context);
  late final InAppWebController _inAppWebCtr = InAppWebController.of(context);
  late final NotificationController _notificationCtr = NotificationController.of(context);
  late final VersionController _versionController = VersionController.of(context);

  Future<void> _deepLinkListener() async{
    final Uri? initUri = await getInitialUri();
    await _deepLinkHandler(initUri);
    uriLinkStream.listen(_deepLinkHandler);
  }

  Future<void> _deepLinkHandler(Uri? event) async {
    if(event != null) {
      log("DEEP LINK: ${event.toString()}");
      final String? url = event.queryParameters["url"];
      if(url != null) await _inAppWebCtr.webViewCtr.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))));
    }
  }

  final List<String> _allowHosts = <String>[
    HOST_NAME,
    "www.youtube.com",
  ];

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
        onCreateWindow: _onCreateWindow,
        initialUrlRequest: URLRequest(
          url: WebUri(Config.instance.getUrl()),
        ),
        initialSettings: InAppWebViewSettings(
          applicationNameForUserAgent: USERAGENT,
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          // supportMultipleWindows: true,
          // iframeAllowFullscreen: true,
          useOnDownloadStart: true,
          useShouldOverrideUrlLoading: true,
          allowFileAccessFromFileURLs: true,
          useShouldInterceptAjaxRequest: true,
          useHybridComposition: true,
          domStorageEnabled: true,
          cacheMode: CacheMode.LOAD_DEFAULT,
          cacheEnabled: true,
          allowFileAccess: true,
          allowContentAccess: true,
          mediaPlaybackRequiresUserGesture: true,
          allowsBackForwardNavigationGestures: true,
        ),
        onWebViewCreated: _onWebViewCreated,
        onLoadStart: _onLoadStart,
        onLoadStop: _onLoadStop,
        onReceivedHttpError: _onReceivedHttpError,
        onReceivedError: _onReceivedError,
      ),
    );
  }

  void _onReceivedHttpError(InAppWebViewController ctr, WebResourceRequest req, WebResourceResponse res) {
    log("STATUS_CODE: ${res.statusCode}");
    OverlayController.of(context).remove();
  }

  void _onReceivedError(InAppWebViewController ctr, WebResourceRequest req, WebResourceError err) {
    OverlayController.of(context).remove();
  }

  void _onDownloadStartRequest(InAppWebViewController ctr, DownloadStartRequest req) {
    log("${req.url}");
    _fileDownload(req.url.toString());
  }

  Future<WebResourceResponse> _androidShouldInterceptRequest(InAppWebViewController ctr, WebResourceRequest req) async{
    return WebResourceResponse();
  }

  void _onLoadResource(InAppWebViewController ctr, LoadedResource resource) {
    // debugPrint("resource url: ${resource.url}");
  }

  Future<bool?> _onCreateWindow(InAppWebViewController ctr, CreateWindowAction action) async{
    await ctr.loadUrl(urlRequest: action.request);
    log(action, title: "WINDOW.OPEN");
    return false;
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController ctr, NavigationAction action) async{
    final WebUri? webUri = action.request.url;

    final String? path = action.request.url?.path;

    if(path != null) if(path.startsWith("/index.php") || path == "/") await clearHistory();

    if(webUri != null) {
      String url = webUri.toString();
      final String host = webUri.host;

      log("SHOULD OVERRIDE URL : ${webUri.toString()}");
      log("HOST : ${webUri.host}");

      if(webUri.path == "/login.php" && webUri.queryParameters["view"] == "logout") {
        final NaverConfig na = NaverConfig();
        final KakaoConfig ka = KakaoConfig();
        await na.logout();
        await ka.logout();
      }

      if(!webUri.scheme.startsWith("http")/* || !_allowHosts.any((ah) => host == ah)*/){
        if(mounted) OverlayController.of(context).showIndicator(context, openURL(url));
        return NavigationActionPolicy.CANCEL;
      } else if(url.endsWith(".pdf") || url.endsWith(".hwp") || url.endsWith(".docx") || url.endsWith(".xlsx") || url.endsWith(".hwpx")){
        return _fileDownload(url);
      } else {
        return NavigationActionPolicy.ALLOW;
      }
    } else {
      return NavigationActionPolicy.CANCEL;
    }
  }

  Future<AjaxRequest?> _shouldInterceptAjaxRequest(InAppWebViewController ctr, AjaxRequest req) async{
    return req;
  }

  Future<FetchRequest?> _shouldInterceptFetchRequest(InAppWebViewController ctr, FetchRequest req) async{
    return req;
  }

  void _onWebViewCreated(InAppWebViewController ctr) async{
    String javascriptCode = "";
    /*for(final MapEntry<String, dynamic> map in _initialHeader.entries) {
      javascriptCode += "sessionStorage.setItem('${map.key}', '${map.value}');\n";
    }*/
    // javascriptCode = "setCookieWeb('fcmToken', '${NotificationController.of(context).fcmToken}');";

    _inAppWebCtr.webViewCtr = ctr
      ..evaluateJavascript(source: javascriptCode)
      ..reload();
  }

  void _onLoadStart(InAppWebViewController ctr, Uri? uri) async{
    log("CURRENT_URI = $uri");
    final String? path = uri?.path;
    if(path != null) {
      if(path.startsWith("/index.php") || path == "/") await clearHistory();
    }
    if(_inAppWebCtr.firstLoad && mounted) {
      if(IS_SHOW_OVERLAY) {
        final bool canGoForward = await _inAppWebCtr.webViewCtr.canGoForward();
        if(!canGoForward && mounted) _overlayCtr.show(context);
      }
    }
  }

  void _onLoadStop(InAppWebViewController ctr, Uri? uri) async{
    if(IS_SHOW_OVERLAY) {
      final bool canGoForward = await _inAppWebCtr.webViewCtr.canGoForward();
      if(!canGoForward && mounted) _overlayCtr.remove();
    }
    if(!_inAppWebCtr.firstLoad && _versionController.isChecked) {
      _overlayCtr.remove();
      _inAppWebCtr.firstLoad = true;
      if(mounted) await _notificationCtr.firebasePushListener(context);
      _deepLinkListener();
    }

    if(uri?.path.endsWith(LOGIN_PAGE) == true) {
      log(_notificationCtr.fcmToken, title: "FCM_TOKEN");
      ctr.evaluateJavascript(source: """
      document.getElementById('fcmToken').value = '${_notificationCtr.fcmToken}';
      document.getElementById('deviceId').value = '${_deviceCtr.deviceId}';
      """);
    }
    if(uri?.path.startsWith("/dashboard") == true) {
      log(uri?.path);
      ctr.evaluateJavascript(source: """
      \$\('#app_version').text('${_versionController.info?.version}');
      """);
    }
  }

  void _onConsoleMessage(InAppWebViewController ctr, ConsoleMessage cm) async{
    final String msg = cm.message;
    switch(msg) {
      case "kakao_login": return OverlayController.of(context).showIndicator(context, _kakaoLogin());
      case "naver_login": return OverlayController.of(context).showIndicator(context, _naverLogin());
      case "apple_login": return OverlayController.of(context).showIndicator(context, _appleLogin());

    }
    log(msg);
  }

  Future<void> _kakaoLogin() async{
    final KakaoConfig kc = KakaoConfig();
    final User? user = await kc.login();
    log(user, title: "USER");
    if(user != null) {
      final String script = """
      email = '${user.kakaoAccount?.email}';
      phone = '${user.kakaoAccount?.phoneNumber?.replaceAll("+82 10", "010")}';
      name = '${user.kakaoAccount?.name}';
      item = 'kakao';
      
      oPBP.setValue('item',item);
      oPBP.setValue('view','CheckApiLogin');
      oPBP.setValue('email', '${user.kakaoAccount?.email}');
      oPBP.setValue('fcmToken', '${NotificationController.of(context).fcmToken}');
      oPBP.setValue('deviceId', '${DeviceController.of(context).deviceId}');
      oPBP.doSubmit('login.php', OnFinishedLogin);
      """;
      log(script);
      await _inAppWebCtr.webViewCtr.evaluateJavascript(source: script);
    }
  }

  Future<void> _appleLogin() async{
    final AppleConfig kc = AppleConfig();
    final AuthorizationCredentialAppleID? user = await kc.login();
    if(user != null) {
      String name = "";
      if(user.familyName != null && user.givenName != null) {
        name = "${user.familyName}${user.givenName}";
      }
      final String script = """
      email = '${user.userIdentifier}';
      name = '$name';
      item = 'apple';
      
      oPBP.setValue('item',item);
      oPBP.setValue('view','CheckApiLogin');
      oPBP.setValue('email', '${user.userIdentifier}');
      oPBP.setValue('fmcToken', '${NotificationController.of(context).fcmToken}');
      oPBP.setValue('deviceId', '${DeviceController.of(context).deviceId}');
      oPBP.doSubmit('login.php', OnFinishedLogin);
      """;
      log(script);
      await _inAppWebCtr.webViewCtr.evaluateJavascript(source: script);
    }
  }

  Future<void> _naverLogin() async{
    final NaverConfig nc = NaverConfig();
    final NaverAccountResult? user = await nc.login();

    if(user != null) {
      final String script = """
      email = '${user.email}';
      phone = '${user.mobile.replaceAll("+82 10", "010")}';
      name = '${user.name}';
      item = 'naver';
      
      oPBP.setValue('item',item);
      oPBP.setValue('view','CheckApiLogin');
      oPBP.setValue('email', '${user.email}');
      oPBP.setValue('fcmToken', '${NotificationController.of(context).fcmToken}');
      oPBP.setValue('deviceId', '${DeviceController.of(context).deviceId}');
      oPBP.doSubmit('login.php', OnFinishedLogin);
      """;
      log(script);
      await _inAppWebCtr.webViewCtr.evaluateJavascript(source: script);
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

  Future<void> clearHistory() async{
    try {
      await _inAppWebCtr.webViewCtr.clearHistory();
    } catch(ignore){
    }
  }
}