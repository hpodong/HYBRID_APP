import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Device extends Equatable {

  final String version;
  final int buildNumber;

  const Device({
    required this.version,
    required this.buildNumber,
  });

  factory Device.fromInfo(PackageInfo info) {
    return Device(
        version: info.version,
        buildNumber: int.parse(info.buildNumber)
    );
  }

  @override
  List<Object?> get props => [];
}