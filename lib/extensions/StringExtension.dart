extension Stringextension on String {
  String insertZwj() {
    return replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
  }
}