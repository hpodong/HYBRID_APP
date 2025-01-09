import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers/notification_provider.dart';

void main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  widgetsBinding;
  await dotenv.load(fileName: 'prod.env');
  await Firebase.initializeApp();
  await NotificationService.instance.firebasePushSetting();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const ProviderScope(child: (App())));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}