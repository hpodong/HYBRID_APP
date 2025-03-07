import 'dart:isolate';

class IsolateHelper<T>{

  final void Function(SendPort sendPort) function;
  final void Function(T? data)? onReceived;

  bool _isExecute = false;

  IsolateHelper(this.function, {
    this.onReceived,
  }) {
    _execute();
  }

  void _execute() {
    if(_isExecute) return;
    _isExecute = true;
    final ReceivePort receivePort = ReceivePort();

    Isolate.spawn(function, receivePort.sendPort);

    receivePort.listen((data) {
      if(onReceived != null) onReceived!(data as T?);
      _isExecute = false;
      receivePort.close();
    });
  }
}