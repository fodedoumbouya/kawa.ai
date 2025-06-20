import 'package:dart_mappable/dart_mappable.dart';

part 'project.mapper.dart';

@MappableClass()
class Project with ProjectMappable {
  final String id;
  final String projectName;
  final Map<String, dynamic> projectStructure;
  final String routers;
  final String user;
  final String created;
  final String updated;
  Project({
    required this.id,
    required this.projectName,
    required this.projectStructure,
    required this.routers,
    required this.user,
    required this.created,
    required this.updated,
  });
}
