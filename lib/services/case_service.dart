import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_case.dart';
import '../models/case_entry.dart';

class CaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// حالة العميل الحالي — Stream
  Stream<PatientCase?> myCase() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('cases').doc(uid).snapshots().map(
        (doc) => doc.exists ? PatientCase.fromMap(doc.id, doc.data()!) : null);
  }

  /// سجلات (أعراض/توجيهات) حالة معينة — Stream
  Stream<List<CaseEntry>> entries(String caseId) {
    return _firestore
        .collection('cases')
        .doc(caseId)
        .collection('entries')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// تحديث اسم العميل داخل ملف الحالة
  Future<void> updateClientName({
    required String userName,
    required String userPhone,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('cases').doc(uid).set({
      'userName': userName,
      'userPhone': userPhone,
      'lastUpdatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// العميل يضيف أعراض جديدة
  Future<void> addSymptomEntry(String text) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final caseRef = _firestore.collection('cases').doc(uid);

    await caseRef.collection('entries').add({
      'authorRole': 'client',
      'text': text,
      'createdAt': Timestamp.now(),
    });

    await caseRef.set({
      'lastUpdatedAt': Timestamp.now(),
      'hasUnreadForAdmin': true,
      'hasUnreadForClient': false,
    }, SetOptions(merge: true));
  }

  /// الأدمن يضيف توجيه
  Future<void> addGuidanceEntry({
    required String caseId,
    required String text,
  }) async {
    final caseRef = _firestore.collection('cases').doc(caseId);

    await caseRef.collection('entries').add({
      'authorRole': 'admin',
      'text': text,
      'createdAt': Timestamp.now(),
    });

    await caseRef.set({
      'lastUpdatedAt': Timestamp.now(),
      'hasUnreadForClient': true,
      'hasUnreadForAdmin': false,
    }, SetOptions(merge: true));
  }

  /// الأدمن يحدد/يعدل التشخيص
  Future<void> updateDiagnosis({
    required String caseId,
    required String diagnosis,
  }) async {
    await _firestore.collection('cases').doc(caseId).set({
      'diagnosis': diagnosis,
    }, SetOptions(merge: true));
  }

    /// كل الحالات (للأدمن) — Stream
  Stream<List<PatientCase>> allCases() {
    return _firestore
        .collection('cases')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientCase.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// تعليم كمقروء من طرف الأدمن
  Future<void> markSeenByAdmin(String caseId) async {
    await _firestore.collection('cases').doc(caseId).set({
      'hasUnreadForAdmin': false,
    }, SetOptions(merge: true));
  }

  /// تعليم كمقروء من طرف العميل
  Future<void> markSeenByClient() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('cases').doc(uid).set({
      'hasUnreadForClient': false,
    }, SetOptions(merge: true));
  }
}