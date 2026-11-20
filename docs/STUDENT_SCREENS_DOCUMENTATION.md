# 👨‍🎓 شرح تفصيلي لشاشات الطالب (Student Screens)

---

# 📊 نظرة عامة

| الشاشة | الملف | الوظيفة |
|--------|-------|---------|
| لوحة التحكم | `student_dashboard_screen.dart` | الإحصائيات والإجراءات السريعة |
| درجاتي | `my_grades_screen.dart` | عرض الدرجات مجمّعة حسب المادة |
| سجل الحضور | `my_attendance_screen.dart` | عرض سجل الحضور والغياب |
| موادي | `my_subjects_screen.dart` | عرض المواد المسجل فيها |
| التكاليف | `upload_assignment_screen.dart` | عرض التكاليف ورفع الملفات |

---

# 1️⃣ لوحة تحكم الطالب (StudentDashboardScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/student/student_dashboard_screen.dart` |
| **النوع** | `StatefulWidget` |
| **الصلاحيات** | الطالب فقط (role: student) |
| **قاعدة البيانات** | `watchStudentStats()` |

## هيكل التخطيط
```
Directionality (RTL)
└── Scaffold
    └── body: CustomScrollView
        └── slivers: [
            │
            ├── SliverToBoxAdapter [Header]
            │   └── Container (gradient: أزرق)
            │       └── Column
            │           ├── Row [AppBar]
            │           │   ├── Text "لوحة الطالب"
            │           │   └── IconButton [خروج]
            │           │
            │           └── _buildWelcomeCard
            │               └── Container (glass)
            │                   └── Row
            │                       ├── Column
            │                       │   ├── Text "مرحباً"
            │                       │   ├── Text [الاسم]
            │                       │   └── Container [badge الصف]
            │                       └── CircleAvatar [الحرف الأول]
            │
            ├── SliverToBoxAdapter [الإحصائيات]
            │   └── Padding
            │       └── Column
            │           ├── Text "إحصائياتي الأكاديمية"
            │           └── StreamBuilder<Map<String, dynamic>>
            │               └── Row
            │                   ├── _buildStatItem [المعدل]
            │                   ├── _buildStatItem [الحضور]
            │                   └── _buildStatItem [التكاليف]
            │
            └── SliverPadding [الإجراءات]
                └── SliverGrid (2 أعمدة)
                    ├── DashboardCard [درجاتي]
                    ├── DashboardCard [الحضور]
                    ├── DashboardCard [المواد]
                    └── DashboardCard [التكاليف]
        ]
```

## Widgets الرئيسية

### 1. StreamBuilder للإحصائيات
```dart
StreamBuilder<Map<String, dynamic>>(
  stream: FirestoreService.instance.watchStudentStats(
    AuthService.instance.currentUser!.uid,
  ),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return _buildErrorWidget(snapshot.error.toString());
    }
    
    if (!snapshot.hasData) {
      return _buildLoadingStats();
    }
    
    final stats = snapshot.data!;
    return Row(
      children: [
        Expanded(child: _buildStatItem(
          icon: Icons.grade,
          label: 'المعدل',
          value: '${stats['averageGrade']}%',
          color: _getGradeColor(stats['averageGrade']),
        )),
        Expanded(child: _buildStatItem(
          icon: Icons.check_circle,
          label: 'الحضور',
          value: '${stats['attendanceRate']}%',
          color: _getAttendanceColor(stats['attendanceRate']),
        )),
        Expanded(child: _buildStatItem(
          icon: Icons.assignment_turned_in,
          label: 'التكاليف',
          value: '${stats['completedAssignments']}',
          color: AppTheme.successColor,
        )),
      ],
    );
  },
)
```
| البند | التفاصيل |
|-------|---------|
| **stream** | `watchStudentStats()` - يحسب المعدل والحضور |
| **البيانات** | averageGrade, attendanceRate, completedAssignments |
| **التحديث** | تلقائي عند أي تغيير |

### 2. بطاقة الإحصائية الدائرية
```dart
Widget _buildStatItem({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 4),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
```

### 3. تلوين حسب القيمة
```dart
Color _getGradeColor(int grade) {
  if (grade >= 85) return AppTheme.successColor;   // أخضر
  if (grade >= 60) return AppTheme.warningColor;   // برتقالي
  return AppTheme.errorColor;                       // أحمر
}

Color _getAttendanceColor(int rate) {
  if (rate >= 75) return AppTheme.successColor;
  if (rate >= 50) return AppTheme.warningColor;
  return AppTheme.errorColor;
}
```

### 4. Badge الصف
```dart
Container(
  margin: EdgeInsets.only(top: 8),
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(20),
  ),
  child: FutureBuilder<ClassModel?>(
    future: FirestoreService.instance.getClassById(user.classId!),
    builder: (context, snapshot) {
      final className = snapshot.data?.name ?? 'جاري التحميل...';
      return Text(
        className,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      );
    },
  ),
)
```

---

# 2️⃣ شاشة درجاتي (MyGradesScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/student/my_grades_screen.dart` |
| **قاعدة البيانات** | `watchStudentGrades()` |

## هيكل التخطيط
```
Scaffold
└── body: CustomScrollView
    └── slivers: [
        │
        ├── SliverAppBar [Header]
        │   └── flexibleSpace: Container (gradient)
        │       └── Column
        │           ├── Text "درجاتي"
        │           └── _buildAverageCard
        │               └── Row
        │                   ├── Column [المعدل العام]
        │                   └── CircularProgressIndicator
        │
        └── StreamBuilder<List<GradeModel>>
            └── SliverList
                └── ExpansionTile (لكل مادة)
                    ├── leading: CircleAvatar [أيقونة]
                    ├── title: Text [اسم المادة]
                    ├── subtitle: Text [عدد الدرجات + المتوسط]
                    └── children:
                        └── Column
                            └── ListTile (لكل درجة)
                                ├── title: Text [نوع الاختبار]
                                ├── subtitle: Text [التاريخ]
                                └── trailing: _buildGradeBadge
```

## Widgets الرئيسية

### 1. تجميع الدرجات حسب المادة
```dart
Map<String, List<GradeModel>> _groupBySubject(List<GradeModel> grades) {
  final Map<String, List<GradeModel>> grouped = {};
  
  for (final grade in grades) {
    grouped.putIfAbsent(grade.subjectName, () => []).add(grade);
  }
  
  return grouped;
}
```
| البند | التفاصيل |
|-------|---------|
| **putIfAbsent** | يضيف القائمة إذا لم توجد |
| **النتيجة** | Map: اسم المادة → قائمة الدرجات |

### 2. ExpansionTile للمادة
```dart
ExpansionTile(
  leading: CircleAvatar(
    backgroundColor: _getSubjectColor(subjectName),
    child: Icon(Icons.book, color: Colors.white, size: 20),
  ),
  title: Text(
    subjectName,
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Text(
    '${grades.length} درجات • المتوسط: ${_calculateAverage(grades).toStringAsFixed(1)}%',
    style: TextStyle(color: Colors.grey[600]),
  ),
  children: grades.map((grade) => _buildGradeItem(grade)).toList(),
)
```

### 3. عنصر الدرجة
```dart
Widget _buildGradeItem(GradeModel grade) {
  return ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 24),
    title: Text(grade.examTypeName),  // الاختبار الشهري الأول
    subtitle: Text(
      DateFormat('d MMMM yyyy', 'ar').format(grade.createdAt),
    ),
    trailing: _buildGradeBadge(grade),
  );
}

Widget _buildGradeBadge(GradeModel grade) {
  final percentage = grade.percentage;
  final color = _getGradeColor(percentage.toInt());
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color),
    ),
    child: Text(
      '${grade.grade.toInt()}/${grade.maxGrade.toInt()}',
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
```

### 4. مؤشر المعدل الدائري
```dart
Stack(
  alignment: Alignment.center,
  children: [
    SizedBox(
      width: 80,
      height: 80,
      child: CircularProgressIndicator(
        value: averageGrade / 100,
        strokeWidth: 8,
        backgroundColor: Colors.white.withOpacity(0.3),
        valueColor: AlwaysStoppedAnimation<Color>(
          _getGradeColor(averageGrade.toInt()),
        ),
      ),
    ),
    Text(
      '${averageGrade.toInt()}%',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
)
```

---

# 3️⃣ شاشة سجل الحضور (MyAttendanceScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/student/my_attendance_screen.dart` |
| **قاعدة البيانات** | `watchStudentAttendance()` |

## هيكل التخطيط
```
Scaffold
└── body: CustomScrollView
    └── slivers: [
        │
        ├── SliverAppBar [Header]
        │   └── flexibleSpace:
        │       └── Column
        │           ├── Text "سجل الحضور"
        │           └── _buildAttendanceStats
        │               └── Row
        │                   ├── _StatBox [نسبة الحضور]
        │                   ├── _StatBox [أيام الحضور]
        │                   └── _StatBox [أيام الغياب]
        │
        └── StreamBuilder<List<AttendanceModel>>
            └── SliverList
                └── _buildAttendanceCard (لكل سجل)
                    └── Container
                        └── Row
                            ├── Container [أيقونة الحالة]
                            ├── Expanded
                            │   └── Column
                            │       ├── Text [اسم المادة]
                            │       └── Text [التاريخ]
                            └── _buildStatusBadge [الحالة]
```

## Widgets الرئيسية

### 1. إحصائيات الحضور
```dart
Widget _buildAttendanceStats(List<AttendanceModel> attendance) {
  final total = attendance.length;
  final present = attendance.where((a) => a.status == 'present').length;
  final absent = attendance.where((a) => a.status == 'absent').length;
  final rate = total > 0 ? (present / total * 100) : 0;
  
  return Container(
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(child: _StatBox(
          value: '${rate.toInt()}%',
          label: 'نسبة الحضور',
          icon: Icons.pie_chart,
        )),
        Container(width: 1, height: 40, color: Colors.white24),
        Expanded(child: _StatBox(
          value: '$present',
          label: 'أيام الحضور',
          icon: Icons.check_circle,
        )),
        Container(width: 1, height: 40, color: Colors.white24),
        Expanded(child: _StatBox(
          value: '$absent',
          label: 'أيام الغياب',
          icon: Icons.cancel,
        )),
      ],
    ),
  );
}
```

### 2. شريط التقدم
```dart
Widget _buildProgressBar(double rate) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('نسبة الحضور'),
          Text('${rate.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: rate / 100,
          minHeight: 12,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            rate >= 75 
              ? AppTheme.successColor 
              : rate >= 50 
                ? AppTheme.warningColor 
                : AppTheme.errorColor,
          ),
        ),
      ),
    ],
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **LinearProgressIndicator** | شريط تقدم أفقي |
| **value** | 0.0 إلى 1.0 |
| **ClipRRect** | تدوير الحواف |

### 3. بطاقة الحضور
```dart
Widget _buildAttendanceCard(AttendanceModel attendance) {
  final isPresent = attendance.status == 'present';
  final statusColor = _getStatusColor(attendance.status);
  
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // أيقونة الحالة
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: statusColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        
        // التفاصيل
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attendance.subjectName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('EEEE، d MMMM yyyy', 'ar')
                    .format(DateTime.parse(attendance.date)),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        
        // Badge الحالة
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            ArabicNames.getAttendanceStatus(attendance.status),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'present': return AppTheme.successColor;   // أخضر
    case 'absent':  return AppTheme.errorColor;     // أحمر
    case 'late':    return AppTheme.warningColor;   // برتقالي
    case 'excused': return AppTheme.infoColor;      // أزرق
    default:        return Colors.grey;
  }
}
```

---

# 4️⃣ شاشة موادي (MySubjectsScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/student/my_subjects_screen.dart` |
| **قاعدة البيانات** | `getAllSubjects()` مع فلترة |

## هيكل التخطيط
```
Scaffold
└── body: CustomScrollView
    └── slivers: [
        │
        ├── SliverAppBar [Header]
        │   └── Text "موادي الدراسية"
        │
        └── FutureBuilder<List<SubjectModel>>
            └── SliverPadding
                └── SliverGrid (2 أعمدة)
                    └── _buildSubjectCard (لكل مادة)
                        └── Container
                            └── Column
                                ├── CircleAvatar [أيقونة]
                                ├── Text [اسم المادة]
                                ├── Text [اسم المعلم]
                                └── Text [الوصف]
```

## Widgets الرئيسية

### 1. بطاقة المادة
```dart
Widget _buildSubjectCard(SubjectModel subject) {
  final color = _getSubjectColor(subject.name);
  
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // أيقونة المادة
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getSubjectIcon(subject.name),
            color: color,
            size: 32,
          ),
        ),
        SizedBox(height: 12),
        
        // اسم المادة
        Text(
          subject.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        
        // اسم المعلم
        Text(
          'أ. ${subject.teacherName}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        
        // الوصف (إن وجد)
        if (subject.description != null) ...[
          SizedBox(height: 8),
          Text(
            subject.description!,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    ),
  );
}
```

### 2. ألوان وأيقونات المواد
```dart
Color _getSubjectColor(String name) {
  final colors = [
    Color(0xFF2196F3),  // أزرق
    Color(0xFF4CAF50),  // أخضر
    Color(0xFFFF9800),  // برتقالي
    Color(0xFF9C27B0),  // بنفسجي
    Color(0xFFE91E63),  // وردي
    Color(0xFF00BCD4),  // سماوي
  ];
  return colors[name.hashCode.abs() % colors.length];
}

IconData _getSubjectIcon(String name) {
  if (name.contains('رياضيات')) return Icons.calculate;
  if (name.contains('علوم')) return Icons.science;
  if (name.contains('لغة')) return Icons.translate;
  if (name.contains('تاريخ')) return Icons.history_edu;
  if (name.contains('جغرافيا')) return Icons.public;
  if (name.contains('حاسب') || name.contains('برمجة')) return Icons.computer;
  return Icons.book;
}
```

---

# 5️⃣ شاشة التكاليف (UploadAssignmentScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/student/upload_assignment_screen.dart` |
| **قاعدة البيانات** | `watchClassAssignments()`, `addSubmission()` |
| **الحزم** | `file_picker` لاختيار الملفات |

## هيكل التخطيط
```
Scaffold
└── body: CustomScrollView
    └── slivers: [
        │
        ├── SliverAppBar [Header]
        │   └── Text "التكاليف والواجبات"
        │
        └── StreamBuilder<List<AssignmentModel>>
            └── SliverList
                └── _buildAssignmentCard (لكل تكليف)
                    └── Card
                        └── Column
                            ├── _buildAssignmentHeader
                            │   └── Row
                            │       ├── Expanded
                            │       │   └── Column
                            │       │       ├── Text [العنوان]
                            │       │       └── Text [المادة]
                            │       └── _buildDueDateChip
                            │
                            ├── Divider
                            │
                            ├── _buildAssignmentDetails
                            │   └── Column
                            │       ├── Row [تاريخ التسليم]
                            │       └── Text [الوصف]
                            │
                            └── _buildSubmissionButton
                                └── ElevatedButton أو Text [الحالة]
```

## Widgets الرئيسية

### 1. Chip تاريخ التسليم
```dart
Widget _buildDueDateChip(AssignmentModel assignment) {
  final dueDate = DateTime.parse(assignment.dueDate);
  final now = DateTime.now();
  final daysLeft = dueDate.difference(now).inDays;
  
  Color color;
  String text;
  
  if (daysLeft < 0) {
    color = Colors.grey;
    text = 'منتهي';
  } else if (daysLeft == 0) {
    color = AppTheme.errorColor;
    text = 'اليوم!';
  } else if (daysLeft <= 3) {
    color = AppTheme.warningColor;
    text = 'باقي $daysLeft أيام';
  } else {
    color = AppTheme.successColor;
    text = 'باقي $daysLeft يوم';
  }
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
```

### 2. زر التسليم/الحالة
```dart
Widget _buildSubmissionButton(
  AssignmentModel assignment, 
  SubmissionModel? submission,
) {
  if (assignment.isOverdue && submission == null) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: Colors.grey),
          SizedBox(width: 8),
          Text('انتهى الموعد', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
  
  if (submission != null) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: AppTheme.successColor),
          SizedBox(width: 8),
          Text(
            submission.isGraded 
              ? 'تم التقييم: ${submission.grade}'
              : 'تم التسليم',
            style: TextStyle(color: AppTheme.successColor),
          ),
        ],
      ),
    );
  }
  
  return ElevatedButton.icon(
    onPressed: () => _showUploadDialog(assignment),
    icon: Icon(Icons.upload_file),
    label: Text('رفع التسليم'),
    style: ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, 45),
    ),
  );
}
```

### 3. نافذة رفع الملف
```dart
void _showUploadDialog(AssignmentModel assignment) {
  String? _selectedFileName;
  String? _selectedFilePath;
  final _notesController = TextEditingController();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                'تسليم: ${assignment.title}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              // زر اختيار الملف
              InkWell(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
                  );
                  if (result != null) {
                    setSheetState(() {
                      _selectedFileName = result.files.single.name;
                      _selectedFilePath = result.files.single.path;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedFileName != null 
                        ? AppTheme.successColor 
                        : Colors.grey,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedFileName != null 
                          ? Icons.insert_drive_file 
                          : Icons.upload_file,
                        color: _selectedFileName != null 
                          ? AppTheme.successColor 
                          : Colors.grey,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFileName ?? 'اختر ملف للرفع',
                          style: TextStyle(
                            color: _selectedFileName != null 
                              ? Colors.black 
                              : Colors.grey,
                          ),
                        ),
                      ),
                      if (_selectedFileName != null)
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey),
                          onPressed: () => setSheetState(() {
                            _selectedFileName = null;
                            _selectedFilePath = null;
                          }),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              
              // ملاحظات
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              
              // زر الإرسال
              ElevatedButton(
                onPressed: _selectedFileName == null 
                  ? null 
                  : () => _submitAssignment(
                      assignment, 
                      _selectedFilePath!, 
                      _notesController.text,
                    ),
                child: Text('إرسال التسليم'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    ),
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **StatefulBuilder** | لتحديث حالة BottomSheet |
| **FilePicker** | مكتبة اختيار الملفات |
| **allowedExtensions** | أنواع الملفات المسموحة |

### 4. إرسال التسليم
```dart
Future<void> _submitAssignment(
  AssignmentModel assignment,
  String filePath,
  String notes,
) async {
  setState(() => _isLoading = true);
  
  try {
    final user = AuthService.instance.currentUser!;
    
    // في التطبيق الحقيقي: رفع الملف لـ Firebase Storage
    // final fileUrl = await _uploadFile(filePath);
    
    final submission = SubmissionModel(
      id: '',
      assignmentId: assignment.id,
      studentId: user.uid,
      studentName: user.name,
      fileUrl: filePath,  // في الحقيقة: fileUrl
      fileName: filePath.split('/').last,
      notes: notes.isNotEmpty ? notes : null,
      status: 'submitted',
      submittedAt: DateTime.now(),
    );
    
    await FirestoreService.instance.addSubmission(
      assignment.id,
      submission,
    );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال التسليم بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('خطأ: $e'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

# 🔗 العلاقات بين الشاشات

```
                    ┌─────────────────────┐
                    │  StudentDashboard   │
                    │  (الشاشة الرئيسية)  │
                    └──────────┬──────────┘
                               │
        ┌──────────┬───────────┼───────────┬──────────┐
        ▼          ▼           ▼           ▼          
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ درجاتي │ │ الحضور  │ │ المواد  │ │التكاليف │
   └─────────┘ └─────────┘ └─────────┘ └────┬────┘
                                            │
                                       ┌────▼────┐
                                       │رفع ملف │
                                       └─────────┘
```

---

# 🗄️ علاقة قاعدة البيانات

| الشاشة | القراءة | الكتابة |
|--------|---------|---------|
| Dashboard | `watchStudentStats()` | - |
| MyGrades | `watchStudentGrades()` | - |
| MyAttendance | `watchStudentAttendance()` | - |
| MySubjects | `getAllSubjects()` | - |
| Assignments | `watchClassAssignments()` | `addSubmission()` |

---

# 🎨 ملخص التصميم

| العنصر | التصميم |
|--------|---------|
| **اللون الرئيسي** | `AppTheme.studentColor` (أزرق) |
| **Header** | تدرج أزرق + بطاقة glass |
| **البطاقات** | زوايا مدورة 16px + ظلال ملونة |
| **الإحصائيات** | بطاقات دائرية + ألوان حسب القيمة |
| **القوائم** | ExpansionTile للدرجات، ListView للحضور |
| **الحالات** | ألوان: أخضر/برتقالي/أحمر |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
