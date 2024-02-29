import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utills/enums.dart';

class Config {

  static Config get instance => Config();

  final String HOST_NAME = dotenv.get('HOST_NAME');
  final String API_KEY = dotenv.get("API_KEY");
  // final String BASE_API = dotenv.get('BASE_API');
  // final String PACKAGE_NAME = dotenv.get('PACKAGE_NAME');
  final String APP_STORE_ID = dotenv.get('APP_STORE_ID');

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
}