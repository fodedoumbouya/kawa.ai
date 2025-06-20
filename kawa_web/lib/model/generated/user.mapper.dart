// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user.dart';

class UserModelMapper extends ClassMapperBase<UserModel> {
  UserModelMapper._();

  static UserModelMapper? _instance;
  static UserModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserModelMapper._());
      ProjectMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'UserModel';

  static String _$id(UserModel v) => v.id;
  static const Field<UserModel, String> _f$id = Field('id', _$id);
  static String? _$password(UserModel v) => v.password;
  static const Field<UserModel, String> _f$password =
      Field('password', _$password);
  static String? _$tokenKey(UserModel v) => v.tokenKey;
  static const Field<UserModel, String> _f$tokenKey =
      Field('tokenKey', _$tokenKey);
  static String _$email(UserModel v) => v.email;
  static const Field<UserModel, String> _f$email = Field('email', _$email);
  static bool? _$emailVisibility(UserModel v) => v.emailVisibility;
  static const Field<UserModel, bool> _f$emailVisibility =
      Field('emailVisibility', _$emailVisibility);
  static bool? _$verified(UserModel v) => v.verified;
  static const Field<UserModel, bool> _f$verified =
      Field('verified', _$verified);
  static String? _$name(UserModel v) => v.name;
  static const Field<UserModel, String> _f$name = Field('name', _$name);
  static String? _$avatar(UserModel v) => v.avatar;
  static const Field<UserModel, String> _f$avatar = Field('avatar', _$avatar);
  static List<Project>? _$project(UserModel v) => v.project;
  static const Field<UserModel, List<Project>> _f$project =
      Field('project', _$project);
  static String? _$created(UserModel v) => v.created;
  static const Field<UserModel, String> _f$created =
      Field('created', _$created);
  static String? _$updated(UserModel v) => v.updated;
  static const Field<UserModel, String> _f$updated =
      Field('updated', _$updated);

  @override
  final MappableFields<UserModel> fields = const {
    #id: _f$id,
    #password: _f$password,
    #tokenKey: _f$tokenKey,
    #email: _f$email,
    #emailVisibility: _f$emailVisibility,
    #verified: _f$verified,
    #name: _f$name,
    #avatar: _f$avatar,
    #project: _f$project,
    #created: _f$created,
    #updated: _f$updated,
  };

  static UserModel _instantiate(DecodingData data) {
    return UserModel(
        id: data.dec(_f$id),
        password: data.dec(_f$password),
        tokenKey: data.dec(_f$tokenKey),
        email: data.dec(_f$email),
        emailVisibility: data.dec(_f$emailVisibility),
        verified: data.dec(_f$verified),
        name: data.dec(_f$name),
        avatar: data.dec(_f$avatar),
        project: data.dec(_f$project),
        created: data.dec(_f$created),
        updated: data.dec(_f$updated));
  }

  @override
  final Function instantiate = _instantiate;

  static UserModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserModel>(map);
  }

  static UserModel fromJson(String json) {
    return ensureInitialized().decodeJson<UserModel>(json);
  }
}

mixin UserModelMappable {
  String toJson() {
    return UserModelMapper.ensureInitialized()
        .encodeJson<UserModel>(this as UserModel);
  }

  Map<String, dynamic> toMap() {
    return UserModelMapper.ensureInitialized()
        .encodeMap<UserModel>(this as UserModel);
  }

  UserModelCopyWith<UserModel, UserModel, UserModel> get copyWith =>
      _UserModelCopyWithImpl(this as UserModel, $identity, $identity);
  @override
  String toString() {
    return UserModelMapper.ensureInitialized()
        .stringifyValue(this as UserModel);
  }

  @override
  bool operator ==(Object other) {
    return UserModelMapper.ensureInitialized()
        .equalsValue(this as UserModel, other);
  }

  @override
  int get hashCode {
    return UserModelMapper.ensureInitialized().hashValue(this as UserModel);
  }
}

extension UserModelValueCopy<$R, $Out> on ObjectCopyWith<$R, UserModel, $Out> {
  UserModelCopyWith<$R, UserModel, $Out> get $asUserModel =>
      $base.as((v, t, t2) => _UserModelCopyWithImpl(v, t, t2));
}

abstract class UserModelCopyWith<$R, $In extends UserModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Project, ProjectCopyWith<$R, Project, Project>>? get project;
  $R call(
      {String? id,
      String? password,
      String? tokenKey,
      String? email,
      bool? emailVisibility,
      bool? verified,
      String? name,
      String? avatar,
      List<Project>? project,
      String? created,
      String? updated});
  UserModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserModel, $Out>
    implements UserModelCopyWith<$R, UserModel, $Out> {
  _UserModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserModel> $mapper =
      UserModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Project, ProjectCopyWith<$R, Project, Project>>?
      get project => $value.project != null
          ? ListCopyWith($value.project!, (v, t) => v.copyWith.$chain(t),
              (v) => call(project: v))
          : null;
  @override
  $R call(
          {String? id,
          Object? password = $none,
          Object? tokenKey = $none,
          String? email,
          Object? emailVisibility = $none,
          Object? verified = $none,
          Object? name = $none,
          Object? avatar = $none,
          Object? project = $none,
          Object? created = $none,
          Object? updated = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (password != $none) #password: password,
        if (tokenKey != $none) #tokenKey: tokenKey,
        if (email != null) #email: email,
        if (emailVisibility != $none) #emailVisibility: emailVisibility,
        if (verified != $none) #verified: verified,
        if (name != $none) #name: name,
        if (avatar != $none) #avatar: avatar,
        if (project != $none) #project: project,
        if (created != $none) #created: created,
        if (updated != $none) #updated: updated
      }));
  @override
  UserModel $make(CopyWithData data) => UserModel(
      id: data.get(#id, or: $value.id),
      password: data.get(#password, or: $value.password),
      tokenKey: data.get(#tokenKey, or: $value.tokenKey),
      email: data.get(#email, or: $value.email),
      emailVisibility: data.get(#emailVisibility, or: $value.emailVisibility),
      verified: data.get(#verified, or: $value.verified),
      name: data.get(#name, or: $value.name),
      avatar: data.get(#avatar, or: $value.avatar),
      project: data.get(#project, or: $value.project),
      created: data.get(#created, or: $value.created),
      updated: data.get(#updated, or: $value.updated));

  @override
  UserModelCopyWith<$R2, UserModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _UserModelCopyWithImpl($value, $cast, t);
}
