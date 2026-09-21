class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String role; // "client" أو "admin"

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'client',
    );
  }
}