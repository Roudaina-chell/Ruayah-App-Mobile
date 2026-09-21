import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// إرسال طلب حجز موعد جديد
  Future<void> requestAppointment({
    required String userName,
    required String userPhone,
    required String note,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    await _firestore.collection('appointments').add({
      'userId': uid,
      'userName': userName,
      'userPhone': userPhone,
      'note': note,
      'status': 'pending',
      'appointmentDate': null,
      'appointmentTime': null,
      'seenByClient': true,
      'createdAt': Timestamp.now(),
    });
  }

  /// مواعيد المستخدم الحالي (Stream مباشر: كيتحدث أوتوماتيكيًا)
  Stream<List<Appointment>> myAppointments() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// كل المواعيد (للأدمن) — Stream مباشر
  Stream<List<Appointment>> allAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// تأكيد موعد بتاريخ وساعة محددين — يبقى "غير مُطّلع عليه" حتى يشوفو العميل
  Future<void> confirmAppointment({
    required String appointmentId,
    required String date,
    required String time,
  }) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'confirmed',
      'appointmentDate': date,
      'appointmentTime': time,
      'seenByClient': false,
    });
  }

  /// إلغاء موعد — يبقى "غير مُطّلع عليه" حتى يشوفو العميل
  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': 'cancelled',
      'seenByClient': false,
    });
  }

  /// تعليم موعد كـ"تم الاطلاع عليه" من طرف العميل
  Future<void> markAsSeen(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'seenByClient': true,
    });
  }
}