import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utills/enums.dart';

final String HOST_NAME = dotenv.get('HOST_NAME');
final String API_KEY = dotenv.get("API_KEY");
final bool USE_SSL = dotenv.get("USE_SSL") == "1";
final String PORT = dotenv.get("PORT");
final String APP_STORE_ID = dotenv.get('APP_STORE_ID');
final String LOGIN_PAGE = dotenv.get('LOGIN_PAGE');
final String LOGOUT_PAGE = dotenv.get('LOGOUT_PAGE');
final String _USERAGENT = dotenv.get('USERAGENT');
final String ANDROID_CHANNEL_ID = dotenv.get('ANDROID_CHANNEL_ID');
final String ANDROID_CHANNEL_NAME = dotenv.get('ANDROID_CHANNEL_NAME');
final String ANDROID_CHANNEL_DESCRIPTION = dotenv.get('ANDROID_CHANNEL_DESCRIPTION');
final String KAKAO_NATIVE_APP_KEY = dotenv.get('KAKAO_NATIVE_APP_KEY');
final String KAKAO_JAVASCRIPT_APP_KEY = dotenv.get('KAKAO_JAVASCRIPT_APP_KEY');
final String SPLASH_IMAGE = dotenv.get('SPLASH_IMAGE');
final String APPLE_CLIENT_ID = dotenv.get('APPLE_CLIENT_ID');
final String APPLE_LOGIN_CALLBACK = dotenv.get('APPLE_LOGIN_CALLBACK');
final String INITIAL_PATH = dotenv.get('INITIAL_PATH');
const double PADDING_VALUE = 20;

final bool VERSION_CHECK = bool.parse(dotenv.get('VERSION_CHECK'));
final bool IS_SHOW_OVERLAY = bool.parse(dotenv.get('IS_SHOW_OVERLAY'));

String get USERAGENT => Platform.isAndroid ? "${_USERAGENT}_ANDROID" : "${_USERAGENT}_IOS";

class Config {

  static Config get instance => Config();

  Future SET_TOKEN(TokenType tokenType, String? jwt) async{

    final SharedPreferences spf = await SharedPreferences.getInstance();
    if(jwt != null){
      return spf.setString(tokenType.name, jwt);
    }
  }

  Future REMOVE_TOKEN(TokenType tokenType) async{
    final SharedPreferences spf = await SharedPreferences.getInstance();
    if(await GET_TOKEN(tokenType) != null){
      spf.remove(tokenType.name);
    }
    return null;
  }

  Future<String?> GET_TOKEN(TokenType tokenType) async{
    final SharedPreferences spf = await SharedPreferences.getInstance();
    return spf.getString(tokenType.name);
  }

  Future<Map<String, String>> HEADERS({String? accessToken, bool isFormData = false}) async {
    accessToken = await GET_TOKEN(TokenType.accessToken);

    return {
      if(accessToken != null) HttpHeaders.authorizationHeader: 'Bearer $accessToken',
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
      HttpHeaders.connectionHeader: 'keep-alive',
      HttpHeaders.contentTypeHeader: isFormData ? 'multipart/form-data' : 'application/json'
    };
  }

  String getUrl([String? add_path]) {
    String url = "http://";
    if(USE_SSL) url = "https://";
    url += HOST_NAME;
    if(!USE_SSL) url += ":$PORT";
    if(add_path != null) url += add_path;
    return url;
  }
}