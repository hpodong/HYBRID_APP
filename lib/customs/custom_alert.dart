part of 'custom.dart';

class CustomAlert {

  static const String _cancelText = '아니오';
  static const String _acceptText = '예';
  static const String _confirmText = '확인';

  static void alert(
      final BuildContext context,
      final String? title,
      final String? desc,
      final Function()? onTap
      ) {
    if(Platform.isAndroid) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => _androidAlertDialog(context, title ?? '알림', desc, onTap));
    } else {
      showCupertinoDialog(context: context, barrierDismissible: false, builder: (context) => _iosAlertDialog(context, title ?? '알림', desc, onTap));
    }
  }

  static AlertDialog _androidAlertDialog(BuildContext context, String title, String? desc, Function()? onTap) {
    return AlertDialog(
      title: Text(title),
      content: desc == null ? null : Text(desc),
      actions: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.pop();
              if(onTap != null) onTap();
            },
            child: const Text(_confirmText, style: TextStyle(color: CustomColors.main, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  static CupertinoAlertDialog _iosAlertDialog(BuildContext context, String title, String? desc, Function()? onTap) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: desc == null ? null : Text(desc),
      actions: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.pop();
              if(onTap != null) onTap();
            },
            child: const Text(_confirmText)
        ),
      ],
    );
  }

  static void confirm(
      final BuildContext context,
      final String title,
      final String? desc,
      final Function(bool result) onSelected, {
        final bool focusCancel = true,
      }
      ) {

    final FontWeight cancelWeight = focusCancel ? FontWeight.bold : FontWeight.w200;
    final FontWeight acceptWeight = focusCancel ? FontWeight.w200 : FontWeight.bold;

    if(Platform.isAndroid) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => _androidConfirmDialog(title, desc, context, cancelWeight, onSelected, acceptWeight));
    } else {
      showCupertinoDialog(context: context, barrierDismissible: false, builder: (context) => _iosConfirmDialog(title, desc, context, cancelWeight, onSelected, acceptWeight));
    }
  }

  static CupertinoAlertDialog _iosConfirmDialog(String title, String? desc, BuildContext context, FontWeight cancelWeight, Function(bool result) onSelected, FontWeight acceptWeight) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: desc == null ? null : Text(desc),
      actions: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              context.pop();
              onSelected(false);
            },
            child: const Text(_cancelText)
        ),
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              onSelected(true);
              context.pop();
            },
            child: const Text(_acceptText)
        ),
      ],
    );
  }

  static AlertDialog _androidConfirmDialog(String title, String? desc, BuildContext context, FontWeight cancelWeight, Function(bool result) onSelected, FontWeight acceptWeight) {
    return AlertDialog(
      title: Text(title),
      content: desc == null ? null : Text(desc),
      actions: [
        TextButton(
            onPressed: () {
              context.pop();
              onSelected(false);
            },
            child: const Text(_cancelText, style: TextStyle(color: CustomColors.main))
        ),
        TextButton(
            onPressed: () {
              onSelected(true);
              context.pop();
            },
            child: const Text(_acceptText, style: TextStyle(color: CustomColors.main, fontWeight: FontWeight.bold))
        )
      ],
    );
  }
}
