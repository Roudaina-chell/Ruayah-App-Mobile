import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/models/program.dart';

void main() {
  group('Program', () {
    final date = DateTime(2026, 1, 15, 10, 30);

    test('toMap contient tous les champs', () {
      final program = Program(
        id: 'p1',
        title: 'برنامج الصباح',
        shortDescription: 'وصف قصير',
        content: 'محتوى كامل',
        createdAt: date,
      );

      final map = program.toMap();

      expect(map['title'], 'برنامج الصباح');
      expect(map['shortDescription'], 'وصف قصير');
      expect(map['content'], 'محتوى كامل');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate().isAtSameMomentAs(date), isTrue);
      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap lit tous les champs', () {
      final program = Program.fromMap('p1', {
        'title': 'عنوان',
        'shortDescription': 'وصف',
        'content': 'محتوى',
        'createdAt': Timestamp.fromDate(date),
      });

      expect(program.id, 'p1');
      expect(program.title, 'عنوان');
      expect(program.shortDescription, 'وصف');
      expect(program.content, 'محتوى');
      expect(program.createdAt.isAtSameMomentAs(date), isTrue);
    });

    test('fromMap utilise des valeurs par défaut si les champs manquent', () {
      final before = DateTime.now();
      final program = Program.fromMap('p2', {});
      final after = DateTime.now();

      expect(program.id, 'p2');
      expect(program.title, '');
      expect(program.shortDescription, '');
      expect(program.content, '');
      expect(program.createdAt.isBefore(before), isFalse);
      expect(program.createdAt.isAfter(after), isFalse);
    });

    test('toMap puis fromMap redonne le même programme', () {
      final original = Program(
        id: 'p3',
        title: 'عنوان',
        shortDescription: 'وصف',
        content: 'محتوى',
        createdAt: date,
      );

      final copy = Program.fromMap('p3', original.toMap());

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.shortDescription, original.shortDescription);
      expect(copy.content, original.content);
      expect(copy.createdAt.isAtSameMomentAs(original.createdAt), isTrue);
    });
  });
}