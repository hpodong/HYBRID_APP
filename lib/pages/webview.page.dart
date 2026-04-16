import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../configs/config/config.dart';
import 'package:http/http.dart' as http;

import '../providers/device_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/overlay_provider.dart';
import '../providers/version_provider.dart';
import '../utills/common.dart';
import 'window_popup.page.dart';

class WebViewPage extends ConsumerStatefulWidget {

  static const String path = '/webview';
  static const String routeName = 'webViewPage';

  final URLRequest? request;

  const WebViewPage({this.request, super.key});

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends ConsumerState<WebViewPage> {

  late final OverlayStateNotifier _overlayStateNotifier = ref.read(overlayProvider.notifier);
  late final DeviceStateNotifier _deviceStateNotifier = ref.read(deviceProvider.notifier);
  late final VersionStateNotifier _versionStateNotifier = ref.read(versionProvider.notifier);
  late final FcmTokenStateNotifier _fcmTokenStateNotifier = ref.read(notificationProvider.notifier);

  final CookieManager _cookieManager = CookieManager.instance();

  InAppWebViewController? _controller;

  bool _firstLoad = false;

  Future<void> _deepLinkListener() async{
    final AppLinks appLinks = AppLinks();

    final Uri? initUri = await appLinks.getInitialLink();
    await _deepLinkHandler(initUri);
    appLinks.uriLinkStream.listen(_deepLinkHandler);
  }

  Future<void> _deepLinkHandler(Uri? event) async {
    if(event != null) {
      log(event, title: "DEEP LINK");
      final String? url = event.queryParameters["url"];
      if(url != null) await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))));
    }
  }

  static final List<String> _allowHosts = <String>[
    HOST_NAME,
    "www.youtube.com",
    /*"nid.naver.com",
    "kauth.kakao.com",
    "talk-apps.kakao.com",
    "accounts.kakao.com",
    "logins.daum.net",*/
  ];

  static final List<String> _allowFiles = <String>[
    "png",
    "jpg",
    "jpeg",
    "pdf",
    "hwp",
    "docx",
    "xlsx",
    "hwpx",
    "svg",
  ];

  @override
  void initState() {
    super.initState();
    _setInitialData();
  }

  Future<void> _setInitialData() async {
    await _deviceStateNotifier.setDeviceInfo();
    final String? fcmToken = _fcmTokenStateNotifier.fcmToken;
    final String? deviceId = _deviceStateNotifier.deviceId;
    final String? version = _versionStateNotifier.version;
    final DateTime expiredAt = DateTime.now().add(const Duration(days: 365));

    if(fcmToken != null) await _setCookie("FCM_TOKEN", fcmToken, expiredAt: expiredAt);
    if(deviceId != null) await _setCookie("DEVICE_ID", deviceId, expiredAt: expiredAt);
    if(version != null) await _setCookie("APP_VERSION", version, expiredAt: expiredAt);
  }

  final InAppWebViewSettings _webViewSettings = InAppWebViewSettings(
    applicationNameForUserAgent: USERAGENT,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: true,
    iframeAllowFullscreen: true,
    useOnDownloadStart: true,
    useShouldOverrideUrlLoading: true,
    underPageBackgroundColor: Colors.white,
    cacheMode: CacheMode.LOAD_DEFAULT,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    supportZoom: false,
  );

  Timer? _closeTimer;

  bool _canClose = false;

  Future<void> _onWillPop(bool didPop, dynamic data) async{
    final bool? canGoBack = await _controller?.canGoBack();

    if(mounted && _overlayStateNotifier.isShowingOverlay) {
      _overlayStateNotifier.remove();
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
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
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
            )
        )
    );
  }

  void _onWebContentProcessDidTerminate(InAppWebViewController ctr) {
    ctr.reload();
  }

  void _onReceivedHttpError(InAppWebViewController ctr, WebResourceRequest req, WebResourceResponse res) {
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
  }

  void _onReceivedError(InAppWebViewController ctr, WebResourceRequest req, WebResourceError err) {
    log(err, title: "ERROR");
    final WebResourceErrorType type = err.type;
    if(type == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET) {
      showToast("인터넷 연결이 필요합니다.");
    }
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
  }

  void _onDownloadStartRequest(InAppWebViewController ctr, DownloadStartRequest req) {
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.showIndicator(context, _fileDownload(req));
  }

  Future<PermissionResponse?> _onPermissionRequest(InAppWebViewController ctr, PermissionRequest req) async{
    return PermissionResponse(resources: req.resources, action: PermissionResponseAction.GRANT);
  }

  Future<bool?> _onCreateWindow(InAppWebViewController ctr, CreateWindowAction action) async{
    log(action, title: "WINDOW.OPEN");
    /*if(mounted) context.pushNamed(WindowPopupPage.routeName, extra: action);*/
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => WindowPopupPage(action)));
    return true;
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController ctr, NavigationAction action) async{
    final WebUri? webUri = action.request.url;

    if(webUri != null) {
      String url = webUri.toString();
      final String host = webUri.host;

      if(!webUri.isScheme("https") && !webUri.isScheme("http")/* || !_allowHosts.any((ah) => host == ah)*/){
        if(mounted) _overlayStateNotifier.showIndicator(context, openURL(url));
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
    _controller = ctr
      ..addJavaScriptHandler(
          handlerName: "getLocation",
          callback: (args) async{
            final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              return {"status": "LOCATION_DISABLED"};
            }

            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
            }

            if (permission == LocationPermission.denied) {
              return {"status": "DENIED"};
            }

            if (permission == LocationPermission.deniedForever) {
              return {"status": "DENIED_FOREVER"};
            }

            if (permission == LocationPermission.unableToDetermine) {
              return {"status": "UNABLE_TO_DETERMINE"};
            }

            final LocationSettings settings = const LocationSettings(
                timeLimit: Duration(seconds: 5)
            );
            try {
              final Position position = await Geolocator.getCurrentPosition(
                  locationSettings: settings
              );
              return {
                "status": "SUCCESS",
                "latitude": position.latitude,
                "longitude": position.longitude,
              };
            } catch(e) {
              return {
                "status": "ERROR",
                "message": e.toString()
              };
            }
          }
      );
  }

  void _onLoadStart(InAppWebViewController ctr, Uri? uri) async{
    log(uri, title: "CURRENT_URL");
    final String? path = uri?.path;
    if(mounted && INITIAL_PATH == path) await clearHistory();

    if(IS_SHOW_OVERLAY && mounted) _overlayStateNotifier.show(context);

    if(path != null) if(path.startsWith("/index.php") || path == "/" || path == "/main") await clearHistory();
  }

  void _onLoadStop(InAppWebViewController ctr, Uri? uri) async{
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();

    if(_versionStateNotifier.isChecked) {
      if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
      if(!_firstLoad) {
        setState(() => _firstLoad = true);
        await _fcmTokenStateNotifier.firebasePushListener(_controller);
        _deepLinkListener();
      }
    }

    if(USE_NOTIFICATION && LOGIN_PAGE == uri?.path) {
      final String? fcmToken = ref.read(notificationProvider);
      await ctr.evaluateJavascript(source: """
      window.open('https://naver.com','_blank')
      """);
      if(fcmToken != null) {
        await ctr.evaluateJavascript(source: """
          document.getElementById('fcmToken').value = '$fcmToken';
          """);
      }
    }
  }

  void _onConsoleMessage(InAppWebViewController ctr, ConsoleMessage cm) async{
    final String msg = cm.message;
    log(msg, title: "CONSOLE_MESSAGE");

    switch(msg) {
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
    log("NAME : $name, VALUE : $value");
  }
}