part of "http.config.dart";

class Request {

  static final Config _config = Config();

  static Future<Response> post(String suffix, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    Map<String, List<File>>? files,
    String? accessToken,
    bool hasToken = true,
    RequestType type = RequestType.POST
  }) async {
    final HttpClient client = HttpClient();
    String url;
    if (suffix.startsWith("http")) {
      url = suffix;
    } else {
      url = "${_config.HOST_NAME}$suffix";
    }
    accessToken ??= await _config.GET_TOKEN(TokenType.accessToken);
    if (params != null && params.isNotEmpty) {
      final StringBuffer sb = StringBuffer();
      for (int index = 0; index < params.length; index++) {
        final String key = params.keys.map((e) => e).toList()[index];
        final dynamic value = params[key];
        if (index == 0) {
          sb.write("?");
        } else if (index < params.length) {
          sb.write("&");
        }
        sb.write(key);
        sb.write("=");
        sb.write(value);
      }
      url += sb.toString();
    }
    final Uri uri = Uri.parse(url);
    try {
      final HttpClientRequest req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, "*/*");
      req.headers.set(HttpHeaders.acceptEncodingHeader, "gzip, deflate, br");
      req.headers.set(HttpHeaders.connectionHeader, "keep-alive");
      req.headers.set("x-api-key", _config.API_KEY);
      if (accessToken != null && hasToken) req.headers.set(
          HttpHeaders.authorizationHeader, "Bearer $accessToken");
      switch (type) {
        case RequestType.GET:
        case RequestType.POST:
          req.headers.contentType =
              ContentType("application", "json", charset: "UTF-8");
          final String encodeBody = jsonEncode(body);
          final Uint8List encodeBytes = Uint8List.fromList(
              utf8.encode(encodeBody));
          req.contentLength = encodeBytes.length;
          if (headers != null) {
            for (String key in headers.keys) {
              final String? value = headers[key];
              if (value != null) req.headers.set(key, value);
            }
          }
          req.add(encodeBytes);
          log(
              "🐶🐶🐶🐶🐶Request Info🐶🐶🐶🐶🐶\nurl: $url\nbody: $encodeBody\nheaders: ${req
                  .headers}");
          break;

        case RequestType.MULTIPART:
          return _responseFromFormData(uri, body, files, headers, accessToken, hasToken: hasToken);
      }

      final HttpClientResponse res = await req.close();
      switch (res.statusCode) {
        case 403:
          final String? at = await _reissueToken();
          if (at != null) {
            return post(suffix, headers: headers,
                body: body,
                params: params,
                hasToken: hasToken,
                accessToken: at);
          }
      }
      return Response.fromHttp(res);
    } on ArgumentError catch (e) {
      if (e.message.toString().contains("No host specified in URI")) {
        return Response(
            statusCode: 404, message: "존재하지 않는 URI 주소입니다.", error: e.message);
      }
    } on SocketException catch (e) {
      log("message", error: e.message, type: LogType.info);
      return Response(statusCode: null, error: e.message);
    }
    return Response(statusCode: null, message: ErrorMessages.unknown);
  }

  static Future<String?> _reissueToken() async {
    const TokenType at = TokenType.accessToken;
    const TokenType rt = TokenType.refreshToken;
    final Response res = await Request.post("REISSUE_TOKEN", body: {
      rt.name: await _config.GET_TOKEN(rt)
    });
    final String? accessToken = res.data[at.name];
    switch (res.statusCode) {
      case 200:
        await _config.SET_TOKEN(at, res.data[at.name]);
        await _config.SET_TOKEN(rt, res.data[rt.name]);
    }
    return accessToken;
  }

  static Future<Response> _responseFromFormData(Uri uri, Map<String, dynamic>? body, Map<String, List<File>>? files, Map<String, String>? headers, String? accessToken,
      {bool hasToken = true}) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest("POST", uri);
      if(accessToken != null && hasToken) request.headers.addAll({HttpHeaders.authorizationHeader: "Bearer $accessToken"});
      request.headers.addAll({"x-api-key": _config.API_KEY});
      if(headers != null) request.headers.addAll(headers);
      if(body != null) for (final String key in body.keys) {
        final String? value = body[key]?.toString();
        if (value != null) request.fields[key] = value;
      }
      print(request.headers);
      if (files != null) for (final String key in files.keys) {
        final List<File>? fileList = files[key];
        if (fileList != null) for (final File file in fileList) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      }
      final http.StreamedResponse res = await request.send();

      return Response.fromFormData(res).then((res) async{
        switch(res.statusCode) {
          case 403:
            final String? accessToken = await _reissueToken();
            if(accessToken != null) _responseFromFormData(uri, body, files, headers, accessToken, hasToken: hasToken);
        }
        return res;
      });
    } on ArgumentError catch (e) {
      log(e.name, error: e, type: LogType.error);
      return Response(statusCode: null, error: e.message);
    } on SocketException catch (e) {
      log(e.message, error: e.message, type: LogType.info);
      return Response(statusCode: null, error: e.message);
    }
  }
}