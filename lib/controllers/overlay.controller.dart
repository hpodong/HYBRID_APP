import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverlayController extends ChangeNotifier {
  static OverlayController of(BuildContext context) => context.read<OverlayController>();

  OverlayEntry? _entry;
  OverlayEntry? get entry => _entry;
  set entry(OverlayEntry? entry) {
    _entry = entry;
    notifyListeners();
  }

  static Widget _buildIndicator(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withOpacity(0.3),
      child: Center(
          child: Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator()
      ),
    );
  }

  Future<T> showIndicator<T>(BuildContext context, Future<T> future) {
    remove();

    entry = OverlayEntry(builder: _buildIndicator);

    OverlayState? overlayState = Overlay.of(context);

    if(entry != null) overlayState.insert(entry!);

    return future.then((result) {
      return result;
    }).catchError((error) {
      throw Exception(error);
    }).whenComplete(() {
      remove();
    });
  }

  void showOverlayWidget(BuildContext context, Widget Function(BuildContext) builder) {
    remove();

    entry = OverlayEntry(builder: builder);

    OverlayState? overlayState = Overlay.of(context);

    if(entry != null) overlayState.insert(entry!);
  }

  void remove() {
    entry?.remove();
    entry = null;
  }

  void show(BuildContext context) {

    remove();

    entry = OverlayEntry(builder: _buildIndicator);

    final OverlayState overlayState = Overlay.of(context);

    if(entry != null) overlayState.insert(entry!);
  }
}