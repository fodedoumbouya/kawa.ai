// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'project.dart';

class ProjectMapper extends ClassMapperBase<Project> {
  ProjectMapper._();

  static ProjectMapper? _instance;
  static ProjectMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProjectMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Project';

  static String _$id(Project v) => v.id;
  static const Field<Project, String> _f$id = Field('id', _$id);
  static String _$projectName(Project v) => v.projectName;
  static const Field<Project, String> _f$projectName =
      Field('projectName', _$projectName);
  static Map<String, dynamic> _$projectStructure(Project v) =>
      v.projectStructure;
  static const Field<Project, Map<String, dynamic>> _f$projectStructure =
      Field('projectStructure', _$projectStructure);
  static String _$routers(Project v) => v.routers;
  static const Field<Project, String> _f$routers = Field('routers', _$routers);
  static String _$user(Project v) => v.user;
  static const Field<Project, String> _f$user = Field('user', _$user);
  static String _$created(Project v) => v.created;
  static const Field<Project, String> _f$created = Field('created', _$created);
  static String _$updated(Project v) => v.updated;
  static const Field<Project, String> _f$updated = Field('updated', _$updated);

  @override
  final MappableFields<Project> fields = const {
    #id: _f$id,
    #projectName: _f$projectName,
    #projectStructure: _f$projectStructure,
    #routers: _f$routers,
    #user: _f$user,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Project _instantiate(DecodingData data) {
    return Project(
        id: data.dec(_f$id),
        projectName: data.dec(_f$projectName),
        projectStructure: data.dec(_f$projectStructure),
        routers: data.dec(_f$routers),
        user: data.dec(_f$user),
        created: data.dec(_f$created),
        updated: data.dec(_f$updated));
  }

  @override
  final Function instantiate = _instantiate;

  static Project fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Project>(map);
  }

  static Project fromJson(String json) {
    return ensureInitialized().decodeJson<Project>(json);
  }
}

mixin ProjectMappable {
  String toJson() {
    return ProjectMapper.ensureInitialized()
        .encodeJson<Project>(this as Project);
  }

  Map<String, dynamic> toMap() {
    return ProjectMapper.ensureInitialized()
        .encodeMap<Project>(this as Project);
  }

  ProjectCopyWith<Project, Project, Project> get copyWith =>
      _ProjectCopyWithImpl(this as Project, $identity, $identity);
  @override
  String toString() {
    return ProjectMapper.ensureInitialized().stringifyValue(this as Project);
  }

  @override
  bool operator ==(Object other) {
    return ProjectMapper.ensureInitialized()
        .equalsValue(this as Project, other);
  }

  @override
  int get hashCode {
    return ProjectMapper.ensureInitialized().hashValue(this as Project);
  }
}

extension ProjectValueCopy<$R, $Out> on ObjectCopyWith<$R, Project, $Out> {
  ProjectCopyWith<$R, Project, $Out> get $asProject =>
      $base.as((v, t, t2) => _ProjectCopyWithImpl(v, t, t2));
}

abstract class ProjectCopyWith<$R, $In extends Project, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
      get projectStructure;
  $R call(
      {String? id,
      String? projectName,
      Map<String, dynamic>? projectStructure,
      String? routers,
      String? user,
      String? created,
      String? updated});
  ProjectCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProjectCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Project, $Out>
    implements ProjectCopyWith<$R, Project, $Out> {
  _ProjectCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Project> $mapper =
      ProjectMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>
      get projectStructure => MapCopyWith(
          $value.projectStructure,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(projectStructure: v));
  @override
  $R call(
          {String? id,
          String? projectName,
          Map<String, dynamic>? projectStructure,
          String? routers,
          String? user,
          String? created,
          String? updated}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (projectName != null) #projectName: projectName,
        if (projectStructure != null) #projectStructure: projectStructure,
        if (routers != null) #routers: routers,
        if (user != null) #user: user,
        if (created != null) #created: created,
        if (updated != null) #updated: updated
      }));
  @override
  Project $make(CopyWithData data) => Project(
      id: data.get(#id, or: $value.id),
      projectName: data.get(#projectName, or: $value.projectName),
      projectStructure:
          data.get(#projectStructure, or: $value.projectStructure),
      routers: data.get(#routers, or: $value.routers),
      user: data.get(#user, or: $value.user),
      created: data.get(#created, or: $value.created),
      updated: data.get(#updated, or: $value.updated));

  @override
  ProjectCopyWith<$R2, Project, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProjectCopyWithImpl($value, $cast, t);
}
