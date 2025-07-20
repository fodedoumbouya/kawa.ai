import 'dart:io';

import 'package:kawa_web/model/generated/apiSettingModel.dart';
import 'package:kawa_web/model/generated/user.dart';

import 'spUtil.dart';

class DataPersistence {
  DataPersistence._();

  static const String _ACCOUNT = 'account';
  static const String modelAPiSetting = 'model_api_setting';

  static Future<void>? deleteAll() {
    return SpUtil.clear();
  }

  static Future<void>? deleteAccount() {
    return SpUtil.remove(_ACCOUNT);
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
