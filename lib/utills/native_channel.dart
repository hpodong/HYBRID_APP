import 'package:HYBRID_APP/utills/common.dart';
import 'package:flutter/services.dart';

class NativeChannel {

  const NativeChannel._();

  static const MethodChannel _CHANNEL = MethodChannel("method_channel");

  static Future<String?> getBundle(String key) {
    log(key, title: "KEY");
    return _CHANNEL.invokeMethod("getBundle", key);
  }
}