import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/models/ruqyah.dart';

void main() {
  group('Ruqyah', () {
    final date = DateTime(2026, 2, 20, 8, 0);

    test('toMap pour une rqyah youtube', () {
      final ruqyah = Ruqyah(
        id: 'r1',
        title: 'رقية يوتيوب',
        type: 'youtube',
        youtubeUrl: 'https://youtube.com/watch?v=abc',
        createdAt: date,
      );

      final map = ruqyah.toMap();

      expect(map['title'], 'رقية يوتيوب');
      expect(map['type'], 'youtube');
      expect(map['youtubeUrl'], 'https://youtube.com/watch?v=abc');
      expect(map['audioUrl'], isNull);
      expect(map['createdAt'], isA<Timestamp>());
      expect(map.containsKey('id'), isFalse);
    });

    test('toMap pour une rqyah audio', () {
      final ruqyah = Ruqyah(
        id: 'r2',
        title: 'رقية صوتية',
        type: 'audio',
        audioUrl: 'https://example.com/file.mp3',
        createdAt: date,
      );

      final map = ruqyah.toMap();

      expect(map['type'], 'audio');
      expect(map['audioUrl'], 'https://example.com/file.mp3');
      expect(map['youtubeUrl'], isNull);
    });

    test('fromMap lit tous les champs', () {
      final ruqyah = Ruqyah.fromMap('r3', {
        'title': 'عنوان',
        'type': 'youtube',
        'youtubeUrl': 'https://youtube.com/watch?v=xyz',
        'audioUrl': null,
        'createdAt': Timestamp.fromDate(date),
      });

      expect(ruqyah.id, 'r3');
      expect(ruqyah.title, 'عنوان');
      expect(ruqyah.type, 'youtube');
      expect(ruqyah.youtubeUrl, 'https://youtube.com/watch?v=xyz');
      expect(ruqyah.audioUrl, isNull);
      expect(ruqyah.createdAt.isAtSameMomentAs(date), isTrue);
    });

    test('fromMap utilise audio comme type par défaut', () {
      final before = DateTime.now();
      final ruqyah = Ruqyah.fromMap('r4', {});
      final after = DateTime.now();

      expect(ruqyah.title, '');
      expect(ruqyah.type, 'audio');
      expect(ruqyah.youtubeUrl, isNull);
      expect(ruqyah.audioUrl, isNull);
      expect(ruqyah.createdAt.isBefore(before), isFalse);
      expect(ruqyah.createdAt.isAfter(after), isFalse);
    });

    test('toMap puis fromMap redonne la même rqyah', () {
      final original = Ruqyah(
        id: 'r5',
        title: 'عنوان',
        type: 'audio',
        audioUrl: 'https://example.com/a.mp3',
        createdAt: date,
      );

      final copy = Ruqyah.fromMap('r5', original.toMap());

      expect(copy.title, original.title);
      expect(copy.type, original.type);
      expect(copy.audioUrl, original.audioUrl);
      expect(copy.youtubeUrl, original.youtubeUrl);
      expect(copy.createdAt.isAtSameMomentAs(original.createdAt), isTrue);
    });
  });
}