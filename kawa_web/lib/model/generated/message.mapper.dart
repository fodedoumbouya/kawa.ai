// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'message.dart';

class MessageMapper extends ClassMapperBase<Message> {
  MessageMapper._();

  static MessageMapper? _instance;
  static MessageMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageMapper._());
      ChatMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Message';

  static String _$id(Message v) => v.id;
  static const Field<Message, String> _f$id = Field('id', _$id);
  static String _$role(Message v) => v.role;
  static const Field<Message, String> _f$role = Field('role', _$role);
  static String _$content(Message v) => v.content;
  static const Field<Message, String> _f$content = Field('content', _$content);
  static Chat _$chat(Message v) => v.chat;
  static const Field<Message, Chat> _f$chat = Field('chat', _$chat);
  static String _$created(Message v) => v.created;
  static const Field<Message, String> _f$created = Field('created', _$created);
  static String _$updated(Message v) => v.updated;
  static const Field<Message, String> _f$updated = Field('updated', _$updated);

  @override
  final MappableFields<Message> fields = const {
    #id: _f$id,
    #role: _f$role,
    #content: _f$content,
    #chat: _f$chat,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Message _instantiate(DecodingData data) {
    return Message(
        id: data.dec(_f$id),
        role: data.dec(_f$role),
        content: data.dec(_f$content),
        chat: data.dec(_f$chat),
        created: data.dec(_f$created),
        updated: data.dec(_f$updated));
  }

  @override
  final Function instantiate = _instantiate;

  static Message fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Message>(map);
  }

  static Message fromJson(String json) {
    return ensureInitialized().decodeJson<Message>(json);
  }
}

mixin MessageMappable {
  String toJson() {
    return MessageMapper.ensureInitialized()
        .encodeJson<Message>(this as Message);
  }

  Map<String, dynamic> toMap() {
    return MessageMapper.ensureInitialized()
        .encodeMap<Message>(this as Message);
  }

  MessageCopyWith<Message, Message, Message> get copyWith =>
      _MessageCopyWithImpl(this as Message, $identity, $identity);
  @override
  String toString() {
    return MessageMapper.ensureInitialized().stringifyValue(this as Message);
  }

  @override
  bool operator ==(Object other) {
    return MessageMapper.ensureInitialized()
        .equalsValue(this as Message, other);
  }

  @override
  int get hashCode {
    return MessageMapper.ensureInitialized().hashValue(this as Message);
  }
}

extension MessageValueCopy<$R, $Out> on ObjectCopyWith<$R, Message, $Out> {
  MessageCopyWith<$R, Message, $Out> get $asMessage =>
      $base.as((v, t, t2) => _MessageCopyWithImpl(v, t, t2));
}

abstract class MessageCopyWith<$R, $In extends Message, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ChatCopyWith<$R, Chat, Chat> get chat;
  $R call(
      {String? id,
      String? role,
      String? content,
      Chat? chat,
      String? created,
      String? updated});
  MessageCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MessageCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Message, $Out>
    implements MessageCopyWith<$R, Message, $Out> {
  _MessageCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Message> $mapper =
      MessageMapper.ensureInitialized();
  @override
  ChatCopyWith<$R, Chat, Chat> get chat =>
      $value.chat.copyWith.$chain((v) => call(chat: v));
  @override
  $R call(
          {String? id,
          String? role,
          String? content,
          Chat? chat,
          String? created,
          String? updated}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (role != null) #role: role,
        if (content != null) #content: content,
        if (chat != null) #chat: chat,
        if (created != null) #created: created,
        if (updated != null) #updated: updated
      }));
  @override
  Message $make(CopyWithData data) => Message(
      id: data.get(#id, or: $value.id),
      role: data.get(#role, or: $value.role),
      content: data.get(#content, or: $value.content),
      chat: data.get(#chat, or: $value.chat),
      created: data.get(#created, or: $value.created),
      updated: data.get(#updated, or: $value.updated));

  @override
  MessageCopyWith<$R2, Message, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MessageCopyWithImpl($value, $cast, t);
}
