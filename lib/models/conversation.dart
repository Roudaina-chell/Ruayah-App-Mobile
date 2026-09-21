import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id; // نفس userId ديال العميل
  final String userName;
  final String userPhone;
  final String lastMessage;
  final DateTime lastMessageAt;
  final bool hasUnreadForAdmin;
  final bool hasUnreadForClient;

  Conversation({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.hasUnreadForAdmin,
    required this.hasUnreadForClient,
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt:
          (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasUnreadForAdmin: map['hasUnreadForAdmin'] ?? false,
      hasUnreadForClient: map['hasUnreadForClient'] ?? false,
    );
  }
}