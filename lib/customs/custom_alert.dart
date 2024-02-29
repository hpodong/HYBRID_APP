part of 'custom.dart';

class CustomAlert {

  static final TextStyle _titleStyle = CustomTextStyle.title();
  static final TextStyle _descStyle = CustomTextStyle.classic();

  static const String _cancelText = '아니오';
  static const String _acceptText = '예';
  static const String _confirmText = '확인';

  static const Color _androidButtonColor = Colors.blue;
  static const Color _iosButtonColor = CupertinoColors.activeBlue;

  static void alert(
      final BuildContext context,
      final String? title,
      final String? desc,
  {
    final Function()? onTap
  }
      ) {
    if(Platform.isAndroid) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => _androidAlertDialog(context, title ?? '알림', desc, onTap));
    } else {
      showCupertinoDialog(context: context, barrierDismissible: false, builder: (context) => _iosAlertDialog(context, title ?? '알림', desc, onTap));
    }
  }

  static AlertDialog _androidAlertDialog(BuildContext context, String title, String? desc, Function()? onTap) {
    return AlertDialog(
      title: title == null ? null : Text(title, style: _titleStyle),
      content: desc == null ? null : Text(desc, style: _descStyle),
      actions: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
              if(onTap != null) onTap();
            },
            child: Text(_confirmText, style: CustomTextStyle.classic(color: _androidButtonColor, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  static CupertinoAlertDialog _iosAlertDialog(BuildContext context, String title, String? desc, Function()? onTap) {
    return CupertinoAlertDialog(
      title: title == null ? null : Text(title, style: _titleStyle),
      content: desc == null ? null : Text(desc),
      actions: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
              if(onTap != null) onTap();
            },
            child: Text(_confirmText, style: CustomTextStyle.classic(color: _iosButtonColor, fontWeight: FontWeight.bold))
        ),
      ],
    );
  }

  static void confirm(
      final BuildContext context,
      final String title,
      final String? desc,
      final Function() onSelected, {
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

  static CupertinoAlertDialog _iosConfirmDialog(String title, String? desc, BuildContext context, FontWeight cancelWeight, onSelected(), FontWeight acceptWeight) {
    return CupertinoAlertDialog(
      title: title == null ? null : Text(title, style: _titleStyle),
      content: desc == null ? null : Text(desc, style: _descStyle),
      actions: [
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(_cancelText, style: CustomTextStyle.classic(color: _iosButtonColor, fontWeight: cancelWeight))
        ),
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              onSelected();
              Navigator.pop(context);
            },
            child: Text(_acceptText, style: CustomTextStyle.classic(color: _iosButtonColor, fontWeight: acceptWeight))
        ),
      ],
    );
  }

  static AlertDialog _androidConfirmDialog(String title, String? desc, BuildContext context, FontWeight cancelWeight, onSelected(), FontWeight acceptWeight) {
    return AlertDialog(
      title: title == null ? null : Text(title, style: _titleStyle),
      content: desc == null ? null : Text(desc, style: _descStyle),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_cancelText, style: CustomTextStyle.classic(fontWeight: cancelWeight, color: _androidButtonColor))
        ),
        TextButton(
            onPressed: () {
              onSelected();
              Navigator.pop(context);
            },
            child: Text(_acceptText, style: CustomTextStyle.classic(fontWeight: acceptWeight, color: _androidButtonColor))
        )
      ],
    );
  }
}
