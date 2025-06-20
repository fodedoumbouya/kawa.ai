// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'appPath.dart';

class AppPathMapper extends ClassMapperBase<AppPath> {
  AppPathMapper._();

  static AppPathMapper? _instance;
  static AppPathMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppPathMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AppPath';

  static String _$id(AppPath v) => v.id;
  static const Field<AppPath, String> _f$id = Field('id', _$id);
  static String _$name(AppPath v) => v.name;
  static const Field<AppPath, String> _f$name = Field('name', _$name);
  static String _$path(AppPath v) => v.path;
  static const Field<AppPath, String> _f$path = Field('path', _$path);
  static bool _$isSelected(AppPath v) => v.isSelected;
  static const Field<AppPath, bool> _f$isSelected =
      Field('isSelected', _$isSelected, opt: true, def: false);
  static String? _$imgPath(AppPath v) => v.imgPath;
  static const Field<AppPath, String> _f$imgPath =
      Field('imgPath', _$imgPath, opt: true);
  static String? _$initPrompt(AppPath v) => v.initPrompt;
  static const Field<AppPath, String> _f$initPrompt =
      Field('initPrompt', _$initPrompt, opt: true);

  @override
  final MappableFields<AppPath> fields = const {
    #id: _f$id,
    #name: _f$name,
    #path: _f$path,
    #isSelected: _f$isSelected,
    #imgPath: _f$imgPath,
    #initPrompt: _f$initPrompt,
  };

  static AppPath _instantiate(DecodingData data) {
    return AppPath(
        id: data.dec(_f$id),
        name: data.dec(_f$name),
        path: data.dec(_f$path),
        isSelected: data.dec(_f$isSelected),
        imgPath: data.dec(_f$imgPath),
        initPrompt: data.dec(_f$initPrompt));
  }

  @override
  final Function instantiate = _instantiate;

  static AppPath fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AppPath>(map);
  }

  static AppPath fromJson(String json) {
    return ensureInitialized().decodeJson<AppPath>(json);
  }
}

mixin AppPathMappable {
  String toJson() {
    return AppPathMapper.ensureInitialized()
        .encodeJson<AppPath>(this as AppPath);
  }

  Map<String, dynamic> toMap() {
    return AppPathMapper.ensureInitialized()
        .encodeMap<AppPath>(this as AppPath);
  }

  AppPathCopyWith<AppPath, AppPath, AppPath> get copyWith =>
      _AppPathCopyWithImpl(this as AppPath, $identity, $identity);
  @override
  String toString() {
    return AppPathMapper.ensureInitialized().stringifyValue(this as AppPath);
  }

  @override
  bool operator ==(Object other) {
    return AppPathMapper.ensureInitialized()
        .equalsValue(this as AppPath, other);
  }

  @override
  int get hashCode {
    return AppPathMapper.ensureInitialized().hashValue(this as AppPath);
  }
}

extension AppPathValueCopy<$R, $Out> on ObjectCopyWith<$R, AppPath, $Out> {
  AppPathCopyWith<$R, AppPath, $Out> get $asAppPath =>
      $base.as((v, t, t2) => _AppPathCopyWithImpl(v, t, t2));
}

abstract class AppPathCopyWith<$R, $In extends AppPath, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? id,
      String? name,
      String? path,
      bool? isSelected,
      String? imgPath,
      String? initPrompt});
  AppPathCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AppPathCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AppPath, $Out>
    implements AppPathCopyWith<$R, AppPath, $Out> {
  _AppPathCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AppPath> $mapper =
      AppPathMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? name,
          String? path,
          bool? isSelected,
          Object? imgPath = $none,
          Object? initPrompt = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (path != null) #path: path,
        if (isSelected != null) #isSelected: isSelected,
        if (imgPath != $none) #imgPath: imgPath,
        if (initPrompt != $none) #initPrompt: initPrompt
      }));
  @override
  AppPath $make(CopyWithData data) => AppPath(
      id: data.get(#id, or: $value.id),
      name: data.get(#name, or: $value.name),
      path: data.get(#path, or: $value.path),
      isSelected: data.get(#isSelected, or: $value.isSelected),
      imgPath: data.get(#imgPath, or: $value.imgPath),
      initPrompt: data.get(#initPrompt, or: $value.initPrompt));

  @override
  AppPathCopyWith<$R2, AppPath, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AppPathCopyWithImpl($value, $cast, t);
}
