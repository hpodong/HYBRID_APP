part of 'custom.dart';

enum FontFamily{
  N_Light,
  N_Regular,
  N_Medium,
  N_Bold,
  N_Black,
  P_Light,
  P_Regular,
  P_Medium,
  P_Bold,
  BM
}

mixin CustomTextStyle on TextStyle{

  static String _stringFromFontFamily(FontFamily fontFamily){
    switch(fontFamily){
      case FontFamily.N_Light: return 'NotoSansKR_Light';
      case FontFamily.N_Regular: return 'NotoSansKR-Regular';
      case FontFamily.N_Medium: return 'NotoSansKR-Medium';
      case FontFamily.N_Bold: return 'NotoSansKR-Bold';
      case FontFamily.N_Black: return 'NotoSansKR-Black';
      case FontFamily.P_Light: return 'Poppins-Light';
      case FontFamily.P_Regular: return 'Poppins-Regular';
      case FontFamily.P_Medium: return 'Poppins-Medium';
      case FontFamily.P_Bold: return 'Poppins-Bold';
      case FontFamily.BM: return 'BM';
    }
  }

  static TextStyle classic({
    final double fontSize = 14,
    final FontFamily fontFamily = FontFamily.N_Medium,
    final Color color = CustomColors.black,
    final double? height,
    final TextDecoration decoration = TextDecoration.none,
    final double? letterSpacing,
    final double? wordSpacing,
    final FontWeight fontWeight = FontWeight.normal
  }) {
    return TextStyle(
        fontSize: fontSize,
        fontFamily: _stringFromFontFamily(fontFamily),
        color: color,
        height: height,
        fontWeight: fontWeight,
        decoration: decoration,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing
    );
  }

  static TextStyle title({
    final double fontSize = 16,
    final FontFamily fontFamily = FontFamily.N_Medium,
    final Color color = CustomColors.black,
    final double? height,
    final TextDecoration decoration = TextDecoration.none,
    final double? letterSpacing,
    final double? wordSpacing,
    final FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
        fontSize: fontSize,
        fontFamily: _stringFromFontFamily(fontFamily),
        color: color,
        height: height,
        fontWeight: fontWeight,
        decoration: decoration,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing
    );
  }

  static TextStyle appBarStyle(BuildContext context, {
    final double fontSize = 16,
    final FontFamily fontFamily = FontFamily.N_Medium,
    final Color? color,
    final double height = 0.0,
    final TextDecoration decoration = TextDecoration.none,
    final double? letterSpacing,
    final double? wordSpacing,
    final FontWeight fontWeight = FontWeight.bold
  }) {
    return Theme.of(context).appBarTheme.titleTextStyle!.copyWith(
        fontSize: fontSize,
        color: color,
        fontFamily: _stringFromFontFamily(fontFamily),
        height: height,
        decoration: decoration,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        fontWeight: fontWeight
    );
  }
}