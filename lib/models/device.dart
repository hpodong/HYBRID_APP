import 'package:equatable/equatable.dart';

class Device extends Equatable {

  final String deviceId;
  final String deviceCode;
  final String deviceType;

  const Device(this.deviceId, this.deviceCode, this.deviceType);

  @override
  List<Object?> get props => [deviceId, deviceCode, deviceType];
}