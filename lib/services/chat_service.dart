import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// رسائل محادثة معينة — Stream مباشر
  Stream<List<ChatMessage>> messages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// إرسال رسالة من العميل
  Future<void> sendClientMessage({
    required String userName,
    required String userPhone,
    required String text,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final conversationRef = _firestore.collection('conversations').doc(uid);

    await conversationRef.collection('messages').add({
      'senderId': uid,
      'senderRole': 'client',
      'text': text,
      'createdAt': Timestamp.now(),
    });

    await conversationRef.set({
      'userId': uid,
      'userName': userName,
      'userPhone': userPhone,
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
      'hasUnreadForAdmin': true,
      'hasUnreadForClient': false,
    }, SetOptions(merge: true));
  }

  /// إرسال رد من الأدمن
  Future<void> sendAdminReply({
    required String conversationId,
    required String text,
  }) async {
    final conversationRef =
        _firestore.collection('conversations').doc(conversationId);

    await conversationRef.collection('messages').add({
      'senderId': 'admin',
      'senderRole': 'admin',
      'text': text,
      'createdAt': Timestamp.now(),
    });

    await conversationRef.update({
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
      'hasUnreadForClient': true,
      'hasUnreadForAdmin': false,
    });
  }

  /// كل المحادثات (للأدمن) — Stream مباشر
  Stream<List<Conversation>> allConversations() {
    return _firestore
        .collection('conversations')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// محادثة العميل الحالي (Stream ديال document واحد)
  Stream<Conversation?> myConversation() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('conversations').doc(uid).snapshots().map(
        (doc) => doc.exists ? Conversation.fromMap(doc.id, doc.data()!) : null);
  }

  /// تعليم كمقروء من طرف الأدمن
  Future<void> markSeenByAdmin(String conversationId) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .update({'hasUnreadForAdmin': false});
  }

  /// تعليم كمقروء من طرف العميل
  Future<void> markSeenByClient() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('conversations')
        .doc(uid)
        .update({'hasUnreadForClient': false});
  }
}