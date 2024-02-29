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
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3)
      ),
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(),
    );
  }

  Future<T> showIndicator<T>(BuildContext context, Future<T> future) {

    entry = OverlayEntry(builder: _buildIndicator);

    OverlayState? overlayState = Overlay.of(context);

    if(entry != null) overlayState.insert(entry!);

    return future.then((result) {
      removeOverlay();
      return result;
    }).catchError((error) {
      removeOverlay();
      throw Exception(error);
    });
  }

  void showOverlayWidget(BuildContext context, Widget Function(BuildContext) builder) {

    entry = OverlayEntry(builder: builder);

    OverlayState? overlayState = Overlay.of(context);

    if(entry != null) overlayState.insert(entry!);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }
}