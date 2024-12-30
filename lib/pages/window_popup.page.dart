import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../configs/config/config.dart';
import '../controllers/overlay.controller.dart';
import '../utills/common.dart';

class WindowPopupPage extends StatefulWidget {
  final CreateWindowAction action;
  const WindowPopupPage(this.action, {super.key});

  @override
  State<WindowPopupPage> createState() => _WindowPopupPageState();
}

class _WindowPopupPageState extends State<WindowPopupPage> {

  String? _title;

  InAppWebViewController? _controller;
  late final OverlayController _overlayCtr = OverlayController.of(context);

  Future<void> _onPopInvokedWithResult(bool canPop, dynamic result) async{
    if(mounted && _overlayCtr.entry != null) {
      _overlayCtr.remove();
    } else if(await _controller?.canGoBack() == true) {
      await _controller?.goBack();
    } else {
      if(mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  Future<void> _onWebViewCreated(InAppWebViewController controller) async{
    /*await controller.loadUrl(urlRequest: widget.action.request);*/
    setState(() => _controller = controller);
  }

  Future<void> _onCloseWindow(InAppWebViewController controller) async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(_title ?? ""),
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
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
              allowsBackForwardNavigationGestures: true,
            ),
            onTitleChanged: (ctr, title) {
              if(mounted) setState(() => _title = title);
            },
            onWebViewCreated: _onWebViewCreated,
            onCloseWindow: _onCloseWindow,
            onLoadStart: (ctr, uri) {
              _overlayCtr.show(context);
            },
            onLoadStop: (ctr, uri) => _overlayCtr.remove(),
            onReceivedHttpError: (ctr, req, err) => _overlayCtr.remove(),
            onReceivedError: (ctr, req, err) => _overlayCtr.remove(),
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
        if(mounted) OverlayController.of(context).showIndicator(context, openURL(url));
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
