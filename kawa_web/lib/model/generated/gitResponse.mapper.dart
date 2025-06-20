// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'gitResponse.dart';

class GitResponseMapper extends ClassMapperBase<GitResponse> {
  GitResponseMapper._();

  static GitResponseMapper? _instance;
  static GitResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GitResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GitResponse';

  static bool _$success(GitResponse v) => v.success;
  static const Field<GitResponse, bool> _f$success =
      Field('success', _$success);
  static String? _$message(GitResponse v) => v.message;
  static const Field<GitResponse, String> _f$message =
      Field('message', _$message, opt: true);
  static bool? _$canBackward(GitResponse v) => v.canBackward;
  static const Field<GitResponse, bool> _f$canBackward =
      Field('canBackward', _$canBackward, opt: true);
  static bool? _$canForward(GitResponse v) => v.canForward;
  static const Field<GitResponse, bool> _f$canForward =
      Field('canForward', _$canForward, opt: true);
  static String? _$currentState(GitResponse v) => v.currentState;
  static const Field<GitResponse, String> _f$currentState =
      Field('currentState', _$currentState, opt: true);

  @override
  final MappableFields<GitResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #canBackward: _f$canBackward,
    #canForward: _f$canForward,
    #currentState: _f$currentState,
  };

  static GitResponse _instantiate(DecodingData data) {
    return GitResponse(
        success: data.dec(_f$success),
        message: data.dec(_f$message),
        canBackward: data.dec(_f$canBackward),
        canForward: data.dec(_f$canForward),
        currentState: data.dec(_f$currentState));
  }

  @override
  final Function instantiate = _instantiate;

  static GitResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GitResponse>(map);
  }

  static GitResponse fromJson(String json) {
    return ensureInitialized().decodeJson<GitResponse>(json);
  }
}

mixin GitResponseMappable {
  String toJson() {
    return GitResponseMapper.ensureInitialized()
        .encodeJson<GitResponse>(this as GitResponse);
  }

  Map<String, dynamic> toMap() {
    return GitResponseMapper.ensureInitialized()
        .encodeMap<GitResponse>(this as GitResponse);
  }

  GitResponseCopyWith<GitResponse, GitResponse, GitResponse> get copyWith =>
      _GitResponseCopyWithImpl(this as GitResponse, $identity, $identity);
  @override
  String toString() {
    return GitResponseMapper.ensureInitialized()
        .stringifyValue(this as GitResponse);
  }

  @override
  bool operator ==(Object other) {
    return GitResponseMapper.ensureInitialized()
        .equalsValue(this as GitResponse, other);
  }

  @override
  int get hashCode {
    return GitResponseMapper.ensureInitialized().hashValue(this as GitResponse);
  }
}

extension GitResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GitResponse, $Out> {
  GitResponseCopyWith<$R, GitResponse, $Out> get $asGitResponse =>
      $base.as((v, t, t2) => _GitResponseCopyWithImpl(v, t, t2));
}

abstract class GitResponseCopyWith<$R, $In extends GitResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {bool? success,
      String? message,
      bool? canBackward,
      bool? canForward,
      String? currentState});
  GitResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GitResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GitResponse, $Out>
    implements GitResponseCopyWith<$R, GitResponse, $Out> {
  _GitResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GitResponse> $mapper =
      GitResponseMapper.ensureInitialized();
  @override
  $R call(
          {bool? success,
          Object? message = $none,
          Object? canBackward = $none,
          Object? canForward = $none,
          Object? currentState = $none}) =>
      $apply(FieldCopyWithData({
        if (success != null) #success: success,
        if (message != $none) #message: message,
        if (canBackward != $none) #canBackward: canBackward,
        if (canForward != $none) #canForward: canForward,
        if (currentState != $none) #currentState: currentState
      }));
  @override
  GitResponse $make(CopyWithData data) => GitResponse(
      success: data.get(#success, or: $value.success),
      message: data.get(#message, or: $value.message),
      canBackward: data.get(#canBackward, or: $value.canBackward),
      canForward: data.get(#canForward, or: $value.canForward),
      currentState: data.get(#currentState, or: $value.currentState));

  @override
  GitResponseCopyWith<$R2, GitResponse, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _GitResponseCopyWithImpl($value, $cast, t);
}
