import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/models/appointment.dart';

void main() {
  group('Appointment', () {
    final date = DateTime(2026, 3, 10, 14, 0);

    test('toMap contient tous les champs', () {
      final appointment = Appointment(
        id: 'a1',
        userId: 'u1',
        userName: 'أحمد',
        userPhone: '0555123456',
        note: 'ملاحظة',
        status: 'confirmed',
        appointmentDate: '2026-03-12',
        appointmentTime: '10:30',
        seenByClient: false,
        createdAt: date,
      );

      final map = appointment.toMap();

      expect(map['userId'], 'u1');
      expect(map['userName'], 'أحمد');
      expect(map['userPhone'], '0555123456');
      expect(map['note'], 'ملاحظة');
      expect(map['status'], 'confirmed');
      expect(map['appointmentDate'], '2026-03-12');
      expect(map['appointmentTime'], '10:30');
      expect(map['seenByClient'], false);
      expect(map['createdAt'], isA<Timestamp>());
      expect(map.containsKey('id'), isFalse);
    });

    test('toMap garde la date et l\'heure nulles quand elles ne sont pas définies', () {
      final appointment = Appointment(
        id: 'a2',
        userId: 'u1',
        userName: 'أحمد',
        userPhone: '0555123456',
        note: '',
        status: 'pending',
        seenByClient: true,
        createdAt: date,
      );

      final map = appointment.toMap();

      expect(map['appointmentDate'], isNull);
      expect(map['appointmentTime'], isNull);
    });

    test('fromMap lit tous les champs', () {
      final appointment = Appointment.fromMap('a3', {
        'userId': 'u9',
        'userName': 'سارة',
        'userPhone': '0770111111',
        'note': 'ملاحظة',
        'status': 'cancelled',
        'appointmentDate': '2026-04-01',
        'appointmentTime': '09:00',
        'seenByClient': false,
        'createdAt': Timestamp.fromDate(date),
      });

      expect(appointment.id, 'a3');
      expect(appointment.userId, 'u9');
      expect(appointment.userName, 'سارة');
      expect(appointment.userPhone, '0770111111');
      expect(appointment.note, 'ملاحظة');
      expect(appointment.status, 'cancelled');
      expect(appointment.appointmentDate, '2026-04-01');
      expect(appointment.appointmentTime, '09:00');
      expect(appointment.seenByClient, false);
      expect(appointment.createdAt.isAtSameMomentAs(date), isTrue);
    });

    test('fromMap utilise des valeurs par défaut (pending, seenByClient = true)', () {
      final before = DateTime.now();
      final appointment = Appointment.fromMap('a4', {});
      final after = DateTime.now();

      expect(appointment.userId, '');
      expect(appointment.userName, '');
      expect(appointment.userPhone, '');
      expect(appointment.note, '');
      expect(appointment.status, 'pending');
      expect(appointment.appointmentDate, isNull);
      expect(appointment.appointmentTime, isNull);
      expect(appointment.seenByClient, true);
      expect(appointment.createdAt.isBefore(before), isFalse);
      expect(appointment.createdAt.isAfter(after), isFalse);
    });

    test('toMap puis fromMap redonne le même rendez-vous', () {
      final original = Appointment(
        id: 'a5',
        userId: 'u1',
        userName: 'أحمد',
        userPhone: '0555123456',
        note: 'ملاحظة',
        status: 'confirmed',
        appointmentDate: '2026-03-12',
        appointmentTime: '10:30',
        seenByClient: false,
        createdAt: date,
      );

      final copy = Appointment.fromMap('a5', original.toMap());

      expect(copy.userId, original.userId);
      expect(copy.userName, original.userName);
      expect(copy.userPhone, original.userPhone);
      expect(copy.note, original.note);
      expect(copy.status, original.status);
      expect(copy.appointmentDate, original.appointmentDate);
      expect(copy.appointmentTime, original.appointmentTime);
      expect(copy.seenByClient, original.seenByClient);
      expect(copy.createdAt.isAtSameMomentAs(original.createdAt), isTrue);
    });
  });
}