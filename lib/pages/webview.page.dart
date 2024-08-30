import 'dart:io';

import 'package:HYBRID_APP/customs/custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uni_links/uni_links.dart';
import '../configs/config/config.dart';
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
            url: WebUri(Config.instance.getUrl()),
        ),
        initialSettings: InAppWebViewSettings(
          applicationNameForUserAgent: USERAGENT,
          javaScriptEnabled: true,
          useOnDownloadStart: true,
          useShouldOverrideUrlLoading: true,
          allowFileAccessFromFileURLs: true,
          useHybridComposition: true,
          domStorageEnabled: true,
          cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
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
      ),
    );
  }

  void _onReceivedHttpError(InAppWebViewController ctr, WebResourceRequest req, WebResourceResponse res) {
    log("STATUS_CODE: ${res.statusCode}");
  }

  void _onDownloadStartRequest(InAppWebViewController ctr, DownloadStartRequest req) {
    debugPrint("${req.url}");
    _fileDownload(req.url.toString());
  }

  Future<WebResourceResponse> _androidShouldInterceptRequest(InAppWebViewController ctr, WebResourceRequest req) async{
    return WebResourceResponse();
  }

  void _onLoadResource(InAppWebViewController ctr, LoadedResource resource) {
    // debugPrint("resource url: ${resource.url}");
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController ctr, NavigationAction action) async{
    final WebUri? webUri = action.request.url;

    debugPrint("SHOULD OVERRIDE URL : ${webUri.toString()}");
    debugPrint("HOST : ${webUri?.host}");
    debugPrint("TYPE : ${action.navigationType}");

    final String? path = action.request.url?.path;
    if(path != null) {
      if(path.startsWith("/index.php") || path == "/") await clearHistory();
      if(path.contains("process.php") && await ctr.canGoForward()) {
        await ctr.goBack();
      }
    }

    if(webUri != null) {
      final String url = webUri.toString();
      if(webUri.host != HOST_NAME && !url.contains("youtube")){
        if(action.isForMainFrame) await openURL(url);
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
    debugPrint("ajaxRequest");
    return req;
  }

  Future<FetchRequest?> _shouldInterceptFetchRequest(InAppWebViewController ctr, FetchRequest req) async{
    debugPrint("fetchRequest");
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
    debugPrint("CURRENT_URI = $uri");
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
      if(mounted) _notificationCtr.firebasePushListener(context);
      _deepLinkListener();
    }

    if(uri?.path.endsWith(LOGIN_PAGE) == true) {
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
    log(msg);
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