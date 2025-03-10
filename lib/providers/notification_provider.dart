import 'dart:convert';
import 'dart:io';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../configs/config/config.dart';
import '../utills/common.dart';
import '../utills/enums.dart';

final notificationProvider = StateNotifierProvider<FcmTokenStateNotifier, String?>((ref) => FcmTokenStateNotifier());

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

class NotificationNotifier extends ChangeNotifier{

  final Ref ref;

  NotificationNotifier(this.ref) {
    ref.listen(notificationProvider, (prev, next) {
      log(next, title: "FCM_TOKEN");
      if(prev != next) notifyListeners();
    });
    ref.read(notificationProvider.notifier).initialFcmToken();
  }
}

class FcmTokenStateNotifier extends StateNotifier<String?> {

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FcmTokenStateNotifier(): super(null);

  String? get fcmToken => state;

  Future<void> initialFcmToken() async {
    if(state != null) return;
    final SharedPreferences spf = await SharedPreferences.getInstance();
    state = spf.getString(TokenType.fcmToken.name);
    if(state == null) {
      try {
        if(Platform.isAndroid) {
          final String? token = await _fcm.getToken();
          if(token != null) _setFcmToken(token);
        } else {
          final String? token = await _fcm.getAPNSToken();
          if(token != null) _setFcmToken(token);
        }
      } catch (e) {
        await initialFcmToken();
      }
    }
    _fcm.onTokenRefresh.listen(_setFcmToken);
  }

  Future<void> _setFcmToken(String token) async {
    final SharedPreferences spf = await SharedPreferences.getInstance();
    if(await spf.setString(TokenType.fcmToken.name, token)) state = token;
  }

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

  Future<void> firebasePushListener(InAppWebViewController? ctr) async{
    /*final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true
    );*/

    if(await Permission.notification.isGranted) {
      log("LISTENING FIREBASE PUSH");
      _localNotifications.initialize(_settings,
          onDidReceiveNotificationResponse: (res) => _onTapNotification(ctr, res.payload)
      );
      final NotificationAppLaunchDetails? details = await _localNotifications.getNotificationAppLaunchDetails();
      if(details?.didNotificationLaunchApp == true) {
        _onTapNotification(ctr, details?.notificationResponse?.payload);
      }
      final RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
      if(message != null) {
        _onTapNotification(ctr, message.data.isEmpty ? null : jsonEncode(message.data));
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _notificationHandler(message);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _onTapNotification(ctr, message.data.isEmpty ? "" : jsonEncode(message.data));
      });
    }
  }

  void _notificationHandler(RemoteMessage rm) async{

    final RemoteNotification? notification = rm.notification;
    final AndroidNotification? android = notification?.android;

    log(android?.channelId, title: "CHANNEL");

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      android?.channelId ?? ANDROID_CHANNEL_ID,
      ANDROID_CHANNEL_NAME,
      channelDescription: ANDROID_CHANNEL_DESCRIPTION,
      priority: Priority.high,
      importance: Importance.max,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: Colors.white,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true
    );


    final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails
    );

    log(rm.data, title: "MESSAGE");

    if(notification != null && android != null) {
      await _localNotifications.show(notification.hashCode, notification.title, notification.body, notificationDetails, payload: rm.data.isEmpty ? null : jsonEncode(rm.data));
      await _updateBadge();
    }
  }

  Future<void> _updateBadge() async{
    final List<ActiveNotification> notifications = await _localNotifications.getActiveNotifications();
    await AppBadgePlus.updateBadge(notifications.length);
  }

  void _onTapNotification(InAppWebViewController? ctr, String? payload) async{
    log(payload, title: "PAYLOAD");
    await _updateBadge();
    if(payload != null && payload.isNotEmpty){
      final Map<String, dynamic> json = jsonDecode(payload);
      final String? url = json['url'];
      if(url != null && url.isNotEmpty) {
        final Uri uri = Uri.parse(url);
        await ctr?.loadUrl(urlRequest: URLRequest(url: WebUri(url), body: utf8.encode(jsonEncode(uri.queryParameters))));
      }
    }
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> firebasePushSetting() async{
    await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true
    );
    if(Platform.isAndroid) {
      await _createAndroidChannel(ANDROID_CHANNEL_ID, ANDROID_CHANNEL_NAME,
          description: ANDROID_CHANNEL_DESCRIPTION);
    }
  }

  Future<void> _createAndroidChannel(String id, String name, {
    String? description,
    Importance importance = Importance.max,
    String? groupId
  }) async{
    final AndroidNotificationChannel channel = AndroidNotificationChannel(id, name, description: description, importance: importance, groupId: groupId);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}