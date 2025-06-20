import 'package:dart_mappable/dart_mappable.dart';
import 'package:kawa_web/model/generated/project.dart';

part 'user.mapper.dart';

@MappableClass()
class UserModel with UserModelMappable {
  final String id;
  final String? password;
  final String? tokenKey;
  final String email;
  final bool? emailVisibility;
  final bool? verified;
  final String? name;
  final String? avatar;
  final List<Project>? project;
  final String? created;
  final String? updated;
  UserModel({
    required this.id,
    required this.password,
    required this.tokenKey,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.name,
    required this.avatar,
    required this.project,
    required this.created,
    required this.updated,
  });
}
