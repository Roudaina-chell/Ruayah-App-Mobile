import 'package:cloud_firestore/cloud_firestore.dart';

class CaseEntry {
  final String id;
  final String authorRole; // "client" | "admin"
  final String text;
  final DateTime createdAt;

  CaseEntry({
    required this.id,
    required this.authorRole,
    required this.text,
    required this.createdAt,
  });

  factory CaseEntry.fromMap(String id, Map<String, dynamic> map) {
    return CaseEntry(
      id: id,
      authorRole: map['authorRole'] ?? 'client',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}