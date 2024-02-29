import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

import 'package:http/http.dart' as http;
import '../../utills/common.dart';
import '../../utills/enums.dart';
import '../../utills/error_message.dart';
import '../config/config.dart';

part "request.dart";
part "response.dart";

class HttpConfig extends Config{

}