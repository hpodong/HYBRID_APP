import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../configs/config/config.dart';
import '../controllers/overlay.controller.dart';
import '../utills/common.dart';

class WindowPopupPage extends StatefulWidget {
  final CreateWindowAction action;
  final InAppWebViewSettings settings;
  const WindowPopupPage(this.action, this.settings, {super.key});

  @override
  State<WindowPopupPage> createState() => _WindowPopupPageState();
}

class _WindowPopupPageState extends State<WindowPopupPage> {

  String? _title;

  InAppWebViewController? _controller;
  late final OverlayController _overlayCtr = OverlayController.of(context);

  Future<void> _onPopInvokedWithResult(bool canPop, dynamic result) async{
    if(await _controller?.canGoBack() == true) {
      await _controller?.goBack();
    } else {
      if(mounted && Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  Future<void> _onWebViewCreated(InAppWebViewController controller) async{
    /*await controller.loadUrl(urlRequest: widget.action.request);*/
    setState(() => _controller = controller);
    log(widget.action.windowId, title: "WINDOW ID");
  }

  Future<void> _onCloseWindow(InAppWebViewController controller) async {
    log("", title: "CLOSE WINDOW");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text(_title ?? ""),
          actions: [
            CloseButton(
              onPressed: () {
                if(Navigator.canPop(context)) Navigator.pop(context);
              },
            )
          ],
        ),
        body: SafeArea(
          child: InAppWebView(
            windowId: widget.action.windowId,
            initialSettings: InAppWebViewSettings(
              applicationNameForUserAgent: USERAGENT,
              javaScriptEnabled: true,
              useHybridComposition: true,
              cacheMode: CacheMode.LOAD_DEFAULT,
              cacheEnabled: true,
              allowsBackForwardNavigationGestures: true,
            ),
            onTitleChanged: (ctr, title) => setState(() => _title = title),
            onWebViewCreated: _onWebViewCreated,
            onCloseWindow: _onCloseWindow,
            onLoadStart: (ctr, uri) {
              log(uri, title: "LOAD START");
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
        log(webUri.scheme, title: "SCHEME");
        if(mounted) OverlayController.of(context).showIndicator(context, openURL(url));
        return NavigationActionPolicy.CANCEL;
      } else {
        return NavigationActionPolicy.ALLOW;
      }
    } else {
      return NavigationActionPolicy.CANCEL;
    }
  }
}
