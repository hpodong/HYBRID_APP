import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:toyou/utills/common.dart';


class KakaoConfig {

  static String NATIVE_APP_KEY = dotenv.get("KAKAO_NATIVE_APP_KEY");
  static String JAVASCRIPT_KEY = dotenv.get("KAKAO_JAVASCRIPT_APP_KEY");

  static Future<void> init() async {
    KakaoSdk.init(
      nativeAppKey: NATIVE_APP_KEY,
      javaScriptAppKey: JAVASCRIPT_KEY
    );
  }

  Future<User?> login() async{
    OAuthToken? token;
    final bool isInstalled = await isKakaoTalkInstalled();
    if(isInstalled) {
      token = await _mobileLogin();
    } else {
      token = await _webLogin();
    }

    if(token == null) {
      return null;
    } else {
      return _kakaoUser;
    }
  }

  Future<void> logout() async{
    try {
      final AccessTokenInfo token = await UserApi.instance.accessTokenInfo();
      if(token.id != null) await UserApi.instance.logout();
    } on KakaoClientException catch (e) {
      if(e.msg.isNotEmpty) {
        debugPrint(e.msg);
      }
    }
  }

  Future<OAuthToken?> _webLogin() async{
    OAuthToken? token;
    try {
      token = await UserApi.instance.loginWithKakaoAccount();
    } on PlatformException catch(e) {
      if(e.code == "CANCELED") token = null;
    }
    if(token?.accessToken.isEmpty == true) {
      return null;
    } else {
      return token;
    }
  }

  Future<OAuthToken?> _mobileLogin() async{
    OAuthToken? token;
    try {
      token = await UserApi.instance.loginWithKakaoTalk();
    } on PlatformException catch (e) {
      if(e.code == "NotSupportError") {
        token = await _webLogin();
      } else if(e.code == "CANCELED") {
        token = null;
      }
    }
    if(token?.accessToken.isEmpty == true) {
      return null;
    } else {
      return token;
    }
  }

  Future<User?> get _kakaoUser async{
    try{
      final AccessTokenInfo info = await UserApi.instance.accessTokenInfo();
      log("KAKAO INFO: $info");

      if(info.id == null) {
        return null;
      } else {
        return UserApi.instance.me();
      }
    } catch (e) {
      return null;
    }
  }
}