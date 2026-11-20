# 📚 توثيق تطبيق نظام إدارة المدرسة الذكي
# Smart School Management System Documentation

> **إعداد**: عمر الاكوع  
> **الجامعة**: جامعة ذمار - كلية الحاسبات والمعلوماتية  
> **المقرر**: تطوير تطبيقات الموبايل  
> **التاريخ**: فبراير 2026

---

## 📑 جدول المحتويات

1. [نظرة عامة على المشروع](#نظرة-عامة-على-المشروع)
2. [هيكل المشروع](#هيكل-المشروع)
3. [شاشات المدير (Admin)](#شاشات-المدير-admin)
4. [شاشات المعلم (Teacher)](#شاشات-المعلم-teacher)
5. [شاشات الطالب (Student)](#شاشات-الطالب-student)
6. [شاشة تسجيل الدخول](#شاشة-تسجيل-الدخول)
7. [ملفات التصميم والتخطيط](#ملفات-التصميم-والتخطيط)
8. [الخدمات (Services)](#الخدمات-services)
9. [النماذج (Models)](#النماذج-models)

---

# نظرة عامة على المشروع

## 🎯 الهدف
تطبيق Flutter لإدارة المدارس يدعم ثلاثة أنواع من المستخدمين:
- **المدير**: إدارة المستخدمين والصفوف والمواد
- **المعلم**: تسجيل الحضور ورصد الدرجات وإنشاء التكاليف
- **الطالب**: عرض الدرجات والحضور وتسليم التكاليف

## ✨ المميزات الرئيسية
- تصميم عربي احترافي (RTL)
- دعم الوضع Offline
- بيانات مباشرة (Real-time)
- تشفير كلمات المرور
- واجهة مستخدم حديثة وجذابة

## 📦 التقنيات المستخدمة
| التقنية | الاستخدام |
|---------|----------|
| **Flutter** | إطار العمل الرئيسي |
| **Firebase Auth** | المصادقة |
| **Cloud Firestore** | قاعدة البيانات السحابية |
| **SQLite** | قاعدة البيانات المحلية |
| **RxDart** | إدارة Streams |
| **connectivity_plus** | فحص الاتصال |

---

# هيكل المشروع

```
lib/
├── config/
│   ├── theme.dart        ← نظام الألوان والثيم
│   ├── constants.dart    ← الثوابت والترجمات
│   └── routes.dart       ← مسارات التنقل
├── models/
│   ├── user_model.dart
│   ├── class_model.dart
│   ├── subject_model.dart
│   ├── grade_model.dart
│   ├── attendance_model.dart
│   └── assignment_model.dart
├── services/
│   ├── auth_service.dart      ← خدمة المصادقة
│   ├── firestore_service.dart ← خدمة قاعدة البيانات
│   ├── database_helper.dart   ← SQLite
│   └── sync_service.dart      ← المزامنة
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── users_management_screen.dart
│   │   ├── add_edit_user_screen.dart
│   │   ├── classes_management_screen.dart
│   │   ├── subjects_management_screen.dart
│   │   └── reports_screen.dart
│   ├── teacher/
│   │   ├── teacher_dashboard_screen.dart
│   │   ├── attendance_screen.dart
│   │   ├── grades_screen.dart
│   │   ├── students_list_screen.dart
│   │   └── teacher_assignments_screen.dart
│   └── student/
│       ├── student_dashboard_screen.dart
│       ├── my_grades_screen.dart
│       ├── my_attendance_screen.dart
│       ├── my_subjects_screen.dart
│       └── upload_assignment_screen.dart
└── widgets/
    └── dashboard_card.dart
```

---

# شاشات المدير (Admin)

## 📊 ملخص شاشات المدير

| الشاشة | الملف | الغرض |
|--------|-------|-------|
| **لوحة التحكم** | `admin_dashboard_screen.dart` | الصفحة الرئيسية مع الإحصائيات |
| **إدارة المستخدمين** | `users_management_screen.dart` | عرض وإدارة المستخدمين |
| **إضافة/تعديل مستخدم** | `add_edit_user_screen.dart` | نموذج إضافة أو تعديل |
| **إدارة الصفوف** | `classes_management_screen.dart` | إدارة الصفوف الدراسية |
| **إدارة المواد** | `subjects_management_screen.dart` | إدارة المواد وربطها بالمعلمين |
| **التقارير** | `reports_screen.dart` | إحصائيات وتقارير شاملة |

---

# شاشات المعلم (Teacher)

## 📊 ملخص شاشات المعلم

| الشاشة | الملف | الغرض |
|--------|-------|-------|
| **لوحة التحكم** | `teacher_dashboard_screen.dart` | الصفحة الرئيسية للمعلم |
| **تسجيل الحضور** | `attendance_screen.dart` | تسجيل حضور وغياب الطلاب |
| **رصد الدرجات** | `grades_screen.dart` | إدخال درجات الطلاب |
| **قائمة الطلاب** | `students_list_screen.dart` | عرض طلاب الصفوف |
| **التكاليف** | `teacher_assignments_screen.dart` | إنشاء وإدارة التكاليف |

## 🧩 Widgets المستخدمة في شاشات المعلم

### 1. `Rx.combineLatest3` (دمج Streams)
```dart
_statsStream = Rx.combineLatest3(
  FirestoreService.instance.watchTeacherSubjects(uid),
  FirestoreService.instance.watchTeacherClasses(uid),
  FirestoreService.instance.watchTeacherAssignments(uid),
  (subjects, classes, assignments) {
    final totalStudents = classes.fold(0, (sum, c) => sum + c.studentCount);
    return {
      'subjects': subjects.length,
      'classes': classes.length,
      'assignments': assignments.length,
      'students': totalStudents,
    };
  },
);
```

### 2. `showDatePicker` (اختيار التاريخ)
```dart
final picked = await showDatePicker(
  context: context,
  initialDate: _selectedDate,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  locale: const Locale('ar'),
);
```

### 3. `ExpansionTile` (قائمة قابلة للتوسع)
```dart
ExpansionTile(
  title: Text('اسم الطالب'),
  subtitle: Text('تفاصيل إضافية'),
  leading: CircleAvatar(child: Text('أ')),
  children: [
    // محتوى موسع
  ],
)
```

### 4. `DraggableScrollableSheet` (ورقة سفلية قابلة للسحب)
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.9,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (context, scrollController) {
      return Container(
        child: ListView(controller: scrollController, children: [...]),
      );
    },
  ),
);
```

---

# شاشات الطالب (Student)

## 📊 ملخص شاشات الطالب

| الشاشة | الملف | الغرض |
|--------|-------|-------|
| **لوحة التحكم** | `student_dashboard_screen.dart` | الصفحة الرئيسية للطالب |
| **سجل الحضور** | `my_attendance_screen.dart` | عرض سجل الحضور والغياب |
| **درجاتي** | `my_grades_screen.dart` | عرض الدرجات مجمّعة حسب المادة |
| **موادي الدراسية** | `my_subjects_screen.dart` | عرض المواد المسجل فيها |
| **تسليم التكاليف** | `upload_assignment_screen.dart` | رفع الواجبات والمهام |

## 🧩 Widgets المستخدمة في شاشات الطالب

### 1. `LinearProgressIndicator` (شريط التقدم)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: LinearProgressIndicator(
    value: attendanceRate / 100,  // 0.0 إلى 1.0
    minHeight: 12,
    backgroundColor: Colors.grey.withOpacity(0.2),
    valueColor: AlwaysStoppedAnimation<Color>(
      attendanceRate >= 75 ? AppTheme.successColor : AppTheme.errorColor,
    ),
  ),
)
```

### 2. `FilePicker` (اختيار الملفات)
```dart
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
);
if (result != null) {
  selectedFileName = result.files.single.name;
}
```

### 3. تجميع البيانات حسب المادة
```dart
final gradesBySubject = <String, List<GradeModel>>{};
for (final grade in grades) {
  gradesBySubject
      .putIfAbsent(grade.subjectName, () => [])
      .add(grade);
}
```

---

# شاشة تسجيل الدخول

## 🎯 الهدف
تسجيل دخول المستخدمين وتوجيههم للوحة المناسبة حسب دورهم.

## 🧩 Widgets الرئيسية

### 1. `GlobalKey<FormState>` (مفتاح النموذج)
```dart
final _formKey = GlobalKey<FormState>();

// للتحقق من صحة النموذج
if (_formKey.currentState!.validate()) {
  // كل الحقول صالحة
}
```

### 2. `TextEditingController` (متحكم النص)
```dart
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

### 3. الخلفية المتدرجة مع أشكال زخرفية
```dart
body: Stack(
  children: [
    // الخلفية المتدرجة
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.08),
            Colors.white,
            AppTheme.teacherColor.withOpacity(0.05),
          ],
        ),
      ),
    ),
    // دوائر زخرفية
    Positioned(
      top: -80,
      left: -80,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.15),
              AppTheme.primaryColor.withOpacity(0),
            ],
          ),
        ),
      ),
    ),
    // المحتوى
    SafeArea(child: ...),
  ],
)
```

### 4. `validator` (التحقق من الإدخال)
```dart
validator: (value) {
  if (value == null || value.isEmpty)
    return 'يرجى إدخال البريد الإلكتروني';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
    return 'بريد إلكتروني غير صالح';
  return null;  // صالح
},
```

---

# ملفات التصميم والتخطيط

## 1. theme.dart (نظام الألوان)

### الألوان الرئيسية
```dart
static const Color primaryColor = Color(0xFF1565C0);   // أزرق داكن
static const Color secondaryColor = Color(0xFF42A5F5); // أزرق فاتح
static const Color accentColor = Color(0xFFFF9800);    // برتقالي
```

### ألوان الأدوار
```dart
static const Color adminColor = Color(0xFFE53935);    // أحمر للمدير
static const Color teacherColor = Color(0xFFFF9800);  // برتقالي للمعلم
static const Color studentColor = Color(0xFF1E88E5);  // أزرق للطالب
```

### ألوان الحالات
```dart
static const Color successColor = Color(0xFF4CAF50);  // أخضر - نجاح
static const Color errorColor = Color(0xFFF44336);    // أحمر - خطأ
static const Color warningColor = Color(0xFFFF9800);  // برتقالي - تحذير
static const Color infoColor = Color(0xFF2196F3);     // أزرق - معلومة
```

### دوال مساعدة
```dart
static Color getRoleColor(String role) {
  switch (role) {
    case 'admin':   return adminColor;
    case 'teacher': return teacherColor;
    case 'student': return studentColor;
    default:        return primaryColor;
  }
}

static IconData getRoleIcon(String role) {
  switch (role) {
    case 'admin':   return Icons.admin_panel_settings;
    case 'teacher': return Icons.school;
    case 'student': return Icons.person;
    default:        return Icons.person;
  }
}
```

---

## 2. constants.dart (الثوابت)

### ثوابت التطبيق
```dart
class AppConstants {
  static const String appName = 'نظام إدارة المدرسة الذكي';
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
}
```

### الترجمات العربية
```dart
class ArabicNames {
  static String getRoleName(String role) {
    switch (role) {
      case 'admin':   return 'مدير';
      case 'teacher': return 'معلم';
      case 'student': return 'طالب';
      default:        return role;
    }
  }

  static String getExamType(String type) {
    switch (type) {
      case 'monthly1': return 'الاختبار الشهري الأول';
      case 'monthly2': return 'الاختبار الشهري الثاني';
      case 'final':    return 'الاختبار النهائي';
      default:         return type;
    }
  }
}
```

---

## 3. routes.dart (المسارات)

### تعريف المسارات
```dart
class AppRoutes {
  // المصادقة
  static const String login = '/login';

  // المدير
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';

  // المعلم
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherAttendance = '/teacher/attendance';

  // الطالب
  static const String studentDashboard = '/student/dashboard';
  static const String studentGrades = '/student/grades';
}
```

### إنشاء Route مع حركة انتقالية
```dart
static PageRouteBuilder _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);  // من اليمين
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
```

---

# الخدمات (Services)

## 1. AuthService (خدمة المصادقة)

### نمط Singleton
```dart
class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();
  
  // الاستخدام: AuthService.instance.signIn(...)
}
```

### تسجيل الدخول الذكي (Online/Offline)
```dart
Future<UserModel> signIn(String email, String password) async {
  final isOnline = await _checkConnectivity();

  if (isOnline) {
    return await _signInOnline(email, password);
  } else {
    return await _signInOffline(email, password);
  }
}
```

### تشفير كلمة المرور
```dart
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### ترجمة أخطاء Firebase
```dart
String _handleFirebaseError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'البريد الإلكتروني غير مسجل';
    case 'wrong-password':
      return 'كلمة المرور غير صحيحة';
    case 'email-already-in-use':
      return 'البريد الإلكتروني مستخدم مسبقًا';
    default:
      return 'حدث خطأ: ${e.message}';
  }
}
```

---

## 2. FirestoreService (خدمة قاعدة البيانات)

### أنواع الدوال
| النوع | البادئة | الإرجاع | الاستخدام |
|-------|--------|--------|----------|
| **البث المباشر** | `watch` | `Stream<>` | تحديثات فورية |
| **جلب مرة واحدة** | `get` | `Future<>` | بيانات ثابتة |
| **إضافة** | `add` | `Future<String>` | إنشاء جديد |
| **تحديث** | `update` | `Future<void>` | تعديل موجود |
| **حذف** | `delete` | `Future<void>` | إزالة |

### مثال على Stream
```dart
Stream<List<UserModel>> watchAllUsers({bool isActive = true}) {
  return _firestore
      .collection('users')
      .where('isActive', isEqualTo: isActive)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return UserModel.fromMap(data);
      }).toList());
}
```

### دمج Streams
```dart
Stream<Map<String, int>> watchStatistics() {
  return Rx.combineLatest3(
    _firestore.collection('users').snapshots(),
    _firestore.collection('subjects').snapshots(),
    _firestore.collection('classes').snapshots(),
    (usersSnap, subjectsSnap, classesSnap) {
      return {
        'totalUsers': usersSnap.docs.length,
        'subjects': subjectsSnap.docs.length,
        'classes': classesSnap.docs.length,
      };
    },
  );
}
```

### Batch Operations (عمليات مجمعة)
```dart
Future<void> _updateUserRelatedRecords(UserModel user) async {
  final batch = _firestore.batch();

  final gradesQuery = await _firestore
      .collection('grades')
      .where('studentId', isEqualTo: user.uid)
      .get();
  
  for (var doc in gradesQuery.docs) {
    batch.update(doc.reference, {'studentName': user.name});
  }

  await batch.commit();
}
```

---

# النماذج (Models)

## الهيكل المشترك
```dart
class ModelName {
  // 1. الحقول
  final String id;
  final String name;

  // 2. المُنشئ
  ModelName({required this.id, required this.name});

  // 3. fromMap (من Firestore)
  factory ModelName.fromMap(Map<String, dynamic> map, {String? docId}) { ... }

  // 4. toMap (إلى Firestore)
  Map<String, dynamic> toMap() { ... }

  // 5. copyWith (نسخة معدلة)
  ModelName copyWith({String? id, String? name}) { ... }
}
```

## ملخص النماذج

| النموذج | الحقول الأساسية | الغرض |
|---------|----------------|-------|
| **UserModel** | uid, email, name, role | بيانات المستخدم |
| **ClassModel** | id, name, grade, section | بيانات الصف |
| **SubjectModel** | id, name, teacherId | بيانات المادة |
| **GradeModel** | studentId, grade, maxGrade | بيانات الدرجة |
| **AttendanceModel** | studentId, date, status | بيانات الحضور |
| **AssignmentModel** | title, dueDate, maxGrade | بيانات التكليف |
| **SubmissionModel** | studentId, fileUrl, status | بيانات التسليم |

## مخطط العلاقات

```
┌─────────────┐
│   UserModel  │◄────────────────────────────────┐
│   (users)    │                                  │
└──────┬───────┘                                  │
       │                                          │
       │ classId                                  │ teacherId
       ▼                                          │
┌─────────────┐         ┌─────────────┐           │
│  ClassModel  │◄────────│ SubjectModel │◄─────────┘
│   (classes)  │         │  (subjects)  │
└──────────────┘         └──────────────┘
       ▲                        ▲
       │ classId                │ subjectId
       │                        │
┌──────┴───────┐         ┌──────┴───────┐
│AttendanceModel│        │  GradeModel   │
│  (attendance)  │        │   (grades)    │
└────────────────┘        └───────────────┘
                                ▲
                                │
                    ┌───────────┴───────────┐
                    │   AssignmentModel      │
                    │    (assignments)       │
                    │         │              │
                    │  ┌──────▼──────┐       │
                    │  │SubmissionModel│      │
                    │  │ (submissions) │      │
                    │  └──────────────┘       │
                    └────────────────────────┘
```

---

# 📌 ملاحظات مهمة

## أنماط التصميم المستخدمة

### 1. Singleton Pattern
```dart
class ServiceName {
  static final ServiceName instance = ServiceName._init();
  ServiceName._init();
}
```

### 2. Factory Pattern
```dart
factory UserModel.fromMap(Map<String, dynamic> map) { ... }
```

### 3. Real-time Data with Streams
```dart
StreamBuilder<List<UserModel>>(
  stream: FirestoreService.instance.watchAllUsers(),
  builder: (context, snapshot) {
    if (snapshot.hasError) return ErrorWidget();
    if (!snapshot.hasData) return LoadingWidget();
    return DataWidget(data: snapshot.data!);
  },
)
```

## مميزات التصميم

| الميزة | الوصف |
|--------|-------|
| **RTL Support** | دعم كامل للغة العربية |
| **Gradient Headers** | تدرجات لونية جذابة |
| **Glassmorphism** | تأثيرات شفافية حديثة |
| **Responsive** | تصميم متجاوب |
| **Offline Support** | يعمل بدون إنترنت |
| **Real-time** | تحديثات فورية |

---

# 🔑 الحسابات الافتراضية

| الدور | البريد | كلمة المرور |
|-------|--------|-------------|
| مدير | admin@example.com | CHANGE_ME_123 |

---

> **ملاحظة**: هذا التوثيق يشمل جميع المكونات الرئيسية للتطبيق. للمزيد من التفاصيل، راجع الكود المصدري مباشرة.

---

*تم إنشاء هذا التوثيق تلقائياً - فبراير 2026*
