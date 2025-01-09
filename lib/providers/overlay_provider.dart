import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayProvider = StateNotifierProvider((ref) => OverlayStateNotifier());

class OverlayStateNotifier extends StateNotifier<OverlayEntry?> {
  OverlayStateNotifier(): super(null);

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

    state = OverlayEntry(builder: _buildIndicator);

    OverlayState? overlayState = Overlay.of(context);

    if(state != null) overlayState.insert(state!);

    return future.then((result) {
      return result;
    }).catchError((error) {
      throw Exception(error);
    }).whenComplete(() {
      remove();
    });
  }

  bool get isShowingOverlay => state != null;

  void showOverlayWidget(BuildContext context, Widget Function(BuildContext) builder) {
    remove();

    state = OverlayEntry(builder: builder);

    OverlayState? overlayState = Overlay.of(context);

    if(state != null) overlayState.insert(state!);
  }

  void remove() {
    state?.remove();
    state = null;
  }

  void show(BuildContext context) {

    remove();

    state = OverlayEntry(builder: _buildIndicator);

    final OverlayState overlayState = Overlay.of(context);

    if(state != null) overlayState.insert(state!);
  }
}