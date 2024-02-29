import 'dart:io';

import '../configs/config/config.dart';
import '../configs/http.configs/http.config.dart';

class VersionRepo extends Config{

  static VersionRepo get instance => VersionRepo();

  Future<Response> versionCheck({
    required final String version,
    required final int buildNumber,
  }) async{
    final Map<String, dynamic> body = <String, dynamic>{
      "version": version.trim(),
      "build": buildNumber,
      "type": Platform.isAndroid ? 1 : 2,
      "os": Platform.isAndroid ? "AOS" : "IOS"
    };
    return Request.post('${getUrl()}/include/api/getAppVersion.php', body: body);
  }
}