part of 'custom.dart';

class CustomOverlay{

  static CustomOverlay get instance => CustomOverlay();

  static Widget _buildIndicator(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3)
      ),
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(),
    );
  }

  static Future<T> indicator<T>(BuildContext context, Future<T> future) {

    final OverlayEntry overlayEntry = OverlayEntry(builder: _buildIndicator);

    OverlayState? overlayState = Overlay.of(context);

    overlayState.insert(overlayEntry);

    return future.then((result) {
      overlayEntry.remove();
      return result;
    }).catchError((error) {
      overlayEntry.remove();
    });
  }

  static OverlayEntry showWidget(BuildContext context, Widget Function(BuildContext) builder) {

    final OverlayEntry overlayEntry = OverlayEntry(builder: builder);

    OverlayState? overlayState = Overlay.of(context);

    overlayState.insert(overlayEntry);

    return overlayEntry;
  }
}