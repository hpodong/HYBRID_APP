import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:toyou/utills/common.dart';

import 'inapp-web.controller.dart';

class NotificationController extends ChangeNotifier{

  static NotificationController get instance => NotificationController();
  static NotificationController of(BuildContext context) => context.read<NotificationController>();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  set fcmToken(String? token){
    _fcmToken = token;
    notifyListeners();
    debugPrint("fcmToken: $_fcmToken");
  }

  Future setFcmToken() async{
    return _fcm.getToken().then((token) {
      fcmToken = token;
    }).catchError((error) {
      throw Exception(error);
    });
  }

  final String _ANDROID_CHANNEL_ID = dotenv.get('ANDROID_CHANNEL_ID');
  final String _ANDROID_CHANNEL_NAME = dotenv.get('ANDROID_CHANNEL_NAME');
  final String _ANDROID_CHANNEL_DESCRIPTION = dotenv.get('ANDROID_CHANNEL_DESCRIPTION');

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final DarwinNotificationDetails _iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
  );

  AndroidNotificationChannel _androidChannel() => AndroidNotificationChannel(
      _ANDROID_CHANNEL_ID,
      _ANDROID_CHANNEL_NAME,
      description: _ANDROID_CHANNEL_DESCRIPTION,
      importance: Importance.max
  );

  final AndroidInitializationSettings _androidSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher');

  final DarwinInitializationSettings _iosSettings = const DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  InitializationSettings get _settings =>
      InitializationSettings(
        android: _androidSettings,
        iOS: _iosSettings,
      );

  void firebasePushSetting() {
    _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );
    _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel());
  }

  void firebasePushListener(BuildContext context) {
    log("LISTENING FIREBASE PUSH");
    _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true
    ).then((settings) {
      String desc = '';
      // FirebaseMessaging.instance.subscribeToTopic("all");
      switch(settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          _localNotifications.initialize(_settings,
              onDidReceiveNotificationResponse: (res) => _onTapNotification(context, res.payload)
          );
          desc = '허용됨';
          _localNotifications.getNotificationAppLaunchDetails().then((details) {
            if(details?.didNotificationLaunchApp == true) {
              _onTapNotification(context, details?.notificationResponse?.payload);
            }
          });
          FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
            if(message != null) {
              debugPrint('getInitialMessage');
              _onTapNotification(context, message.data.isEmpty ? null : jsonEncode(message.data));
            }
          });
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            debugPrint('onMessage');
            _notificationHandler(context, message);
          });
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            debugPrint('onMessageOpenedApp');
            _onTapNotification(context, message.data.isEmpty ? "" : jsonEncode(message.data));
          });
          break;
        case AuthorizationStatus.denied:
          desc = '허용되지 않음';
          break;
        case AuthorizationStatus.notDetermined:
          desc = '결정되지 않음';
          break;
        case AuthorizationStatus.provisional:
          desc = '임시로 허용됨';
      }
      debugPrint("알림 액세스: $desc");
    });
  }

  void _notificationHandler(BuildContext context, RemoteMessage rm) {

    FlutterAppBadger.removeBadge();

    final RemoteNotification? notification = rm.notification;
    final AndroidNotification? android = notification?.android;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _ANDROID_CHANNEL_ID,
        _ANDROID_CHANNEL_NAME,
        channelDescription: _ANDROID_CHANNEL_DESCRIPTION,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Colors.white,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: _iosDetails
    );

    debugPrint('message: ${rm.data}');

    if(notification != null && android != null) {
      _localNotifications.show(notification.hashCode, notification.title, notification.body, notificationDetails, payload: rm.data.isEmpty ? null : jsonEncode(rm.data));
    }
  }

  void _onTapNotification(BuildContext context, String? payload) {

    FlutterAppBadger.removeBadge();

    debugPrint('payload: $payload');

    if(payload != null && payload.isNotEmpty){
      final Map<String, dynamic> json = jsonDecode(payload);
      final String? url = json['url'];
      if(url != null && url.isNotEmpty) InAppWebController.of(context).webViewCtr.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    }
  }
}