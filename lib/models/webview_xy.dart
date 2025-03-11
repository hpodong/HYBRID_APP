import 'package:equatable/equatable.dart';

class WebviewXY extends Equatable{
  final int x;
  final int y;

  const WebviewXY(this.x, this.y);

  @override
  List<Object?> get props => [x, y];
}