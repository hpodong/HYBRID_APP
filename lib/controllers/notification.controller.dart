import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '../configs/config/config.dart';
import '../utills/common.dart';
import 'inapp-web.controller.dart';

class NotificationController extends ChangeNotifier{

  static NotificationController get instance => NotificationController();
  static NotificationController of(BuildContext context) => context.read<NotificationController>();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  set fcmToken(String? token){
    _fcmToken = token;
    notifyListeners();
    log("fcmToken: $_fcmToken");
  }

  Future setFcmToken() async{
    return _fcm.getToken().then((token) {
      fcmToken = token;
    }).catchError((error) {
      throw Exception(error);
    });
  }

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final DarwinNotificationDetails _iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
  );

  AndroidNotificationChannel _androidChannel() => AndroidNotificationChannel(
      ANDROID_CHANNEL_ID,
      ANDROID_CHANNEL_NAME,
      description: ANDROID_CHANNEL_DESCRIPTION,
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

  Future<void> firebasePushSetting() async{
    await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel());
  }

  Future<void> firebasePushListener(BuildContext context) async{
    log("LISTENING FIREBASE PUSH");
    final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true
    );

    String desc = '';
    // FirebaseMessaging.instance.subscribeToTopic("all");
    switch(settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        _localNotifications.initialize(_settings,
            onDidReceiveNotificationResponse: (res) => _onTapNotification(context, res.payload)
        );
        desc = '허용됨';
        final NotificationAppLaunchDetails? details = await _localNotifications.getNotificationAppLaunchDetails();
        if(details?.didNotificationLaunchApp == true && context.mounted) {
          _onTapNotification(context, details?.notificationResponse?.payload);
        }
        final RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
        if(message != null && context.mounted) {
          _onTapNotification(context, message.data.isEmpty ? null : jsonEncode(message.data));
        }
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if(context.mounted) _notificationHandler(context, message);
        });
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          if(context.mounted) _onTapNotification(context, message.data.isEmpty ? "" : jsonEncode(message.data));
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
    log("알림 액세스: $desc");
  }

  void _notificationHandler(BuildContext context, RemoteMessage rm) {

    FlutterAppBadger.removeBadge();

    final RemoteNotification? notification = rm.notification;
    final AndroidNotification? android = notification?.android;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        ANDROID_CHANNEL_ID,
        ANDROID_CHANNEL_NAME,
        channelDescription: ANDROID_CHANNEL_DESCRIPTION,
        priority: Priority.high,
        importance: Importance.max,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: Colors.white,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: _iosDetails
    );

    log('message: ${rm.data}');

    if(notification != null && android != null) {
      if(rm.data["send_time"] != null) {
        final DateTime? dt = DateTime.tryParse(rm.data["send_time"]);

        if(dt != null) {
          final tz.TZDateTime tzdt = tz.TZDateTime.parse(tz.local, dt.toIso8601String());
          final Map<String, dynamic> data = rm.data;
          data["send_time"] = null;
          final String payload = jsonEncode(data);
          _localNotifications.zonedSchedule(notification.hashCode, notification.title, notification.body, tzdt, notificationDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, payload: payload);
        }
      } else {
        _localNotifications.show(notification.hashCode, notification.title, notification.body, notificationDetails, payload: rm.data.isEmpty ? null : jsonEncode(rm.data));
      }
    }
  }

  void _onTapNotification(BuildContext context, String? payload) async{

    FlutterAppBadger.removeBadge();

    log('payload: $payload');

    if(payload != null && payload.isNotEmpty){
      final Map<String, dynamic> json = jsonDecode(payload);
      final String? url = json['url'];
      if(url != null && url.isNotEmpty) {
        final Uri uri = Uri.parse(url);
        await InAppWebController.of(context).webViewCtr.loadUrl(urlRequest: URLRequest(url: WebUri(url), body: utf8.encode(jsonEncode(uri.queryParameters))));
      }
    }
  }
}