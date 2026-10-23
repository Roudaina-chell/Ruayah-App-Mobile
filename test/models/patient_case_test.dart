import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/models/patient_case.dart';

void main() {
  group('PatientCase', () {
    final date = DateTime(2026, 6, 1, 12, 0);

    test('fromMap lit tous les champs', () {
      final patientCase = PatientCase.fromMap('u1', {
        'userName': 'أحمد',
        'userPhone': '0555123456',
        'diagnosis': 'عين',
        'lastUpdatedAt': Timestamp.fromDate(date),
        'hasUnreadForAdmin': true,
        'hasUnreadForClient': true,
      });

      expect(patientCase.id, 'u1');
      expect(patientCase.userName, 'أحمد');
      expect(patientCase.userPhone, '0555123456');
      expect(patientCase.diagnosis, 'عين');
      expect(patientCase.lastUpdatedAt.isAtSameMomentAs(date), isTrue);
      expect(patientCase.hasUnreadForAdmin, true);
      expect(patientCase.hasUnreadForClient, true);
    });

    test('fromMap utilise des valeurs par défaut (aucun message non lu)', () {
      final before = DateTime.now();
      final patientCase = PatientCase.fromMap('u2', {});
      final after = DateTime.now();

      expect(patientCase.id, 'u2');
      expect(patientCase.userName, '');
      expect(patientCase.userPhone, '');
      expect(patientCase.diagnosis, '');
      expect(patientCase.hasUnreadForAdmin, false);
      expect(patientCase.hasUnreadForClient, false);
      expect(patientCase.lastUpdatedAt.isBefore(before), isFalse);
      expect(patientCase.lastUpdatedAt.isAfter(after), isFalse);
    });

    test('les deux indicateurs de lecture sont indépendants', () {
      final patientCase = PatientCase.fromMap('u3', {
        'hasUnreadForAdmin': true,
        'hasUnreadForClient': false,
      });

      expect(patientCase.hasUnreadForAdmin, true);
      expect(patientCase.hasUnreadForClient, false);
    });
  });
}