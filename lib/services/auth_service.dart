import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // نحوّل رقم الهاتف لإيميل داخلي (Firebase Auth كيفهم غير Email)
  String _phoneToEmail(String phone) {
    final cleaned = phone.trim().replaceAll(' ', '');
    return '$cleaned@mohammedraqi.app';
  }

  /// تسجيل مستخدم جديد (Register)
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final appUser = AppUser(
      uid: uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      role: 'client',
    );

    await _firestore.collection('users').doc(uid).set(appUser.toMap());

    return appUser;
  }

  /// تسجيل الدخول (Login)
  Future<AppUser> login({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('لم يتم العثور على بيانات المستخدم');
    }

    return AppUser.fromMap(uid, doc.data()!);
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// المستخدم الحالي (إن وجد)
  User? get currentUser => _auth.currentUser;

  /// بيانات المستخدم الكاملة من Firestore (الاسم، اللقب، الهاتف)
  Future<AppUser?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return AppUser.fromMap(uid, doc.data()!);
  }

  /// تحديث المعلومات الشخصية (الاسم، اللقب، الهاتف)
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('لا يوجد مستخدم مسجل الدخول');

    await _firestore.collection('users').doc(uid).update({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone.trim(),
    });
  }

  /// تغيير كلمة المرور (يتطلب إعادة مصادقة بكلمة المرور الحالية)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('لا يوجد مستخدم مسجل الدخول');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}