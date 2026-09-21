import 'package:cloud_firestore/cloud_firestore.dart';

class Program {
  final String id;
  final String title;
  final String shortDescription;
  final String content;
  final DateTime createdAt;

  Program({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Program.fromMap(String id, Map<String, dynamic> map) {
    return Program(
      id: id,
      title: map['title'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}