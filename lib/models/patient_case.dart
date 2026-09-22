import 'package:cloud_firestore/cloud_firestore.dart';

class PatientCase {
  final String id; // = userId
  final String userName;
  final String userPhone;
  final String diagnosis;
  final DateTime lastUpdatedAt;
  final bool hasUnreadForAdmin;
  final bool hasUnreadForClient;

  PatientCase({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.diagnosis,
    required this.lastUpdatedAt,
    required this.hasUnreadForAdmin,
    required this.hasUnreadForClient,
  });

  factory PatientCase.fromMap(String id, Map<String, dynamic> map) {
    return PatientCase(
      id: id,
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      lastUpdatedAt:
          (map['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasUnreadForAdmin: map['hasUnreadForAdmin'] ?? false,
      hasUnreadForClient: map['hasUnreadForClient'] ?? false,
    );
  }
}