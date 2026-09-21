import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/ruqyah.dart';

class RuqyahService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Ruqyah>> allRuqyahs() {
    return _firestore
        .collection('ruqyahs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Ruqyah.fromMap(doc.id, doc.data())).toList());
  }

  /// رفع ملف صوتي إلى Firebase Storage، يرجع الرابط النهائي
  Future<String> uploadAudioFile(File file, String fileName) async {
    final ref = _storage.ref().child('ruqyahs/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addYoutubeRuqyah({
    required String title,
    required String youtubeUrl,
  }) async {
    await _firestore.collection('ruqyahs').add({
      'title': title,
      'type': 'youtube',
      'youtubeUrl': youtubeUrl,
      'audioUrl': null,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> addAudioRuqyah({
    required String title,
    required String audioUrl,
  }) async {
    await _firestore.collection('ruqyahs').add({
      'title': title,
      'type': 'audio',
      'youtubeUrl': null,
      'audioUrl': audioUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deleteRuqyah(String ruqyahId) async {
    await _firestore.collection('ruqyahs').doc(ruqyahId).delete();
  }
}