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
      "os": Platform.isAndroid ? "AOS" : "IOS"
    };
    return Request.post('${getUrl()}/api/app/version/check.php', body: body);
  }
}