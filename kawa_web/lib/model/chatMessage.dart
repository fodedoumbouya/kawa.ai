// Message model to store chat messages
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime created;
  final DateTime updated;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.created,
    required this.updated,
  });
}
