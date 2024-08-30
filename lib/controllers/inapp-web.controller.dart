import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

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
}