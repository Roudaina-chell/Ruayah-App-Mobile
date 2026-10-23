import 'package:flutter_test/flutter_test.dart';
import 'package:mohammed_raqi_app/models/app_user.dart';

void main() {
  group('AppUser', () {
    test('toMap contient les champs et une date createdAt au format ISO', () {
      final user = AppUser(
        uid: 'u1',
        firstName: 'أحمد',
        lastName: 'بن علي',
        phone: '0555123456',
        role: 'client',
      );

      final map = user.toMap();

      expect(map['firstName'], 'أحمد');
      expect(map['lastName'], 'بن علي');
      expect(map['phone'], '0555123456');
      expect(map['role'], 'client');
      expect(map.containsKey('uid'), isFalse);
      expect(map['createdAt'], isA<String>());
      expect(() => DateTime.parse(map['createdAt'] as String), returnsNormally);
    });

    test('fromMap lit tous les champs', () {
      final user = AppUser.fromMap('u2', {
        'firstName': 'محمد',
        'lastName': 'الراقي',
        'phone': '0666000000',
        'role': 'admin',
      });

      expect(user.uid, 'u2');
      expect(user.firstName, 'محمد');
      expect(user.lastName, 'الراقي');
      expect(user.phone, '0666000000');
      expect(user.role, 'admin');
    });

    test('fromMap utilise des valeurs par défaut (role = client)', () {
      final user = AppUser.fromMap('u3', {});

      expect(user.uid, 'u3');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.phone, '');
      expect(user.role, 'client');
    });

    test('toMap puis fromMap redonne le même utilisateur', () {
      final original = AppUser(
        uid: 'u4',
        firstName: 'سارة',
        lastName: 'منصور',
        phone: '0770111111',
        role: 'client',
      );

      final copy = AppUser.fromMap('u4', original.toMap());

      expect(copy.uid, original.uid);
      expect(copy.firstName, original.firstName);
      expect(copy.lastName, original.lastName);
      expect(copy.phone, original.phone);
      expect(copy.role, original.role);
    });
  });
}