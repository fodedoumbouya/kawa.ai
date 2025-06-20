import 'package:dart_mappable/dart_mappable.dart';
import 'package:kawa_web/model/generated/project.dart';

part 'chat.mapper.dart';

@MappableClass()
class Chat with ChatMappable {
  final String id;
  final String title;
  final Project project;
  final String created;
  final String updated;
  Chat({
    required this.id,
    required this.title,
    required this.project,
    required this.created,
    required this.updated,
  });
}
