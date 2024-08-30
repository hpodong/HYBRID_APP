import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

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

Future<void> openURL(String url, {
  LaunchMode mode = LaunchMode.platformDefault
}) {
  return launchUrl(Uri.parse(url), mode: mode);
}

Future permissionCheck(List<Permission> permissions) async{
  permissions.request().then((statuses) {
    String message = "";
    for(final Permission permission in permissions) {
      message += "$permission: ${statuses[permission]}\n";
    }
    debugPrint(message);
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
  Object? error,
  PrettyPrinter? printer,
  LogType type = LogType.info
}) {
  if(!kReleaseMode) {
    final Logger logger = Logger(
        printer: printer ?? PrettyPrinter(
            methodCount: 0
        )
    );
    switch(type) {
      case LogType.info:
        logger.i(message, error: error);
        break;
      case LogType.debug:
        logger.d(message, error: error);
        break;
      case LogType.error:
        logger.e(message, error: error);
    }
  }
}
