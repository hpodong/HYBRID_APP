import 'package:HYBRID_APP/customs/custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;

  final Function()? onTap;

  final double height;
  final double fontSize;

  final Color color;
  final Color textColor;
  final Color? borderColor;

  final double borderRadius;

  final EdgeInsetsGeometry padding;

  final FontWeight fontWeight;

  const PrimaryButton({
    required this.text,
    required this.onTap,
    this.height = 50,
    this.fontSize = 15,
    this.color = CustomColors.main,
    this.textColor = Colors.white,
    this.borderColor,
    this.borderRadius = 8,
    this.padding = EdgeInsets.zero,
    this.fontWeight = FontWeight.w500,
    super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      disabledColor: Colors.grey,
      borderRadius: _borderRadius,
      padding: const EdgeInsets.all(0),
      minSize: 0,
      color: color,
      onPressed: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
            border: borderColor == null ? null : Border.all(color: borderColor!),
            borderRadius: _borderRadius
        ),
        child: SizedBox(
          height: height,
          child: Center(child: Text(text, style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor
          ))),
        ),
      ),
    );
  }

  BorderRadius get _borderRadius => BorderRadius.circular(borderRadius);
}
