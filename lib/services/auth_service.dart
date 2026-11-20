// خدمة المصادقة - Authentication Service
// تدعم تسجيل الدخول Online و Offline

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  String? _currentLoginPassword;

  AuthService._init();

  /// المستخدم الحالي
  UserModel? get currentUser => _currentUser;
  String? get currentLoginPassword => _currentLoginPassword;

  /// هل المستخدم مسجل الدخول؟
  bool get isLoggedIn => _currentUser != null;

  /// بث بيانات المستخدم الحالي (للمراقبة اللحظية للنشاط)
  Stream<UserModel?> watchCurrentUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    });
  }

  /// التحقق من الاتصال بالإنترنت
  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// تشفير كلمة المرور
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// تسجيل الدخول
  Future<UserModel> signIn(String email, String password) async {
    final isOnline = await _checkConnectivity();

    if (isOnline) {
      // تسجيل الدخول عبر Firebase
      return await _signInOnline(email, password);
    } else {
      // تسجيل الدخول محليًا
      return await _signInOffline(email, password);
    }
  }

  /// تسجيل الدخول Online
  Future<UserModel> _signInOnline(String email, String password) async {
    try {
      // 1. تسجيل الدخول عبر Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      // 2. جلب بيانات المستخدم من Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }

      final userData = userDoc.data()!;
      userData['uid'] = credential.user!.uid;
      userData['password'] =
          password; // حفظ كلمة المرور عند تسجيل الدخول لتحديثها

      final user = UserModel.fromMap(userData);

      // 3. حفظ البيانات محلياً
      await _cacheUserLocally(user, password);

      _currentUser = user;
      _currentLoginPassword = password;
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  /// تسجيل الدخول Offline
  Future<UserModel> _signInOffline(String email, String password) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'user_cache',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, _hashPassword(password)],
    );

    if (result.isEmpty) {
      throw Exception('يرجى الاتصال بالإنترنت لتسجيل الدخول لأول مرة');
    }

    final userData = result.first;
    final user = UserModel(
      uid: userData['uid'] as String,
      email: userData['email'] as String,
      name: userData['name'] as String,
      role: userData['role'] as String,
      classId: userData['class_id'] as String?,
      subjectIds: userData['subject_ids'] != null
          ? (userData['subject_ids'] as String).split(',')
          : null,
      phone: userData['phone'] as String?,
      password: userData['password'] as String?,
      createdAt: DateTime.parse(userData['created_at'] as String),
      updatedAt: DateTime.parse(userData['updated_at'] as String),
    );

    _currentUser = user;
    _currentLoginPassword = password;
    return user;
  }

  /// حفظ المستخدم محليًا
  Future<void> _cacheUserLocally(UserModel user, String password) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('user_cache', {
      'uid': user.uid,
      'email': user.email,
      'password_hash': _hashPassword(password),
      'name': user.name,
      'role': user.role,
      'class_id': user.classId,
      'subject_ids': user.subjectIds?.join(','),
      'phone': user.phone,
      'password': password,
      'is_logged_in': 1,
      'last_sync_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// التحقق من وجود جلسة محفوظة
  Future<UserModel?> checkExistingSession() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query('user_cache', where: 'is_logged_in = 1');

    if (result.isEmpty) return null;

    final userData = result.first;
    final user = UserModel(
      uid: userData['uid'] as String,
      email: userData['email'] as String,
      name: userData['name'] as String,
      role: userData['role'] as String,
      classId: userData['class_id'] as String?,
      subjectIds: userData['subject_ids'] != null
          ? (userData['subject_ids'] as String).split(',')
          : null,
      phone: userData['phone'] as String?,
      password: userData['password'] as String?,
      createdAt: DateTime.parse(userData['created_at'] as String),
      updatedAt: DateTime.parse(userData['updated_at'] as String),
    );

    _currentUser = user;
    _currentLoginPassword = userData['password'] as String?;

    // محاولة تحديث البيانات من Firebase إذا كان متصل
    final isOnline = await _checkConnectivity();
    if (isOnline) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final freshData = userDoc.data()!;
          freshData['uid'] = user.uid;
          _currentUser = UserModel.fromMap(freshData);
        }
      } catch (e) {
        // تجاهل الخطأ واستخدام البيانات المحلية
        debugPrint('⚠️ تعذر تحديث بيانات المستخدم: $e');
      }
    }

    return _currentUser;
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    // تسجيل الخروج من Firebase
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('⚠️ تعذر تسجيل الخروج من Firebase: $e');
    }

    // حذف البيانات المحلية
    final db = await DatabaseHelper.instance.database;
    await db.delete('user_cache');

    _currentUser = null;
  }

  /// إنشاء مستخدم جديد (للمدير فقط)
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    String? classId,
    List<String>? subjectIds,
    String? phone,
  }) async {
    try {
      // 1. إنشاء حساب في Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('فشل إنشاء الحساب');
      }

      final uid = credential.user!.uid;

      // 2. إنشاء وثيقة المستخدم في Firestore
      final user = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        classId: classId,
        subjectIds: subjectIds,
        phone: phone,
        password: password,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  /// تحديث البريد الإلكتروني للمستخدم الحالي
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل');

      // تحديث في Firebase Auth
      await user.verifyBeforeUpdateEmail(newEmail);

      // تحديث في Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(email: newEmail);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  /// تحديث كلمة المرور للمستخدم الحالي
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل');

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  /// إعادة تعيين كلمة مرور مستخدم آخر (بواسطة البريد)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  /// تغيير كلمة مرور مستخدم آخر (باستخدام جلسة مؤقتة)
  Future<void> updateOtherUserPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    FirebaseApp? tempApp;
    try {
      // 1. تهيئة تطبيق Firebase ثانوي
      tempApp = await Firebase.initializeApp(
        name: 'tempAuth_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      // 2. الحصول على Auth للتطبيق الثانوي
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      // 3. تسجيل الدخول ببيانات المستخدم المستهدف
      final credential = await tempAuth.signInWithEmailAndPassword(
        email: email,
        password: oldPassword,
      );

      if (credential.user == null) {
        throw Exception('فشل التوثيق بحساب المستخدم');
      }

      // 4. تحديث كلمة المرور
      await credential.user!.updatePassword(newPassword);

      // 5. تسجيل الخروج
      await tempAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      debugPrint('Error updating other user password: $e');
      rethrow;
    } finally {
      // 6. حذف التطبيق الثانوي لتنظيف الموارد
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  /// معالجة أخطاء Firebase
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور الحالية المخزنة غير صحيحة (قد يكون غيرها بنفسه)';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقًا';
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث (حاول مرة أخرى)';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
