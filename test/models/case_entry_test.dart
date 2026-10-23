import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/models/case_entry.dart';

void main() {
  group('CaseEntry', () {
    final date = DateTime(2026, 5, 5, 18, 45);

    test('fromMap lit une entrée du client', () {
      final entry = CaseEntry.fromMap('e1', {
        'authorRole': 'client',
        'text': 'أشعر بالأرق',
        'createdAt': Timestamp.fromDate(date),
      });

      expect(entry.id, 'e1');
      expect(entry.authorRole, 'client');
      expect(entry.text, 'أشعر بالأرق');
      expect(entry.createdAt.isAtSameMomentAs(date), isTrue);
    });

    test('fromMap lit une entrée de l\'admin', () {
      final entry = CaseEntry.fromMap('e2', {
        'authorRole': 'admin',
        'text': 'قراءة سورة البقرة',
        'createdAt': Timestamp.fromDate(date),
      });

      expect(entry.authorRole, 'admin');
      expect(entry.text, 'قراءة سورة البقرة');
    });

    test('fromMap utilise des valeurs par défaut (authorRole = client)', () {
      final before = DateTime.now();
      final entry = CaseEntry.fromMap('e3', {});
      final after = DateTime.now();

      expect(entry.id, 'e3');
      expect(entry.authorRole, 'client');
      expect(entry.text, '');
      expect(entry.createdAt.isBefore(before), isFalse);
      expect(entry.createdAt.isAfter(after), isFalse);
    });
  });
}