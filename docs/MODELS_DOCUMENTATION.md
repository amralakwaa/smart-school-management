# 📦 شرح تفصيلي للنماذج (Models)

---

# 📊 نظرة عامة

| النموذج | الملف | الوظيفة |
|---------|-------|---------|
| UserModel | `user_model.dart` | بيانات المستخدم |
| ClassModel | `class_model.dart` | بيانات الصف الدراسي |
| SubjectModel | `subject_model.dart` | بيانات المادة |
| GradeModel | `grade_model.dart` | بيانات الدرجة |
| AttendanceModel | `attendance_model.dart` | سجل الحضور |
| AssignmentModel | `assignment_model.dart` | التكليف/الواجب |
| SubmissionModel | `assignment_model.dart` | تسليم الطالب |

---

# 🏗️ البنية المشتركة لكل Model

```dart
class ExampleModel {
  // 1. الحقول (final)
  final String id;
  final String name;
  final DateTime createdAt;
  
  // 2. Constructor
  const ExampleModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  
  // 3. Factory: fromMap (من Firestore)
  factory ExampleModel.fromMap(Map<String, dynamic> map) {...}
  
  // 4. Factory: fromSqliteMap (من SQLite)
  factory ExampleModel.fromSqliteMap(Map<String, dynamic> map) {...}
  
  // 5. Method: toMap (لـ Firestore)
  Map<String, dynamic> toMap() {...}
  
  // 6. Method: toSqliteMap (لـ SQLite)
  Map<String, dynamic> toSqliteMap() {...}
  
  // 7. Method: copyWith (للتعديل)
  ExampleModel copyWith({String? name}) {...}
  
  // 8. Getters المحسوبة
  bool get isNew => ...;
  
  // 9. toString (للطباعة)
  @override
  String toString() => 'ExampleModel(id: $id, name: $name)';
}
```

---

# 1️⃣ نموذج المستخدم (UserModel)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/models/user_model.dart` |
| **الـ Collection** | `users` |
| **الأدوار** | `admin`, `teacher`, `student` |

## الحقول
```dart
class UserModel {
  final String uid;           // معرف Firebase Auth
  final String email;         // البريد الإلكتروني
  final String name;          // الاسم الكامل
  final String role;          // الدور (admin/teacher/student)
  final String? phone;        // رقم الهاتف (اختياري)
  final String? password;     // كلمة المرور (للتطوير فقط!)
  final String? classId;      // معرف الصف (للطالب)
  final List<String>? subjectIds;  // معرفات المواد (للمعلم)
  final DateTime createdAt;   // تاريخ الإنشاء
  final DateTime updatedAt;   // تاريخ التحديث
  final bool isDeleted;       // هل محذوف؟ (Soft Delete)
  final DateTime? deletedAt;  // تاريخ الحذف
}
```

## Constructor
```dart
const UserModel({
  required this.uid,
  required this.email,
  required this.name,
  required this.role,
  this.phone,
  this.password,
  this.classId,
  this.subjectIds,
  required this.createdAt,
  required this.updatedAt,
  this.isDeleted = false,
  this.deletedAt,
});
```
| البند | التفاصيل |
|-------|---------|
| **const** | يجعل الكائن ثابتاً (immutable) |
| **required** | حقل إجباري |
| **this.field** | اختصار للتعيين |

## fromMap - من Firestore
```dart
factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    name: map['name'] ?? '',
    role: map['role'] ?? 'student',
    phone: map['phone'],
    password: map['password'],
    classId: map['classId'],
    subjectIds: map['subjectIds'] != null 
        ? List<String>.from(map['subjectIds']) 
        : null,
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    isDeleted: map['isDeleted'] ?? false,
    deletedAt: map['deletedAt'] != null
        ? (map['deletedAt'] as Timestamp).toDate()
        : null,
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **factory** | Constructor يُرجع كائناً |
| **??** | قيمة افتراضية إذا null |
| **Timestamp** | نوع Firestore للتاريخ |
| **List.from** | تحويل لـ List |

## fromSqliteMap - من SQLite
```dart
factory UserModel.fromSqliteMap(Map<String, dynamic> map) {
  return UserModel(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    name: map['name'] ?? '',
    role: map['role'] ?? 'student',
    phone: map['phone'],
    classId: map['class_id'],  // ملاحظة: snake_case
    subjectIds: map['subject_ids'] != null
        ? (map['subject_ids'] as String).split(',')
        : null,
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **snake_case** | تسمية SQLite |
| **split(',')** | تحويل String لـ List |

## toMap - لـ Firestore
```dart
Map<String, dynamic> toMap() {
  return {
    'email': email,
    'name': name,
    'role': role,
    'phone': phone,
    'classId': classId,
    'subjectIds': subjectIds,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'isDeleted': isDeleted,
    'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
  };
}
```
| البند | التفاصيل |
|-------|---------|
| **uid غير موجود** | يُخزن كـ Document ID |
| **password غير موجود** | لا يُخزن في toMap العادية |

## toSqliteMap - لـ SQLite
```dart
Map<String, dynamic> toSqliteMap() {
  return {
    'uid': uid,
    'email': email,
    'name': name,
    'role': role,
    'phone': phone,
    'class_id': classId,
    'subject_ids': subjectIds?.join(','),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```
| البند | التفاصيل |
|-------|---------|
| **join(',')** | تحويل List لـ String |
| **toIso8601String** | تنسيق تاريخ موحد |

## copyWith - نسخة معدلة
```dart
UserModel copyWith({
  String? uid,
  String? email,
  String? name,
  String? role,
  String? phone,
  String? classId,
  List<String>? subjectIds,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return UserModel(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    name: name ?? this.name,
    role: role ?? this.role,
    phone: phone ?? this.phone,
    classId: classId ?? this.classId,
    subjectIds: subjectIds ?? this.subjectIds,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **الفائدة** | تعديل حقول محددة فقط |
| **الاستخدام** | `user.copyWith(name: 'اسم جديد')` |

## Getters المحسوبة
```dart
// هل المستخدم مدير؟
bool get isAdmin => role == 'admin';

// هل المستخدم معلم؟
bool get isTeacher => role == 'teacher';

// هل المستخدم طالب؟
bool get isStudent => role == 'student';

// الحرف الأول من الاسم
String get initial => name.isNotEmpty ? name[0] : '?';

// اللون حسب الدور
Color get roleColor {
  switch (role) {
    case 'admin': return AppTheme.adminColor;
    case 'teacher': return AppTheme.teacherColor;
    case 'student': return AppTheme.studentColor;
    default: return Colors.grey;
  }
}
```

---

# 2️⃣ نموذج الصف (ClassModel)

## الحقول
```dart
class ClassModel {
  final String id;            // معرف Firestore
  final String name;          // اسم الصف (الصف الأول)
  final String? grade;        // المرحلة (ابتدائي/إعدادي/ثانوي)
  final String? section;      // الشعبة (أ/ب/ج)
  final int studentCount;     // عدد الطلاب
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## Constructor
```dart
const ClassModel({
  required this.id,
  required this.name,
  this.grade,
  this.section,
  this.studentCount = 0,
  required this.createdAt,
  required this.updatedAt,
});
```

## fromMap
```dart
factory ClassModel.fromMap(Map<String, dynamic> map) {
  return ClassModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    grade: map['grade'],
    section: map['section'],
    studentCount: map['studentCount'] ?? 0,
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}
```

## toMap
```dart
Map<String, dynamic> toMap() {
  return {
    'name': name,
    'grade': grade,
    'section': section,
    'studentCount': studentCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

## Getters المحسوبة
```dart
// الاسم الكامل مع الشعبة
String get fullName => section != null ? '$name - $section' : name;

// هل الصف فارغ؟
bool get isEmpty => studentCount == 0;
```

---

# 3️⃣ نموذج المادة (SubjectModel)

## الحقول
```dart
class SubjectModel {
  final String id;
  final String name;              // اسم المادة
  final String? description;      // وصف المادة
  final String teacherId;         // معرف المعلم
  final String? teacherName;      // اسم المعلم (للعرض)
  final List<String> relatedClassIds;  // الصفوف المرتبطة
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## Constructor
```dart
const SubjectModel({
  required this.id,
  required this.name,
  this.description,
  required this.teacherId,
  this.teacherName,
  this.relatedClassIds = const [],
  required this.createdAt,
  required this.updatedAt,
});
```

## fromMap
```dart
factory SubjectModel.fromMap(Map<String, dynamic> map) {
  return SubjectModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    description: map['description'],
    teacherId: map['teacherId'] ?? '',
    teacherName: map['teacherName'],
    relatedClassIds: map['relatedClassIds'] != null
        ? List<String>.from(map['relatedClassIds'])
        : [],
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}
```

## toMap
```dart
Map<String, dynamic> toMap() {
  return {
    'name': name,
    'description': description,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'relatedClassIds': relatedClassIds,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

## Getters
```dart
// عدد الصفوف المرتبطة
int get classCount => relatedClassIds.length;

// هل لها معلم؟
bool get hasTeacher => teacherId.isNotEmpty;
```

---

# 4️⃣ نموذج الدرجة (GradeModel)

## الحقول
```dart
class GradeModel {
  final String id;
  final String studentId;         // معرف الطالب
  final String studentName;       // اسم الطالب
  final String subjectId;         // معرف المادة
  final String subjectName;       // اسم المادة
  final String classId;           // معرف الصف
  final String teacherId;         // معرف المعلم الذي رصد
  final String examType;          // نوع الاختبار
  final double grade;             // الدرجة
  final double maxGrade;          // الدرجة القصوى
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## أنواع الاختبارات
```dart
// القيم المستخدمة
static const String monthly1 = 'monthly1';   // الشهري الأول
static const String monthly2 = 'monthly2';   // الشهري الثاني
static const String midterm = 'midterm';     // نصف الفصل
static const String final_ = 'final';        // النهائي
static const String homework = 'homework';   // واجب
static const String quiz = 'quiz';           // اختبار قصير
```

## fromMap
```dart
factory GradeModel.fromMap(Map<String, dynamic> map) {
  return GradeModel(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    subjectId: map['subjectId'] ?? '',
    subjectName: map['subjectName'] ?? '',
    classId: map['classId'] ?? '',
    teacherId: map['teacherId'] ?? '',
    examType: map['examType'] ?? '',
    grade: (map['grade'] ?? 0).toDouble(),
    maxGrade: (map['maxGrade'] ?? 100).toDouble(),
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}
```

## toMap
```dart
Map<String, dynamic> toMap() {
  return {
    'studentId': studentId,
    'studentName': studentName,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'classId': classId,
    'teacherId': teacherId,
    'examType': examType,
    'grade': grade,
    'maxGrade': maxGrade,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

## Getters المحسوبة
```dart
// النسبة المئوية
double get percentage => maxGrade > 0 ? (grade / maxGrade) * 100 : 0;

// اسم نوع الاختبار بالعربي
String get examTypeName {
  switch (examType) {
    case 'monthly1': return 'الاختبار الشهري الأول';
    case 'monthly2': return 'الاختبار الشهري الثاني';
    case 'midterm': return 'اختبار نصف الفصل';
    case 'final': return 'الاختبار النهائي';
    case 'homework': return 'واجب';
    case 'quiz': return 'اختبار قصير';
    default: return examType;
  }
}

// التقدير
String get letterGrade {
  final pct = percentage;
  if (pct >= 90) return 'ممتاز';
  if (pct >= 80) return 'جيد جداً';
  if (pct >= 70) return 'جيد';
  if (pct >= 60) return 'مقبول';
  return 'ضعيف';
}

// لون التقدير
Color get gradeColor {
  final pct = percentage;
  if (pct >= 85) return AppTheme.successColor;
  if (pct >= 60) return AppTheme.warningColor;
  return AppTheme.errorColor;
}
```

---

# 5️⃣ نموذج الحضور (AttendanceModel)

## الحقول
```dart
class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String classId;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String date;            // التاريخ (yyyy-MM-dd)
  final String status;          // الحالة
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## حالات الحضور
```dart
static const String present = 'present';   // حاضر
static const String absent = 'absent';     // غائب
static const String late = 'late';         // متأخر
static const String excused = 'excused';   // مستأذن
```

## fromMap
```dart
factory AttendanceModel.fromMap(Map<String, dynamic> map) {
  return AttendanceModel(
    id: map['id'] ?? '',
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    classId: map['classId'] ?? '',
    subjectId: map['subjectId'] ?? '',
    subjectName: map['subjectName'] ?? '',
    teacherId: map['teacherId'] ?? '',
    date: map['date'] ?? '',
    status: map['status'] ?? 'absent',
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}
```

## toMap
```dart
Map<String, dynamic> toMap() {
  return {
    'studentId': studentId,
    'studentName': studentName,
    'classId': classId,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'teacherId': teacherId,
    'date': date,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

## Getters المحسوبة
```dart
// هل حاضر؟
bool get isPresent => status == 'present';

// هل غائب؟
bool get isAbsent => status == 'absent';

// هل متأخر؟
bool get isLate => status == 'late';

// هل مستأذن؟
bool get isExcused => status == 'excused';

// اسم الحالة بالعربي
String get statusName {
  switch (status) {
    case 'present': return 'حاضر';
    case 'absent': return 'غائب';
    case 'late': return 'متأخر';
    case 'excused': return 'مستأذن';
    default: return status;
  }
}

// لون الحالة
Color get statusColor {
  switch (status) {
    case 'present': return AppTheme.successColor;
    case 'absent': return AppTheme.errorColor;
    case 'late': return AppTheme.warningColor;
    case 'excused': return AppTheme.infoColor;
    default: return Colors.grey;
  }
}

// أيقونة الحالة
IconData get statusIcon {
  switch (status) {
    case 'present': return Icons.check_circle;
    case 'absent': return Icons.cancel;
    case 'late': return Icons.access_time;
    case 'excused': return Icons.info;
    default: return Icons.help;
  }
}
```

---

# 6️⃣ نموذج التكليف (AssignmentModel)

## الحقول
```dart
class AssignmentModel {
  final String id;
  final String title;             // عنوان التكليف
  final String? description;      // الوصف
  final String teacherId;
  final String teacherName;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String dueDate;           // تاريخ التسليم (yyyy-MM-dd)
  final double? maxGrade;         // الدرجة القصوى
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## fromMap
```dart
factory AssignmentModel.fromMap(Map<String, dynamic> map) {
  return AssignmentModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    description: map['description'],
    teacherId: map['teacherId'] ?? '',
    teacherName: map['teacherName'] ?? '',
    subjectId: map['subjectId'] ?? '',
    subjectName: map['subjectName'] ?? '',
    classId: map['classId'] ?? '',
    className: map['className'] ?? '',
    dueDate: map['dueDate'] ?? '',
    maxGrade: (map['maxGrade'] ?? 0).toDouble(),
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: map['updatedAt'] is Timestamp
        ? (map['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}
```

## toMap
```dart
Map<String, dynamic> toMap() {
  return {
    'title': title,
    'description': description,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'subjectId': subjectId,
    'subjectName': subjectName,
    'classId': classId,
    'className': className,
    'dueDate': dueDate,
    'maxGrade': maxGrade,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

## Getters المحسوبة
```dart
// هل انتهى الموعد؟
bool get isOverdue {
  final due = DateTime.parse(dueDate);
  return DateTime.now().isAfter(due);
}

// الأيام المتبقية
int get daysRemaining {
  final due = DateTime.parse(dueDate);
  return due.difference(DateTime.now()).inDays;
}

// حالة التكليف
String get statusText {
  if (isOverdue) return 'منتهي';
  if (daysRemaining == 0) return 'اليوم!';
  if (daysRemaining == 1) return 'غداً';
  return 'باقي $daysRemaining يوم';
}
```

---

# 7️⃣ نموذج التسليم (SubmissionModel)

## الحقول
```dart
class SubmissionModel {
  final String id;
  final String assignmentId;      // معرف التكليف
  final String studentId;
  final String studentName;
  final String? fileUrl;          // رابط الملف
  final String? fileName;         // اسم الملف
  final String? notes;            // ملاحظات الطالب
  final String status;            // حالة التسليم
  final double? grade;            // الدرجة (بعد التقييم)
  final String? feedback;         // ملاحظات المعلم
  final DateTime submittedAt;     // تاريخ التسليم
  final DateTime? gradedAt;       // تاريخ التقييم
}
```

## حالات التسليم
```dart
static const String pending = 'pending';       // بانتظار التسليم
static const String submitted = 'submitted';   // تم التسليم
static const String graded = 'graded';         // تم التقييم
static const String late = 'late';             // متأخر
```

## fromMap
```dart
factory SubmissionModel.fromMap(Map<String, dynamic> map) {
  return SubmissionModel(
    id: map['id'] ?? '',
    assignmentId: map['assignmentId'] ?? '',
    studentId: map['studentId'] ?? '',
    studentName: map['studentName'] ?? '',
    fileUrl: map['fileUrl'],
    fileName: map['fileName'],
    notes: map['notes'],
    status: map['status'] ?? 'pending',
    grade: map['grade']?.toDouble(),
    feedback: map['feedback'],
    submittedAt: map['submittedAt'] is Timestamp
        ? (map['submittedAt'] as Timestamp).toDate()
        : DateTime.now(),
    gradedAt: map['gradedAt'] != null
        ? (map['gradedAt'] as Timestamp).toDate()
        : null,
  );
}
```

## toMap
```dart
Map<String, dynamic> toMap() {
  return {
    'assignmentId': assignmentId,
    'studentId': studentId,
    'studentName': studentName,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'notes': notes,
    'status': status,
    'grade': grade,
    'feedback': feedback,
    'submittedAt': Timestamp.fromDate(submittedAt),
    'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
  };
}
```

## Getters المحسوبة
```dart
// هل تم التسليم؟
bool get isSubmitted => status == 'submitted' || status == 'graded';

// هل تم التقييم؟
bool get isGraded => status == 'graded' && grade != null;

// هل متأخر؟
bool get isLate => status == 'late';

// هل له ملف؟
bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
```

---

# 🗄️ هيكل Firestore

```
firestore/
├── users/
│   └── {uid}/
│       ├── email: string
│       ├── name: string
│       ├── role: string
│       ├── classId?: string
│       ├── subjectIds?: string[]
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── classes/
│   └── {classId}/
│       ├── name: string
│       ├── grade?: string
│       ├── section?: string
│       ├── studentCount: number
│       └── ...
│
├── subjects/
│   └── {subjectId}/
│       ├── name: string
│       ├── teacherId: string
│       ├── teacherName: string
│       ├── relatedClassIds: string[]
│       └── ...
│
├── grades/
│   └── {gradeId}/
│       ├── studentId: string
│       ├── studentName: string
│       ├── subjectId: string
│       ├── examType: string
│       ├── grade: number
│       ├── maxGrade: number
│       └── ...
│
├── attendance/
│   └── {attendanceId}/
│       ├── studentId: string
│       ├── studentName: string
│       ├── subjectId: string
│       ├── date: string
│       ├── status: string
│       └── ...
│
└── assignments/
    └── {assignmentId}/
        ├── title: string
        ├── teacherId: string
        ├── subjectId: string
        ├── dueDate: string
        └── submissions/
            └── {submissionId}/
                ├── studentId: string
                ├── fileUrl: string
                ├── status: string
                └── grade?: number
```

---

# 🔗 العلاقات بين النماذج

```
                        ┌─────────────┐
                        │  UserModel  │
                        │   (users)   │
                        └──────┬──────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
         ▼                     ▼                     ▼
    role=admin           role=teacher           role=student
         │                     │                     │
         │              ┌──────┴──────┐              │
         │              ▼             ▼              │
         │      ┌────────────┐ ┌──────────────┐     │
         │      │SubjectModel│ │ClassModel    │     │
         │      └─────┬──────┘ └──────┬───────┘     │
         │            │               │              │
         │    ┌───────┴───────────────┴───────┐     │
         │    ▼                               ▼     │
         │ ┌──────────────┐           ┌───────────┐│
         │ │AssignmentModel│          │GradeModel ││
         │ └──────┬───────┘           └───────────┘│
         │        │                                │
         │        ▼                                │
         │ ┌──────────────┐           ┌───────────┐│
         │ │SubmissionModel│          │Attendance ││
         │ └──────────────┘           │  Model    ││
         │                            └───────────┘│
         └─────────────────────────────────────────┘
```

---

# 📊 ملخص النماذج

| النموذج | الحقول الرئيسية | Getters |
|---------|----------------|---------|
| **UserModel** | uid, email, name, role | isAdmin, isTeacher, isStudent |
| **ClassModel** | id, name, grade, section | fullName, isEmpty |
| **SubjectModel** | id, name, teacherId | classCount, hasTeacher |
| **GradeModel** | studentId, grade, maxGrade | percentage, letterGrade |
| **AttendanceModel** | studentId, date, status | isPresent, isAbsent, statusName |
| **AssignmentModel** | title, dueDate, maxGrade | isOverdue, daysRemaining |
| **SubmissionModel** | fileUrl, status, grade | isSubmitted, isGraded |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
