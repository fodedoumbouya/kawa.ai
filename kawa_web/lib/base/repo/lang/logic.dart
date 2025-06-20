import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/localization/strings.dart';
import 'package:kawa_web/model/enum.dart';

import '../../baseStateNotifier.dart';

final langProvider = StateNotifierProvider<LangNotifier, TransText?>((_) {
  return LangNotifier();
});

class LangNotifier extends BaseStateNotifier<TransText?> {
  LangNotifier() : super(TransText(newLang: Lang.fr_FR));

  TransText get getTransText => state ?? TransText(newLang: getSystemLang());

  setLang({required Lang newLang}) {
    state = TransText(newLang: newLang);
    // DataPersistence.putLanguage(newLang);
  }

  Lang getSystemLang() {
    final lang = Platform.localeName;
    if (lang.contains('fr')) {
      return Lang.fr_FR;
    } else if (lang.contains('en')) {
      return Lang.en_US;
    } else {
      return Lang.none;
    }
  }
}
