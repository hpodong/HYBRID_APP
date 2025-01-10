import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../configs/config/config.dart';
import '../providers/overlay_provider.dart';
import '../utills/common.dart';

class WindowPopupPage extends ConsumerStatefulWidget {

  static const String path = "/window";
  static const String routeName = "windowPopupPage";

  final CreateWindowAction action;
  const WindowPopupPage(this.action, {super.key});

  @override
  WindowPopupPageState createState() => WindowPopupPageState();
}

class WindowPopupPageState extends ConsumerState<WindowPopupPage> {

  String? _title;

  InAppWebViewController? _controller;

  late final OverlayStateNotifier _overlayStateNotifier = ref.read(overlayProvider.notifier);

  Future<void> _onPopInvokedWithResult(bool canPop, dynamic result) async{
    if(mounted && _overlayStateNotifier.isShowingOverlay) {
      _overlayStateNotifier.remove();
    } else if(await _controller?.canGoBack() == true) {
      await _controller?.goBack();
    }
  }

  Future<void> _onWebViewCreated(InAppWebViewController controller) async{
    /*await controller.loadUrl(urlRequest: widget.action.request);*/
    setState(() => _controller = controller);
  }

  Future<void> _onCloseWindow(InAppWebViewController controller) async {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: _onPopInvokedWithResult,
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(_title ?? ""),
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
          actions: [
            CloseButton(
                onPressed: _closeWindow
            )
          ],
        ),
        body: SafeArea(
          child: InAppWebView(
            keepAlive: InAppWebViewKeepAlive(),
            windowId: widget.action.windowId,
            initialSettings: InAppWebViewSettings(
                applicationNameForUserAgent: USERAGENT,
                javaScriptEnabled: true,
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
                mediaPlaybackRequiresUserGesture: true,
                interceptOnlyAsyncAjaxRequests: true,
                useShouldInterceptAjaxRequest: true
            ),
            onTitleChanged: _onTitleChanged,
            onWebViewCreated: _onWebViewCreated,
            onCloseWindow: _onCloseWindow,
            onPermissionRequest: _onPermissionRequest,
            onReceivedHttpError: _onReceivedHttpError,
            onReceivedError: _onReceivedError,
            onWebContentProcessDidTerminate: _onWebContentProcessDidTerminate,
            onAjaxProgress: _onAjaxProgress,
            onAjaxReadyStateChange: _onAjaxReadyStateChange,
            onLoadStart: _onLoadStart,
            onLoadStop: _onLoadStop,
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
          ),
        ),
      ),
    );
  }

  void _onTitleChanged(InAppWebViewController ctr, String? title) {
    if(mounted) setState(() => _title = title);
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController ctr, NavigationAction action) async {
    final WebUri? webUri = action.request.url;

    if(webUri != null) {
      final String url = webUri.toString();
      if(!webUri.scheme.startsWith("http")){
        if(mounted) _overlayStateNotifier.showIndicator(context, openURL(url));
        return NavigationActionPolicy.CANCEL;
      } else {
        return NavigationActionPolicy.ALLOW;
      }
    } else {
      return NavigationActionPolicy.CANCEL;
    }
  }

  void _closeWindow() async{
    await _controller?.evaluateJavascript(source: "window.close();");
  }

  void _onLoadStart(InAppWebViewController ctr, Uri? uri) {
    log(uri, title: "CURRENT_URL");
    if(IS_SHOW_OVERLAY && mounted) _overlayStateNotifier.show(context);
  }

  void _onLoadStop(InAppWebViewController ctr, Uri? uri) {
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
    log("STOP");
  }

  void _onReceivedHttpError(InAppWebViewController ctr, WebResourceRequest req, WebResourceResponse res) {
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
  }

  Future<PermissionResponse?> _onPermissionRequest(InAppWebViewController ctr, PermissionRequest req) async{
    return PermissionResponse(resources: req.resources, action: PermissionResponseAction.GRANT);
  }

  void _onReceivedError(InAppWebViewController ctr, WebResourceRequest req, WebResourceError err) {
    log(err, title: "ERROR");
    final WebResourceErrorType type = err.type;
    if(type == WebResourceErrorType.NOT_CONNECTED_TO_INTERNET) {
      showToast("인터넷 연결이 필요합니다.");
    }
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
  }

  void _onWebContentProcessDidTerminate(InAppWebViewController ctr) {
    ctr.reload();
  }

  Future<AjaxRequestAction> _onAjaxProgress(InAppWebViewController ctr, AjaxRequest request) {
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.show(context);
    return Future.value(AjaxRequestAction.PROCEED);
  }

  Future<AjaxRequestAction> _onAjaxReadyStateChange(InAppWebViewController ctr, AjaxRequest request) {
    if(IS_SHOW_OVERLAY) _overlayStateNotifier.remove();
    return Future.value(AjaxRequestAction.PROCEED);
  }
}
