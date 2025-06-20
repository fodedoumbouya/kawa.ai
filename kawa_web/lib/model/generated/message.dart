import 'package:dart_mappable/dart_mappable.dart';
import 'package:kawa_web/model/generated/chat.dart';
part 'message.mapper.dart';

@MappableClass()
class Message with MessageMappable {
  final String id;
  final String role;
  final String content;
  final Chat chat;
  final String created;
  final String updated;
  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.chat,
    required this.created,
    required this.updated,
  });
}
