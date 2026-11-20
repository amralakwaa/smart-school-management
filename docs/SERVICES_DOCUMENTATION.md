# ⚙️ شرح تفصيلي للخدمات (Services)

---

# 📊 نظرة عامة

| الخدمة | الملف | الوظيفة |
|--------|-------|---------|
| AuthService | `auth_service.dart` | المصادقة وإدارة المستخدمين |
| FirestoreService | `firestore_service.dart` | عمليات قاعدة البيانات |
| DatabaseHelper | `database_helper.dart` | قاعدة بيانات SQLite المحلية |
| SyncService | `sync_service.dart` | مزامنة البيانات |

---

# 1️⃣ خدمة المصادقة (AuthService)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/services/auth_service.dart` |
| **النمط** | Singleton Pattern |
| **الاعتماديات** | `firebase_auth`, `cloud_firestore`, `connectivity_plus`, `crypto` |

## نمط Singleton
```dart
class AuthService {
  // المثيل الوحيد (private)
  static final AuthService _instance = AuthService._internal();
  
  // الوصول للمثيل (public)
  static AuthService get instance => _instance;
  
  // Constructor خاص
  AuthService._internal() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }
  
  // الحقول
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  UserModel? _currentUser;
  String? _currentLoginPassword;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
}
```
| البند | التفاصيل |
|-------|---------|
| **لماذا Singleton؟** | مثيل واحد في كل التطبيق |
| **الفائدة** | الوصول من أي مكان بـ `AuthService.instance` |
| **البديل** | Provider, GetIt, Riverpod |

---

## الدوال الرئيسية

### 1. signIn - تسجيل الدخول
```dart
Future<UserModel> signIn(String email, String password) async {
  // 1. فحص الاتصال
  final isOnline = await _checkConnectivity();
  
  if (isOnline) {
    // 2أ. تسجيل دخول أونلاين
    return await _signInOnline(email, password);
  } else {
    // 2ب. تسجيل دخول أوفلاين
    return await _signInOffline(email, password);
  }
}
```

### 2. _checkConnectivity - فحص الاتصال
```dart
Future<bool> _checkConnectivity() async {
  try {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  } catch (e) {
    return false;  // افتراض عدم الاتصال عند الخطأ
  }
}
```
| البند | التفاصيل |
|-------|---------|
| **Connectivity** | مكتبة `connectivity_plus` |
| **ConnectivityResult** | `wifi`, `mobile`, `ethernet`, `none` |

### 3. _signInOnline - تسجيل دخول أونلاين
```dart
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
    
    // 3. إنشاء UserModel
    final userData = userDoc.data()!;
    userData['uid'] = credential.user!.uid;
    userData['password'] = password;  // للتحديث لاحقاً
    
    final user = UserModel.fromMap(userData);
    
    // 4. حفظ البيانات محلياً
    await _cacheUserLocally(user, password);
    
    // 5. تحديث الحالة
    _currentUser = user;
    _currentLoginPassword = password;
    
    return user;
    
  } on FirebaseAuthException catch (e) {
    throw _handleFirebaseError(e);
  }
}
```

### 4. _signInOffline - تسجيل دخول أوفلاين
```dart
Future<UserModel> _signInOffline(String email, String password) async {
  // 1. الحصول على قاعدة البيانات
  final db = await DatabaseHelper.instance.database;
  
  // 2. البحث عن المستخدم
  final result = await db.query(
    'user_cache',
    where: 'email = ? AND password_hash = ?',
    whereArgs: [email, _hashPassword(password)],
  );
  
  if (result.isEmpty) {
    throw Exception('يرجى الاتصال بالإنترنت لتسجيل الدخول لأول مرة');
  }
  
  // 3. إنشاء UserModel من البيانات المخزنة
  final userData = result.first;
  final user = UserModel.fromSqliteMap(userData);
  
  _currentUser = user;
  _currentLoginPassword = password;
  
  return user;
}
```

### 5. _cacheUserLocally - التخزين المحلي
```dart
Future<void> _cacheUserLocally(UserModel user, String password) async {
  final db = await DatabaseHelper.instance.database;
  
  // حذف البيانات القديمة
  await db.delete(
    'user_cache',
    where: 'uid = ?',
    whereArgs: [user.uid],
  );
  
  // إدخال البيانات الجديدة
  await db.insert('user_cache', {
    'uid': user.uid,
    'email': user.email,
    'name': user.name,
    'role': user.role,
    'phone': user.phone,
    'class_id': user.classId,
    'password_hash': _hashPassword(password),
    'cached_at': DateTime.now().toIso8601String(),
    ...user.toSqliteMap(),
  });
}
```

### 6. _hashPassword - تشفير كلمة المرور
```dart
String _hashPassword(String password) {
  // استخدام SHA-256 للتشفير
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```
| البند | التفاصيل |
|-------|---------|
| **sha256** | من مكتبة `crypto` |
| **لماذا التشفير؟** | عدم تخزين كلمة المرور كنص عادي |
| **الناتج** | 64 حرف hex |

### 7. _handleFirebaseError - معالجة الأخطاء
```dart
Exception _handleFirebaseError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return Exception('البريد الإلكتروني غير مسجل');
    case 'wrong-password':
      return Exception('كلمة المرور غير صحيحة');
    case 'invalid-email':
      return Exception('البريد الإلكتروني غير صالح');
    case 'user-disabled':
      return Exception('تم تعطيل هذا الحساب');
    case 'too-many-requests':
      return Exception('محاولات كثيرة، يرجى المحاولة لاحقاً');
    case 'network-request-failed':
      return Exception('فشل الاتصال بالشبكة');
    default:
      return Exception('خطأ في تسجيل الدخول: ${e.message}');
  }
}
```

### 8. signOut - تسجيل الخروج
```dart
Future<void> signOut() async {
  try {
    await _auth.signOut();
  } catch (e) {
    // تجاهل أخطاء Firebase
  } finally {
    // مسح البيانات المحلية دائماً
    _currentUser = null;
    _currentLoginPassword = null;
  }
}
```

### 9. createUser - إنشاء مستخدم جديد
```dart
Future<UserModel> createUser({
  required String email,
  required String password,
  required String name,
  required String role,
  String? phone,
  String? classId,
  List<String>? subjectIds,
}) async {
  try {
    // 1. إنشاء حساب Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user == null) {
      throw Exception('فشل إنشاء الحساب');
    }
    
    final uid = credential.user!.uid;
    
    // 2. إنشاء UserModel
    final user = UserModel(
      uid: uid,
      email: email,
      name: name,
      role: role,
      phone: phone,
      classId: classId,
      subjectIds: subjectIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 3. حفظ في Firestore
    await _firestore.collection('users').doc(uid).set({
      ...user.toMap(),
      'password': password,  // للتطوير فقط!
    });
    
    return user;
    
  } on FirebaseAuthException catch (e) {
    throw _handleCreateUserError(e);
  }
}
```

### 10. updatePassword - تحديث كلمة المرور
```dart
Future<void> updatePassword(String newPassword) async {
  try {
    // 1. تحديث في Firebase Auth
    await _auth.currentUser?.updatePassword(newPassword);
    
    // 2. تحديث في Firestore (للتطوير)
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'password': newPassword});
    }
    
    // 3. تحديث التخزين المحلي
    if (_currentUser != null) {
      await _cacheUserLocally(_currentUser!, newPassword);
    }
    
    _currentLoginPassword = newPassword;
    
  } on FirebaseAuthException catch (e) {
    throw _handleFirebaseError(e);
  }
}
```

---

# 2️⃣ خدمة Firestore (FirestoreService)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/services/firestore_service.dart` |
| **النمط** | Singleton Pattern |
| **الاعتماديات** | `cloud_firestore`, `rxdart` |

## نمط Singleton
```dart
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirestoreService get instance => _instance;
  
  FirestoreService._internal() {
    _firestore = FirebaseFirestore.instance;
  }
  
  late final FirebaseFirestore _firestore;
}
```

---

## دوال المستخدمين (Users)

### 1. watchAllUsers - مراقبة كل المستخدمين
```dart
Stream<List<UserModel>> watchAllUsers() {
  return _firestore
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return UserModel.fromMap(data);
        }).toList();
      });
}
```
| البند | التفاصيل |
|-------|---------|
| **snapshots()** | Stream من التغييرات الفورية |
| **map()** | تحويل QuerySnapshot لـ List |
| **orderBy** | ترتيب حسب تاريخ الإنشاء |

### 2. watchUsersByRole - مراقبة مستخدمين بدور معين
```dart
Stream<List<UserModel>> watchUsersByRole(String role) {
  return _firestore
      .collection('users')
      .where('role', isEqualTo: role)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return UserModel.fromMap(data);
        }).toList();
      });
}
```

### 3. getUserById - جلب مستخدم واحد
```dart
Future<UserModel?> getUserById(String uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  
  if (!doc.exists) return null;
  
  final data = doc.data()!;
  data['uid'] = doc.id;
  return UserModel.fromMap(data);
}
```

### 4. updateUser - تحديث مستخدم
```dart
Future<void> updateUser(UserModel user) async {
  await _firestore
      .collection('users')
      .doc(user.uid)
      .update(user.toMap());
  
  // تحديث السجلات المرتبطة
  await _updateUserRelatedRecords(user);
}
```

### 5. _updateUserRelatedRecords - التحديث المتتالي
```dart
Future<void> _updateUserRelatedRecords(UserModel user) async {
  final batch = _firestore.batch();
  
  // تحديث اسم الطالب في سجلات الحضور
  if (user.role == 'student') {
    final attendanceQuery = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: user.uid)
        .get();
    
    for (final doc in attendanceQuery.docs) {
      batch.update(doc.reference, {'studentName': user.name});
    }
    
    // تحديث اسم الطالب في الدرجات
    final gradesQuery = await _firestore
        .collection('grades')
        .where('studentId', isEqualTo: user.uid)
        .get();
    
    for (final doc in gradesQuery.docs) {
      batch.update(doc.reference, {'studentName': user.name});
    }
  }
  
  // تحديث اسم المعلم في المواد
  if (user.role == 'teacher') {
    final subjectsQuery = await _firestore
        .collection('subjects')
        .where('teacherId', isEqualTo: user.uid)
        .get();
    
    for (final doc in subjectsQuery.docs) {
      batch.update(doc.reference, {'teacherName': user.name});
    }
  }
  
  await batch.commit();
}
```
| البند | التفاصيل |
|-------|---------|
| **WriteBatch** | تنفيذ عدة عمليات دفعة واحدة |
| **commit()** | تنفيذ الدفعة |
| **الفائدة** | ذرية (Atomic) - كله أو لا شيء |

### 6. deleteUser - حذف مستخدم
```dart
Future<void> deleteUser(String uid, {bool hardDelete = false}) async {
  if (hardDelete) {
    // حذف نهائي
    await _firestore.collection('users').doc(uid).delete();
  } else {
    // حذف ناعم (Soft Delete)
    await _firestore.collection('users').doc(uid).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## دوال المواد (Subjects)

### 1. watchAllSubjects
```dart
Stream<List<SubjectModel>> watchAllSubjects() {
  return _firestore
      .collection('subjects')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return SubjectModel.fromMap(data);
        }).toList();
      });
}
```

### 2. watchTeacherSubjects - مواد المعلم
```dart
Stream<List<SubjectModel>> watchTeacherSubjects(String teacherId) {
  return _firestore
      .collection('subjects')
      .where('teacherId', isEqualTo: teacherId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return SubjectModel.fromMap(data);
        }).toList();
      });
}
```

### 3. addSubject
```dart
Future<String> addSubject(SubjectModel subject) async {
  final docRef = await _firestore.collection('subjects').add(subject.toMap());
  return docRef.id;
}
```

---

## دوال الصفوف (Classes)

### 1. watchAllClasses
```dart
Stream<List<ClassModel>> watchAllClasses() {
  return _firestore
      .collection('classes')
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ClassModel.fromMap(data);
        }).toList();
      });
}
```

### 2. watchTeacherClasses - صفوف المعلم
```dart
Stream<List<ClassModel>> watchTeacherClasses(String teacherId) {
  // 1. جلب مواد المعلم أولاً
  return watchTeacherSubjects(teacherId).asyncMap((subjects) async {
    // 2. جمع كل IDs الصفوف من المواد
    final classIds = <String>{};
    for (final subject in subjects) {
      classIds.addAll(subject.relatedClassIds);
    }
    
    if (classIds.isEmpty) return <ClassModel>[];
    
    // 3. جلب الصفوف
    final classesQuery = await _firestore
        .collection('classes')
        .where(FieldPath.documentId, whereIn: classIds.toList())
        .get();
    
    return classesQuery.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ClassModel.fromMap(data);
    }).toList();
  });
}
```

---

## دوال الحضور (Attendance)

### 1. addAttendance
```dart
Future<void> addAttendance(AttendanceModel attendance) async {
  // تحقق من عدم التكرار
  final existing = await _firestore
      .collection('attendance')
      .where('studentId', isEqualTo: attendance.studentId)
      .where('subjectId', isEqualTo: attendance.subjectId)
      .where('date', isEqualTo: attendance.date)
      .get();
  
  if (existing.docs.isNotEmpty) {
    // تحديث السجل الموجود
    await existing.docs.first.reference.update(attendance.toMap());
  } else {
    // إضافة سجل جديد
    await _firestore.collection('attendance').add(attendance.toMap());
  }
}
```

### 2. watchStudentAttendance
```dart
Stream<List<AttendanceModel>> watchStudentAttendance(String studentId) {
  return _firestore
      .collection('attendance')
      .where('studentId', isEqualTo: studentId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return AttendanceModel.fromMap(data);
        }).toList();
      });
}
```

---

## دوال الدرجات (Grades)

### 1. addGrade
```dart
Future<void> addGrade(GradeModel grade) async {
  // تحقق من عدم التكرار
  final existing = await _firestore
      .collection('grades')
      .where('studentId', isEqualTo: grade.studentId)
      .where('subjectId', isEqualTo: grade.subjectId)
      .where('examType', isEqualTo: grade.examType)
      .get();
  
  if (existing.docs.isNotEmpty) {
    await existing.docs.first.reference.update(grade.toMap());
  } else {
    await _firestore.collection('grades').add(grade.toMap());
  }
}
```

### 2. watchStudentGrades
```dart
Stream<List<GradeModel>> watchStudentGrades(String studentId) {
  return _firestore
      .collection('grades')
      .where('studentId', isEqualTo: studentId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return GradeModel.fromMap(data);
        }).toList();
      });
}
```

---

## دوال التكاليف (Assignments)

### 1. watchTeacherAssignments
```dart
Stream<List<AssignmentModel>> watchTeacherAssignments(String teacherId) {
  return _firestore
      .collection('assignments')
      .where('teacherId', isEqualTo: teacherId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return AssignmentModel.fromMap(data);
        }).toList();
      });
}
```

### 2. addSubmission - إضافة تسليم
```dart
Future<void> addSubmission(String assignmentId, SubmissionModel submission) async {
  await _firestore
      .collection('assignments')
      .doc(assignmentId)
      .collection('submissions')
      .add(submission.toMap());
}
```

### 3. watchAssignmentSubmissions
```dart
Stream<List<SubmissionModel>> watchAssignmentSubmissions(String assignmentId) {
  return _firestore
      .collection('assignments')
      .doc(assignmentId)
      .collection('submissions')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return SubmissionModel.fromMap(data);
        }).toList();
      });
}
```

---

## دوال الإحصائيات (Statistics)

### 1. watchStatistics - إحصائيات المدير
```dart
Stream<Map<String, int>> watchStatistics() {
  return Rx.combineLatest3(
    watchAllUsers(),
    watchAllSubjects(),
    watchAllClasses(),
    (List<UserModel> users, List<SubjectModel> subjects, List<ClassModel> classes) {
      return {
        'totalUsers': users.length,
        'teachers': users.where((u) => u.role == 'teacher').length,
        'students': users.where((u) => u.role == 'student').length,
        'admins': users.where((u) => u.role == 'admin').length,
        'subjects': subjects.length,
        'classes': classes.length,
      };
    },
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **Rx.combineLatest3** | دمج 3 Streams |
| **rxdart** | مكتبة للتعامل مع Streams |
| **التحديث** | عند تغير أي Stream |

### 2. watchStudentStats - إحصائيات الطالب
```dart
Stream<Map<String, dynamic>> watchStudentStats(String studentId) {
  return Rx.combineLatest2(
    watchStudentGrades(studentId),
    watchStudentAttendance(studentId),
    (List<GradeModel> grades, List<AttendanceModel> attendance) {
      // حساب المعدل
      double averageGrade = 0;
      if (grades.isNotEmpty) {
        final totalPercentage = grades.fold<double>(
          0, (sum, g) => sum + g.percentage,
        );
        averageGrade = totalPercentage / grades.length;
      }
      
      // حساب نسبة الحضور
      double attendanceRate = 0;
      if (attendance.isNotEmpty) {
        final presentCount = attendance.where((a) => a.isPresent).length;
        attendanceRate = (presentCount / attendance.length) * 100;
      }
      
      return {
        'averageGrade': averageGrade.toInt(),
        'attendanceRate': attendanceRate.toInt(),
        'totalGrades': grades.length,
        'totalAttendance': attendance.length,
      };
    },
  );
}
```

### 3. watchTeacherStats - إحصائيات المعلم
```dart
Stream<Map<String, dynamic>> watchTeacherStats(String teacherId) {
  return Rx.combineLatest3(
    watchTeacherSubjects(teacherId),
    watchTeacherClasses(teacherId),
    watchTeacherAssignments(teacherId),
    (subjects, classes, assignments) {
      final totalStudents = classes.fold<int>(
        0, (sum, c) => sum + c.studentCount,
      );
      
      return {
        'subjects': subjects.length,
        'classes': classes.length,
        'students': totalStudents,
        'assignments': assignments.length,
      };
    },
  );
}
```

---

# 3️⃣ مساعد قاعدة البيانات (DatabaseHelper)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/services/database_helper.dart` |
| **الاعتماديات** | `sqflite`, `path` |
| **الاستخدام** | التخزين المحلي للعمل أوفلاين |

## الهيكل
```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();
  
  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'school_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين المخزنين
    await db.execute('''
      CREATE TABLE user_cache (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT,
        class_id TEXT,
        password_hash TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
    
    // جداول أخرى للتخزين المحلي
    await db.execute('''
      CREATE TABLE grades_cache (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        grade REAL NOT NULL,
        max_grade REAL NOT NULL,
        exam_type TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }
}
```

---

# 4️⃣ خدمة المزامنة (SyncService)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/services/sync_service.dart` |
| **الوظيفة** | مزامنة البيانات بين السيرفر والمحلي |

## الهيكل
```dart
class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;
  SyncService._internal();
  
  // مزامنة درجات الطالب
  Future<void> syncStudentGrades(String studentId) async {
    final isOnline = await _checkConnectivity();
    
    if (isOnline) {
      // جلب من Firestore وتخزين محلياً
      final grades = await FirestoreService.instance
          .getStudentGrades(studentId);
      
      await _cacheGrades(grades);
    }
  }
  
  // جلب الدرجات (أونلاين أو أوفلاين)
  Future<List<GradeModel>> getStudentGrades(String studentId) async {
    final isOnline = await _checkConnectivity();
    
    if (isOnline) {
      return await FirestoreService.instance.getStudentGrades(studentId);
    } else {
      return await _getLocalGrades(studentId);
    }
  }
}
```

---

# 🔗 العلاقات بين الخدمات

```
┌─────────────────────────────────────────────────────────┐
│                        UI Screens                        │
└─────────────────────────────┬───────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  AuthService  │     │FirestoreService│    │  SyncService  │
└───────┬───────┘     └───────┬───────┘     └───────┬───────┘
        │                     │                     │
        └──────────┬──────────┼──────────┬──────────┘
                   ▼          ▼          ▼
            ┌─────────────────────────────────┐
            │        DatabaseHelper           │
            │          (SQLite)               │
            └─────────────────────────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
     ┌───────────┐     ┌───────────┐     ┌───────────┐
     │Firebase   │     │Firestore  │     │  Local    │
     │   Auth    │     │   DB      │     │  SQLite   │
     └───────────┘     └───────────┘     └───────────┘
```

---

# 📊 ملخص الخدمات

| الخدمة | Pattern | المسؤولية |
|--------|---------|----------|
| **AuthService** | Singleton | المصادقة، إدارة الجلسة |
| **FirestoreService** | Singleton | CRUD، Streams الفورية |
| **DatabaseHelper** | Singleton | SQLite المحلية |
| **SyncService** | Singleton | مزامنة البيانات |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
