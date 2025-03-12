import 'package:equatable/equatable.dart';

class WebviewXY extends Equatable{
  final int x;
  final int y;

  final DateTime clickedAt;

  const WebviewXY(this.x, this.y, this.clickedAt);

  @override
  List<Object?> get props => [x, y, clickedAt];
}