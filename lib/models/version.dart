import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Version extends Equatable {

  final String version;
  final int buildNumber;

  const Version({
    required this.version,
    required this.buildNumber,
  });

  factory Version.fromInfo(PackageInfo info) {
    return Version(
        version: info.version,
        buildNumber: int.parse(info.buildNumber)
    );
  }

  @override
  List<Object?> get props => [];
}