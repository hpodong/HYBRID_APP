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
            ),
            onTitleChanged: (ctr, title) {
              if(mounted) setState(() => _title = title);
            },
            onWebViewCreated: _onWebViewCreated,
            onCloseWindow: _onCloseWindow,
            onLoadStart: (ctr, uri) {
              _overlayStateNotifier.show(context);
            },
            onLoadStop: (ctr, uri) => _overlayStateNotifier.remove(),
            onReceivedHttpError: (ctr, req, err) => _overlayStateNotifier.remove(),
            onReceivedError: (ctr, req, err) => _overlayStateNotifier.remove(),
            shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
          ),
        ),
      ),
    );
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
}
