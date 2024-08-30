import 'package:flutter_naver_login/flutter_naver_login.dart';

import '../../utills/common.dart';

class NaverConfig {

  Future<NaverAccountResult?> login({NaverAccessToken? refreshTokens}) => _currentToken.then((tokens) {
    final String accessToken = refreshTokens?.accessToken ?? tokens.accessToken;
    log("ACCESS TOKEN : $accessToken");
    if(accessToken.isNotEmpty) {
      if(refreshTokens?.isValid() == true) {
        return _currentAccount;
      } else {
        return _refreshToken;
      }
    } else {
      return _login();
    }
  });

  Future<void> logout() async{
    final NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;
    if(token.accessToken.isNotEmpty) await FlutterNaverLogin.logOut();
  }

  Future<NaverAccountResult?> _login() async{
    final NaverLoginResult result = await FlutterNaverLogin.logIn();
    log("NAVER LOGIN STATUS: ${result.status}");
    switch(result.status) {
      case NaverLoginStatus.error :
        log("ERROR MESSAGE: ${result.errorMessage}");
        return null;
      case NaverLoginStatus.cancelledByUser: return null;
      case NaverLoginStatus.loggedIn: return result.account;
    }
  }

  Future<NaverAccountResult?> get _currentAccount async{
    final NaverAccountResult user = await FlutterNaverLogin.currentAccount();
    if(user.id.isEmpty) {
      return null;
    } else {
      return user;
    }
  }

  Future<NaverAccessToken> get _currentToken => FlutterNaverLogin.currentAccessToken;

  Future<NaverAccountResult?> get _refreshToken => FlutterNaverLogin.refreshAccessTokenWithRefreshToken()
      .then((tokens) => login(refreshTokens: tokens));

  bool _tokenValidator(String expiresAt){
    final DateTime expiredAt = DateTime.fromMicrosecondsSinceEpoch(int.parse(expiresAt));
    final DateTime now = DateTime.now();
    return now.isBefore(expiredAt);
  }
}