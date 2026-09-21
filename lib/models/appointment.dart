import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String note;
  final String status; // pending | confirmed | cancelled
  final String? appointmentDate;
  final String? appointmentTime;
  final bool seenByClient;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.note,
    required this.status,
    this.appointmentDate,
    this.appointmentTime,
    required this.seenByClient,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'note': note,
      'status': status,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'seenByClient': seenByClient,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      note: map['note'] ?? '',
      status: map['status'] ?? 'pending',
      appointmentDate: map['appointmentDate'],
      appointmentTime: map['appointmentTime'],
      seenByClient: map['seenByClient'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}