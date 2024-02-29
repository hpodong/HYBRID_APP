import '../configs/config/config.dart';
import '../configs/http.configs/http.config.dart';

class MemberRepo extends Config{

  static MemberRepo get instance => MemberRepo();

  Future<Response> reissueToken({
    String? accessToken,
    String? refreshToken
  }) async{
    final Map<String, dynamic> body = <String, dynamic>{
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
    return Request.post('', body: body);
  }

  Future<Response> updateFcmToken({
    required final String fcmToken,
    required final String deviceId,
    final String? userId,
    final String? socialId,
    final String? socialType
}) async{
    final Map<String, dynamic> body = <String, dynamic>{
      "fcm_token": fcmToken,
      "device_id": deviceId,
      if(userId != null) "user_id": userId,
      if(socialId != null)"social_id": socialId,
      if(socialType != null)"social_type": socialType,
    };
    return Request.post("", body: body);
  }
}