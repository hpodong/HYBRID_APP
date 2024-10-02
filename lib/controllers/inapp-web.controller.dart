import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../configs/config/config.dart';

class InAppWebController extends ChangeNotifier {
  static InAppWebController of(BuildContext context) => context.read<InAppWebController>();

  late InAppWebViewController _webViewCtr;

  InAppWebViewController get webViewCtr => _webViewCtr;

  set webViewCtr(InAppWebViewController webViewCtr){
    _webViewCtr = webViewCtr;
    notifyListeners();
  }

  bool _firstLoad = false;

  bool get firstLoad => _firstLoad;
  set firstLoad(bool firstLoad) {
    _firstLoad = firstLoad;
    notifyListeners();
  }

  Future<void> setCookie(String name, String value, {
    DateTime? expiredAt
  }) async {
    final CookieManager cm = CookieManager.instance();
    await cm.setCookie(url: WebUri.uri(Uri.parse(Config.instance.getUrl())), name: name, value: value, expiresDate: expiredAt?.millisecondsSinceEpoch);
  }
}