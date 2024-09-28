import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'enums.dart';

double mediaHeight(BuildContext context, double scale) {
  final double deviceHeight = scale / 844;
  return MediaQuery.of(context).size.height * deviceHeight;
}
double mediaWidth(BuildContext context, double scale) {
  final double deviceWidth = scale / 390;
  return MediaQuery.of(context).size.width * deviceWidth;
}
double basePadding(BuildContext context) => mediaWidth(context, 15);

const MethodChannel platform = MethodChannel('method_channel');

EdgeInsets baseAllPadding(BuildContext context) => EdgeInsets.all(basePadding(context));

Future<dynamic> movePage(BuildContext context, Widget page, {
  String? routeName,
  Object? arguments,
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) async{

  settings = RouteSettings(name: routeName, arguments: arguments);

  return Navigator.push(context, MaterialPageRoute(builder: (context) => page, settings: settings, maintainState: maintainState, fullscreenDialog: fullscreenDialog));
}

Future<dynamic> movePageToNamed(BuildContext context, String routeName, {
  Object? arguments
}) async{
  return Navigator.pushNamed(context, routeName, arguments: arguments);
}

Future permissionCheck(List<Permission> permissions) async{
  permissions.request().then((statuses) {
    String message = "";
    for(final Permission permission in permissions) {
      message += "$permission: ${statuses[permission]}\n";
    }
    log(message);
  });
}

Future showToast(final String msg, {
  Toast toastLength = Toast.LENGTH_LONG,
  double fontSize = 14,
  ToastGravity? gravity,
  Color? backgroundColor,
  Color? textColor
}) async{
  return Fluttertoast.cancel().whenComplete(() => Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      fontSize: fontSize,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor
  ));
}

void log(dynamic message, {
  String? title,
  Object? error,
  PrettyPrinter? printer,
  LogType type = LogType.info,
  bool showRelease = false
}) {
  if(!kReleaseMode || showRelease) {
    final DateTime now = DateTime.now();
    final Logger logger = Logger(
        printer: printer ?? PrettyPrinter(
            methodCount: 0
        )
    );
    final StringBuffer sb = StringBuffer();
    if(title != null) sb.write("[$title] ");
    sb.write(message);
    sb.write("\n[$now]");
    switch(type) {
      case LogType.info:
        logger.i(sb, error: error);
        break;
      case LogType.debug:
        logger.d(sb, error: error);
        break;
      case LogType.error:
        logger.e(sb, error: error);
    }
  }
}

Future<void> openURL(String url) async {
  final bool canLaunch = await canLaunchUrlString(url);
  final Uri uri = Uri.parse(url);
  if(Platform.isIOS) {
    if (canLaunch) await launchUrl(uri);
  } else {
    try {
      final String? packageName = await getPackageName(url);
      log(packageName, title: "PACKAGE NAME");
      switch(packageName) {
        case "kvp.jjy.MispAndroid320":
          url = url.replaceAll(uri.host, uri.host.toUpperCase());
      }
      log(url, title: "OPEN URL");
      await platform.invokeMethod('openURL', {'url': url});
    } catch(e) {
      switch(uri.scheme) {
        case "kftc-bankpay":
          await launchUrlString("https://play.google.com/store/apps/details?id=com.kftc.bankpay.android&hl=ko");
          break;
        case "mg-bankpay":
          await launchUrlString("https://play.google.com/store/apps/details?id=kr.co.kfcc.mobilebank&hl=ko");
          break;
        case "newliiv":
          await launchUrlString("https://play.google.com/store/apps/details?id=com.kbstar.reboot&hl=ko");
          break;
        case "kn-bankpay":
          await launchUrlString("https://play.google.com/store/apps/details?id=com.knb.psb&hl=ko");
          break;
        case "nhb-bankpay":
          await launchUrlString("https://play.google.com/store/apps/details?id=com.nh.cashcardapp&hl=ko");
      }
    }
  }
}

Future<String?> getPackageName(String url) async{
  try {
    return platform.invokeMethod('getPackage', {'url': url});
  } catch(e) {
    return null;
  }
}