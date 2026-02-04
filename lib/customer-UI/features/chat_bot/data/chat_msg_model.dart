class ChatMessage {
  final String? id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString(),
      text: json['content'] ?? json['message'] ?? '', 
      isUser: json['role'] == 'user' || json['sender_type'] == 'user',
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}