// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'apiSettingModel.dart';

class ModelTypeMapper extends EnumMapper<ModelType> {
  ModelTypeMapper._();

  static ModelTypeMapper? _instance;
  static ModelTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ModelTypeMapper._());
    }
    return _instance!;
  }

  static ModelType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ModelType decode(dynamic value) {
    switch (value) {
      case 'Gemini':
        return ModelType.Gemini;
      case 'Mistral':
        return ModelType.Mistral;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ModelType self) {
    switch (self) {
      case ModelType.Gemini:
        return 'Gemini';
      case ModelType.Mistral:
        return 'Mistral';
    }
  }
}

extension ModelTypeMapperExtension on ModelType {
  String toValue() {
    ModelTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ModelType>(this) as String;
  }
}

class ApiSettingModelMapper extends ClassMapperBase<ApiSettingModel> {
  ApiSettingModelMapper._();

  static ApiSettingModelMapper? _instance;
  static ApiSettingModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ApiSettingModelMapper._());
      ModelTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ApiSettingModel';

  static ModelType _$model_host(ApiSettingModel v) => v.model_host;
  static const Field<ApiSettingModel, ModelType> _f$model_host =
      Field('model_host', _$model_host);
  static List<String> _$model_list(ApiSettingModel v) => v.model_list;
  static const Field<ApiSettingModel, List<String>> _f$model_list =
      Field('model_list', _$model_list);
  static String? _$model_name(ApiSettingModel v) => v.model_name;
  static const Field<ApiSettingModel, String> _f$model_name =
      Field('model_name', _$model_name, opt: true);
  static String? _$api_key(ApiSettingModel v) => v.api_key;
  static const Field<ApiSettingModel, String> _f$api_key =
      Field('api_key', _$api_key, opt: true);

  @override
  final MappableFields<ApiSettingModel> fields = const {
    #model_host: _f$model_host,
    #model_list: _f$model_list,
    #model_name: _f$model_name,
    #api_key: _f$api_key,
  };

  static ApiSettingModel _instantiate(DecodingData data) {
    return ApiSettingModel(
        model_host: data.dec(_f$model_host),
        model_list: data.dec(_f$model_list),
        model_name: data.dec(_f$model_name),
        api_key: data.dec(_f$api_key));
  }

  @override
  final Function instantiate = _instantiate;

  static ApiSettingModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ApiSettingModel>(map);
  }

  static ApiSettingModel fromJson(String json) {
    return ensureInitialized().decodeJson<ApiSettingModel>(json);
  }
}

mixin ApiSettingModelMappable {
  String toJson() {
    return ApiSettingModelMapper.ensureInitialized()
        .encodeJson<ApiSettingModel>(this as ApiSettingModel);
  }

  Map<String, dynamic> toMap() {
    return ApiSettingModelMapper.ensureInitialized()
        .encodeMap<ApiSettingModel>(this as ApiSettingModel);
  }

  ApiSettingModelCopyWith<ApiSettingModel, ApiSettingModel, ApiSettingModel>
      get copyWith => _ApiSettingModelCopyWithImpl(
          this as ApiSettingModel, $identity, $identity);
  @override
  String toString() {
    return ApiSettingModelMapper.ensureInitialized()
        .stringifyValue(this as ApiSettingModel);
  }

  @override
  bool operator ==(Object other) {
    return ApiSettingModelMapper.ensureInitialized()
        .equalsValue(this as ApiSettingModel, other);
  }

  @override
  int get hashCode {
    return ApiSettingModelMapper.ensureInitialized()
        .hashValue(this as ApiSettingModel);
  }
}

extension ApiSettingModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ApiSettingModel, $Out> {
  ApiSettingModelCopyWith<$R, ApiSettingModel, $Out> get $asApiSettingModel =>
      $base.as((v, t, t2) => _ApiSettingModelCopyWithImpl(v, t, t2));
}

abstract class ApiSettingModelCopyWith<$R, $In extends ApiSettingModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get model_list;
  $R call(
      {ModelType? model_host,
      List<String>? model_list,
      String? model_name,
      String? api_key});
  ApiSettingModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _ApiSettingModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ApiSettingModel, $Out>
    implements ApiSettingModelCopyWith<$R, ApiSettingModel, $Out> {
  _ApiSettingModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ApiSettingModel> $mapper =
      ApiSettingModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get model_list =>
      ListCopyWith($value.model_list, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(model_list: v));
  @override
  $R call(
          {ModelType? model_host,
          List<String>? model_list,
          Object? model_name = $none,
          Object? api_key = $none}) =>
      $apply(FieldCopyWithData({
        if (model_host != null) #model_host: model_host,
        if (model_list != null) #model_list: model_list,
        if (model_name != $none) #model_name: model_name,
        if (api_key != $none) #api_key: api_key
      }));
  @override
  ApiSettingModel $make(CopyWithData data) => ApiSettingModel(
      model_host: data.get(#model_host, or: $value.model_host),
      model_list: data.get(#model_list, or: $value.model_list),
      model_name: data.get(#model_name, or: $value.model_name),
      api_key: data.get(#api_key, or: $value.api_key));

  @override
  ApiSettingModelCopyWith<$R2, ApiSettingModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ApiSettingModelCopyWithImpl($value, $cast, t);
}
