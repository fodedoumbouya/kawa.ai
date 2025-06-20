import 'package:kawa_web/model/enum.dart';

import 'lang/en_US.dart';
import 'lang/fr_FR.dart';

class TransText {
  /// make this class on singleton
  static final TransText _instance = TransText._internal();
  late Lang lang;
  late Map<String, String> _translate;
  factory TransText({required Lang newLang}) {
    _instance.lang = newLang;
    if (_instance.lang == Lang.fr_FR) {
      _instance._translate = fr_FR;
    } else {
      _instance._translate = en_US;
    }
    return _instance;
  }

  TransText._internal();
  String get appName => _translate['appName'] ?? '';
}
