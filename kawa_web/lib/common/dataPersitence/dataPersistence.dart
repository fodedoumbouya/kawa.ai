import 'dart:io';

import 'package:kawa_web/model/enum.dart';
import 'package:kawa_web/model/generated/apiSettingModel.dart';
import 'package:kawa_web/model/generated/user.dart';

import 'spUtil.dart';

class DataPersistence {
  DataPersistence._();

  static const String _ACCOUNT = 'account';
  static const String _LANGUAGE = 'language';
  static const String modelAPiSetting = 'model_api_setting';

  static Future<void>? deleteAll() {
    return SpUtil.clear();
  }

  static Future<void>? deleteAccount() {
    return SpUtil.remove(_ACCOUNT);
  }

  static Future<void>? deleteLanguage() {
    return SpUtil.remove(_LANGUAGE);
  }

  static UserModel? getAccount() {
    if (SpUtil.getString(_ACCOUNT) == null ||
        SpUtil.getString(_ACCOUNT)!.isEmpty) {
      return null;
    } else {
      return UserModelMapper.fromJson(SpUtil.getString(_ACCOUNT)!);
    }
  }

  static Future<void>? saveAccount(UserModel account) {
    return SpUtil.putString(_ACCOUNT, account.toJson());
  }

  static Lang getLanguage() {
    final lang = SpUtil.getString(_LANGUAGE, defValue: Platform.localeName) ??
        Platform.localeName;
    if (lang.contains('fr')) {
      return Lang.fr_FR;
    } else if (lang.contains('en')) {
      return Lang.en_US;
    } else {
      return Lang.none;
    }
  }

  static Future<void> putLanguage(Lang lang) async {
    await SpUtil.putString(_LANGUAGE, lang.name);
  }

  static Future<void>? saveApiSetting(ApiSettingModel apiSetting) {
    return SpUtil.putString(modelAPiSetting, apiSetting.toJson());
  }

  static ApiSettingModel? getApiSetting() {
    if (SpUtil.getString(modelAPiSetting) == null ||
        SpUtil.getString(modelAPiSetting)!.isEmpty) {
      return null;
    } else {
      return ApiSettingModelMapper.fromJson(SpUtil.getString(modelAPiSetting)!);
    }
  }
}
