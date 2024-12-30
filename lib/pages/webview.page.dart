import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_naver_login_plus/flutter_naver_login_plus.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uni_links/uni_links.dart';
import '../configs/config/config.dart';
import '../configs/socials/apple.config.dart';
import '../configs/socials/kakao.config.dart';
import '../configs/socials/naver.config.dart';
import '../controllers/device.controller.dart';
import '../controllers/notification.controller.dart';
import '../controllers/overlay.controller.dart';
import 'package:http/http.dart' as http;

import '../controllers/version.controller.dart';
import '../customs/custom.dart';
import '../utills/common.dart';
import 'window_popup.page.dart';

class WebViewPage extends StatefulWidget {

  static const String routeName = '/webViewPage';

  final URLRequest? request;

  const WebViewPage({this.request, super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {

  bool _loadCompleted = false;

  late final DeviceController _deviceCtr = DeviceController.of(context);
  late final OverlayController _overlayCtr = OverlayController.of(context);
  late final NotificationController _notificationCtr = NotificationController.of(context);
  late final VersionController _versionController = VersionController.of(context);

  final CookieManager _cookieManager = CookieManager.instance();

  InAppWebViewController? _controller;

  Future<void> _deepLinkListener() async{
    final Uri? initUri = await getInitialUri();
    await _deepLinkHandler(initUri);
    uriLinkStream.listen(_deepLinkHandler);
  }

  Future<void> _deepLinkHandler(Uri? event) async {
    if(event != null) {
      log("DEEP LINK: ${event.toString()}");
      final String? url = event.queryParameters["url"];
      if(url != null) await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))));
    }
  }

  final List<String> _allowHosts = <String>[
    HOST_NAME,
    "www.youtube.com",
    "www.payapp.kr",
    /*"nid.naver.com",
    "kauth.kakao.com",
    "talk-apps.kakao.com",
    "accounts.kakao.com",
    "logins.daum.net",*/
  ];

  final List<String> _allowFiles = <String>[
    "png",
    "jpg",
    "jpeg",
    "pdf",
    "hwp",
    "docx",
    "xlsx",
    "hwpx",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      _overlayCtr.showOverlayWidget(context, (context) => _buildSplash(context));
      if(mounted) await NotificationController.of(context).initialFcmToken();
      if(mounted) await DeviceController.of(context).getDeviceInfo();
      if(mounted) await _setInitialData();
      if(mounted) await VersionController.of(context).getVersion(context);
    });
  }

  Future<void> _setInitialData() async {
    final String? fcmToken = _notificationCtr.fcmToken;
    final String? deviceId = _deviceCtr.deviceId;
    final String? version = _versionController.info?.version;
    final DateTime expiredAt = DateTime.now().add(const Duration(days: 365));
    if(fcmToken != null) await _setCookie("FCM_TOKEN", fcmToken, expiredAt: expiredAt);
    if(deviceId != null) await _setCookie("DEVICE_ID", deviceId, expiredAt: expiredAt);
    if(version != null) await _setCookie("APP_VERSION", version, expiredAt: expiredAt);
  }

  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    applicationNameForUserAgent: USERAGENT,
    javaScriptEnabled: true,
    transparentBackground: true,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,
    iframeAllowFullscreen: true,
    useOnDownloadStart: true,
    useShouldOverrideUrlLoading: true,
    allowFileAccessFromFileURLs: true,
    useHybridComposition: true,
    domStorageEnabled: true,
    underPageBackgroundColor: Colors.white,
    cacheMode: CacheMode.LOAD_DEFAULT,
    cacheEnabled: true,
    allowFileAccess: true,
    allowContentAccess: true,
    mediaPlaybackRequiresUserGesture: true,
    allowsBackForwardNavigationGestures: true,
    supportZoom: false
  );

  Timer? _closeTimer;

  bool _canClose = false;

  Future<void> _onWillPop(bool didPop, dynamic data) async{
    final bool? canGoBack = await _controller?.canGoBack();

    if(mounted && _overlayCtr.entry != null) {
      _overlayCtr.remove();
    } else if(canGoBack == true) {
      _canClose = false;
      setState((){});
      await _controller?.goBack();
    } else {
      _closeTimer?.cancel();
      if(_canClose) exit(1);
      _canClose = true;
      setState(() {});
      showToast("뒤로가기 버튼을 한번 더 누르면 앱이 종료됩니다.");
      _closeTimer = Timer.periodic(const Duration(seconds: 1), (timer) => setState(() => _canClose = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onWillPop,
      child: Consumer<VersionController>(
          builder: (context, controller, child) {
            if(!controller.isChecked) {
              // if(false) {
              return _buildSplash(context);
            } else {
              return Scaffold(
                  backgroundColor: Colors.white,
                  body: _buildBody(context)
              );
            }
          }
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: InAppWebView(
        shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
        keepAlive: InAppWebViewKeepAlive(),
        onConsoleMessage: _onConsoleMessage,
        onDownloadStartRequest: _onDownloadStartRequest,
        onCreateWindow: _onCreateWindow,
        onWebViewCreated: _onWebViewCreated,
        onLoadStart: _onLoadStart,
        onLoadStop: _onLoadStop,
        onPermissionRequest: _onPermissionRequest,
        onReceivedHttpError: _onReceivedHttpError,
        onReceivedError: _onReceivedError,
        onWebContentProcessDidTerminate: _onWebContentProcessDidTerminate,
        initialUrlRequest: widget.request ?? URLRequest(
          url: WebUri(Config.instance.getUrl(INITIAL_PATH)),
        ),
        initialSettings: _webViewSettings,
      ),
    );
  }

  Widget _buildSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.splash,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: CustomColors.splash,
            image: DecorationImage(
                image: AssetImage(SPLASH_IMAGE),
                fit: BoxFit.cover
            )
        ),
      ),
    );
  }

  void _onWebContentProcessDidTerminate(InAppWebViewController ctr) {
    ctr.reload();
  }

  void _onReceivedHttpError(InAppWebViewController ctr, WebResourceRequest req, WebResourceResponse res) {
    _overlayCtr.remove();
  }

  void _onReceivedError(InAppWebViewController ctr, WebResourceRequest req, WebResourceError err) {
    log(err, title: "ERROR");
    final WebResourceErrorType type = err.type;
    if(type == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET) {
      showToast("인터넷 연결이 필요합니다.");
    }
    _overlayCtr.remove();
  }

  void _onDownloadStartRequest(InAppWebViewController ctr, DownloadStartRequest req) {
    _overlayCtr.showIndicator(context, _fileDownload(req));
  }

  Future<PermissionResponse?> _onPermissionRequest(InAppWebViewController ctr, PermissionRequest req) async{
    return PermissionResponse(resources: req.resources, action: PermissionResponseAction.GRANT);
  }

  Future<bool?> _onCreateWindow(InAppWebViewController ctr, CreateWindowAction action) async{
    log(action, title: "WINDOW.OPEN");
    // await ctr.loadUrl(urlRequest: action.request);
    await movePage(context, WindowPopupPage(action), fullscreenDialog: true);
    return true;
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController ctr, NavigationAction action) async{
    final WebUri? webUri = action.request.url;

    final String? path = action.request.url?.path;

    if(path != null) if(path.startsWith("/index.php") || path == "/") await clearHistory();

    if(webUri != null) {
      String url = webUri.toString();
      final String host = webUri.host;

      log(url, title: "SHOULD OVERRIDE URL");
      log(host, title: "HOST");

      if(webUri.path == LOGOUT_PAGE) {
        final NaverConfig na = NaverConfig();
        final KakaoConfig ka = KakaoConfig();
        await na.logout();
        await ka.logout();
      }

      if((!webUri.isScheme("http") && !webUri.isScheme("https")) || !_allowHosts.any((ah) => host == ah)){
        if(mounted) await openURL(url);
        return NavigationActionPolicy.CANCEL;
      } else if(_allowFiles.any((type) => url.endsWith(".$type"))){
        return NavigationActionPolicy.DOWNLOAD;
      } else {
        return NavigationActionPolicy.ALLOW;
      }
    } else {
      return NavigationActionPolicy.CANCEL;
    }
  }

  void _onWebViewCreated(InAppWebViewController ctr) {
    _controller = ctr;
  }

  void _onLoadStart(InAppWebViewController ctr, Uri? uri) async{
    log(uri, title: "CURRENT_URL");
    final String? path = uri?.path;
    if(mounted && INITIAL_PATH == path) await clearHistory();

    if(mounted && !_loadCompleted) {
      _overlayCtr.showOverlayWidget(context, _buildSplash);
    } else if(mounted) {
      _overlayCtr.show(context);
    }
  }

  void _onLoadStop(InAppWebViewController ctr, Uri? uri) async{
    if(IS_SHOW_OVERLAY && _loadCompleted) _overlayCtr.remove();

    if(!_loadCompleted && _versionController.isChecked) {
      _overlayCtr.remove();
      _loadCompleted = true;
      if(mounted) await _notificationCtr.firebasePushListener(_controller);
      _deepLinkListener();
    }
  }

  void _onConsoleMessage(InAppWebViewController ctr, ConsoleMessage cm) async{
    final String msg = cm.message;
    switch(msg) {
      case "kakao_login": return _overlayCtr.showIndicator(context, _kakaoLogin());
      case "naver_login": return _overlayCtr.showIndicator(context, _naverLogin());
      case "apple_login": return _overlayCtr.showIndicator(context, _appleLogin());
    }
    log(msg);
  }

  Future<void> _kakaoLogin() async{
    final KakaoConfig kc = KakaoConfig();
    final User? user = await kc.login();
    log(user, title: "USER");
    if(user != null) {

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
    }
  }

  Future<void> _naverLogin() async{
    final NaverConfig nc = NaverConfig();
    final NaverAccountResult? user = await nc.login();

    if(user != null && mounted) {

    }
  }

  Future<void> _fileDownload(DownloadStartRequest req) async {
    final String filename = req.suggestedFilename ?? DateTime.now().microsecondsSinceEpoch.toString();

    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = "${directory.path}/$filename";
    final File file = File(filePath);
    final http.Response res = await http.get(req.url);
    if(!(await File(filePath).exists())) await file.writeAsBytes(res.bodyBytes.buffer.asUint8List());
    await OpenFilex.open(file.path);
  }

  Future<void> clearHistory() async{
    try {
      log("CLEAR HISTORY");
      await _controller?.clearHistory();
    } catch(ignore){
    }
  }

  Future<void> _setCookie(String name, String value, {
    DateTime? expiredAt
  }) async {
    await _cookieManager.setCookie(url: WebUri.uri(Uri.parse(Config.instance.getUrl())), name: name, value: value, expiresDate: expiredAt?.millisecondsSinceEpoch);
  }
}