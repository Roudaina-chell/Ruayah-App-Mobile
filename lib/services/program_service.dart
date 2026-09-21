import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program.dart';

class ProgramService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// كل البرامج — Stream مباشر (للعميل والأدمن)
  Stream<List<Program>> allPrograms() {
    return _firestore
        .collection('programs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Program.fromMap(doc.id, doc.data())).toList());
  }

  /// إضافة برنامج جديد
  Future<void> addProgram({
    required String title,
    required String shortDescription,
    required String content,
  }) async {
    await _firestore.collection('programs').add({
      'title': title,
      'shortDescription': shortDescription,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  /// تعديل برنامج موجود
  Future<void> updateProgram({
    required String programId,
    required String title,
    required String shortDescription,
    required String content,
  }) async {
    await _firestore.collection('programs').doc(programId).update({
      'title': title,
      'shortDescription': shortDescription,
      'content': content,
    });
  }

  /// حذف برنامج
  Future<void> deleteProgram(String programId) async {
    await _firestore.collection('programs').doc(programId).delete();
  }
}