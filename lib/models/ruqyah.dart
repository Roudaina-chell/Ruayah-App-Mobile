import 'package:cloud_firestore/cloud_firestore.dart';

class Ruqyah {
  final String id;
  final String title;
  final String type; // "youtube" | "audio"
  final String? youtubeUrl;
  final String? audioUrl;
  final DateTime createdAt;

  Ruqyah({
    required this.id,
    required this.title,
    required this.type,
    this.youtubeUrl,
    this.audioUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'youtubeUrl': youtubeUrl,
      'audioUrl': audioUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Ruqyah.fromMap(String id, Map<String, dynamic> map) {
    return Ruqyah(
      id: id,
      title: map['title'] ?? '',
      type: map['type'] ?? 'audio',
      youtubeUrl: map['youtubeUrl'],
      audioUrl: map['audioUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}