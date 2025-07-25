import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

/// SharedPreferences Util.
class SpUtil {
  static SpUtil? _singleton;
  static SharedPreferencesWithCache? _prefs;
  static final Lock _lock = Lock();

  static Future<SpUtil?> getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          // keep local instance till it is fully initialized.P
          var singleton = SpUtil._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }

  SpUtil._();

  Future _init() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  /// put object.
  static Future<void>? putObject(String key, Object value) async {
    return await _prefs?.setString(key, json.encode(value));
  }

  /// get obj.
  static T? getObj<T>(String key, T Function(Map v) f, {T? defValue}) {
    Map? map = getObject(key);
    return map == null ? defValue : f(map);
  }

  /// get object.
  static Map? getObject(String key) {
    String? data = _prefs?.getString(key);
    return (data == null || data.isEmpty) ? null : json.decode(data);
  }

  /// put object list.
  static Future<void>? putObjectList(String key, List<Object> list) async {
    List<String>? dataList = list.map((value) {
      return json.encode(value);
    }).toList();
    return await _prefs?.setStringList(key, dataList);
  }

  /// get obj list.
  static List<T>? getObjList<T>(String key, T Function(Map v) f,
      {List<T>? defValue = const []}) {
    List<Map>? dataList = getObjectList(key);
    List<T>? list = dataList?.map((value) {
      return f(value);
    }).toList();
    return list ?? defValue;
  }

  /// get object list.
  static List<Map>? getObjectList(String key) {
    List<String>? dataLis = _prefs?.getStringList(key);
    return dataLis?.map((value) {
      Map dataMap = json.decode(value);
      return dataMap;
    }).toList();
  }

  /// get string.
  static String? getString(String key, {String? defValue = ''}) {
    return _prefs?.getString(key) ?? defValue;
  }

  /// put string.
  static Future<void>? putString(String key, String value) async {
    return await _prefs?.setString(key, value);
  }

  /// get bool.
  static bool? getBool(String key, {bool? defValue = false}) {
    return _prefs?.getBool(key) ?? defValue;
  }

  /// put bool.
  static Future<void>? putBool(String key, bool value) async {
    return await _prefs?.setBool(key, value);
  }

  /// get int.
  static int? getInt(String key, {int? defValue = 0}) {
    return _prefs?.getInt(key) ?? defValue;
  }

  /// put int.
  static Future<void>? putInt(String key, int value) async {
    return await _prefs?.setInt(key, value);
  }

  /// get double.
  static double? getDouble(String key, {double? defValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defValue;
  }

  /// put double.
  static Future<void>? putDouble(String key, double value) async {
    return _prefs?.setDouble(key, value);
  }

  /// get string list.
  static List<String>? getStringList(String key,
      {List<String>? defValue = const []}) {
    return _prefs?.getStringList(key) ?? defValue;
  }

  /// put string list.
  static Future<void>? putStringList(String key, List<String> value) {
    return _prefs?.setStringList(key, value);
  }

  /// get dynamic.
  static dynamic getDynamic(String key, {Object? defValue}) {
    return _prefs?.get(key) ?? defValue;
  }

  // /// have key.
  // static bool? haveKey(String key) {
  //   return _prefs?.getKeys().contains(key);
  // }

  /// contains Key.
  static bool? containsKey(String key) {
    return _prefs?.containsKey(key);
  }

  // /// get keys.
  // static Set<String>? getKeys() {
  //   return _prefs?.getKeys();
  // }

  /// remove.
  static Future<void>? remove(String key) async {
    return await _prefs?.remove(key);
  }

  /// clear.
  static Future<void>? clear() async {
    return await _prefs?.clear();
  }

  // /// Fetches the latest values from the host platform.
  // static Future<void>? reload() {
  //   return _prefs?.reload();
  // }

  ///Sp is initialized.
  static bool isInitialized() {
    return _prefs != null;
  }

  /// get Sp.
  static SharedPreferencesWithCache? getSp() {
    return _prefs;
  }
}
