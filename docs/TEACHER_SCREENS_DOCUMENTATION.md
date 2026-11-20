# 👨‍🏫 شرح تفصيلي لشاشات المعلم (Teacher Screens)

---

# 📊 نظرة عامة

| الشاشة | الملف | الوظيفة |
|--------|-------|---------|
| لوحة التحكم | `teacher_dashboard_screen.dart` | الإحصائيات والإجراءات السريعة |
| تسجيل الحضور | `attendance_screen.dart` | تسجيل حضور/غياب الطلاب |
| رصد الدرجات | `grades_screen.dart` | إدخال درجات الطلاب |
| قائمة الطلاب | `students_list_screen.dart` | عرض طلاب الصفوف |
| التكاليف | `teacher_assignments_screen.dart` | إنشاء وإدارة الواجبات |

---

# 1️⃣ لوحة تحكم المعلم (TeacherDashboardScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/teacher/teacher_dashboard_screen.dart` |
| **النوع** | `StatefulWidget` |
| **الصلاحيات** | المعلم فقط (role: teacher) |
| **قاعدة البيانات** | `Rx.combineLatest3` لدمج 3 Streams |

## هيكل التخطيط
```
Directionality (RTL)
└── Scaffold
    └── body: CustomScrollView
        └── slivers: [
            │
            ├── SliverToBoxAdapter [Header]
            │   └── Container (gradient)
            │       └── Column
            │           ├── Row [AppBar]
            │           │   ├── Text "لوحة المعلم"
            │           │   └── IconButton [خروج]
            │           └── _buildWelcomeCard
            │               └── Container (glass effect)
            │                   └── Row
            │                       ├── Column [الاسم + الترحيب]
            │                       └── CircleAvatar [صورة]
            │
            ├── SliverToBoxAdapter [الإحصائيات]
            │   └── StreamBuilder
            │       └── GridView.count (2 أعمدة)
            │           ├── StatCard [المواد]
            │           ├── StatCard [الصفوف]
            │           ├── StatCard [الطلاب]
            │           └── StatCard [التكاليف]
            │
            └── SliverPadding [الإجراءات]
                └── SliverGrid
                    ├── DashboardCard [الحضور]
                    ├── DashboardCard [الدرجات]
                    ├── DashboardCard [الطلاب]
                    └── DashboardCard [التكاليف]
        ]
```

## Widgets الرئيسية

### 1. Rx.combineLatest3 (دمج Streams)
```dart
late Stream<Map<String, dynamic>> _statsStream;

@override
void initState() {
  super.initState();
  final uid = AuthService.instance.currentUser!.uid;
  
  _statsStream = Rx.combineLatest3(
    FirestoreService.instance.watchTeacherSubjects(uid),
    FirestoreService.instance.watchTeacherClasses(uid),
    FirestoreService.instance.watchTeacherAssignments(uid),
    (List<SubjectModel> subjects, 
     List<ClassModel> classes, 
     List<AssignmentModel> assignments) {
      
      // حساب إجمالي الطلاب
      final totalStudents = classes.fold(0, (sum, c) => sum + c.studentCount);
      
      return {
        'subjects': subjects.length,
        'classes': classes.length,
        'assignments': assignments.length,
        'students': totalStudents,
      };
    },
  );
}
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | دالة من RxDart تدمج 3 Streams |
| **وظيفته** | حساب الإحصائيات من مصادر متعددة |
| **التحديث** | تلقائي عند تغير أي Stream |
| **البديل** | 3 StreamBuilder متداخلة (أسوأ) |

### 2. بطاقة الترحيب (Glass Effect)
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.15),  // شفافية
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
    ),
  ),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً،', style: TextStyle(color: Colors.white70)),
            Text(userName, style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
      CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Text(userName[0], style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        )),
      ),
    ],
  ),
)
```
| البند | التفاصيل |
|-------|---------|
| **Glass Effect** | خلفية شفافة + حدود شفافة |
| **withOpacity** | جعل اللون شفافاً |
| **علاقة UX** | تصميم عصري وجذاب |

---

# 2️⃣ شاشة الحضور (AttendanceScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/teacher/attendance_screen.dart` |
| **النوع** | `StatefulWidget` |
| **قاعدة البيانات** | `watchTeacherClasses()`, `watchTeacherSubjects()`, `watchStudentsByClass()`, `addAttendance()` |

## هيكل التخطيط
```
Scaffold
└── body: Column
    │
    ├── Container [Header متدرج]
    │   └── Column
    │       ├── Text "تسجيل الحضور"
    │       └── _buildDateSelector
    │           └── InkWell
    │               └── Row
    │                   ├── Icon (calendar)
    │                   ├── Text (التاريخ)
    │                   └── Icon (arrow)
    │
    ├── _buildFilters [فلاتر]
    │   └── Padding
    │       └── Row
    │           ├── Expanded
    │           │   └── DropdownButtonFormField [الصف]
    │           ├── SizedBox
    │           └── Expanded
    │               └── DropdownButtonFormField [المادة]
    │
    └── Expanded
        └── _buildStudentsList
            └── StreamBuilder<List<UserModel>>
                └── ListView.builder
                    └── _buildStudentCard (لكل طالب)
                        └── Container
                            └── Row
                                ├── CircleAvatar
                                ├── Expanded [اسم الطالب]
                                └── Row [أزرار الحالة]
                                    ├── _StatusButton [حاضر]
                                    ├── _StatusButton [غائب]
                                    ├── _StatusButton [متأخر]
                                    └── _StatusButton [مستأذن]

    bottomNavigationBar: [شرطي]
        └── Container
            └── ElevatedButton [حفظ الحضور]
```

## Widgets الرئيسية

### 1. اختيار التاريخ
```dart
InkWell(
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),  // عربي
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.teacherColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  },
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today, color: Colors.white),
        SizedBox(width: 8),
        Text(
          DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDate),
          style: TextStyle(color: Colors.white),
        ),
        Icon(Icons.arrow_drop_down, color: Colors.white),
      ],
    ),
  ),
)
```
| البند | التفاصيل |
|-------|---------|
| **showDatePicker** | نافذة اختيار التاريخ |
| **locale: 'ar'** | أسماء الأيام والأشهر بالعربي |
| **DateFormat** | تنسيق التاريخ |
| **builder** | تخصيص ألوان النافذة |

### 2. أزرار حالة الحضور
```dart
class _StatusButton extends StatelessWidget {
  final String status;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```
| البند | التفاصيل |
|-------|---------|
| **AnimatedContainer** | تأثير حركي عند التغيير |
| **isSelected** | هل هذا الزر محدد؟ |
| **الألوان** | أخضر=حاضر، أحمر=غائب، برتقالي=متأخر |

### 3. إدارة حالة الحضور
```dart
// Map لتخزين حالة كل طالب
Map<String, String> _attendanceStatus = {};

void _setStatus(String studentId, String status) {
  setState(() {
    _attendanceStatus[studentId] = status;
  });
}

// عند البناء
_StatusButton(
  status: 'present',
  label: 'حاضر',
  color: AppTheme.successColor,
  isSelected: _attendanceStatus[student.uid] == 'present',
  onTap: () => _setStatus(student.uid, 'present'),
),
```

### 4. حفظ الحضور
```dart
Future<void> _saveAttendance() async {
  if (_selectedClassId == null || _selectedSubjectId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('يرجى اختيار الصف والمادة')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    for (final entry in _attendanceStatus.entries) {
      final studentId = entry.key;
      final status = entry.value;
      
      // البحث عن اسم الطالب
      final student = _students.firstWhere((s) => s.uid == studentId);
      
      await FirestoreService.instance.addAttendance(
        AttendanceModel(
          studentId: studentId,
          studentName: student.name,
          classId: _selectedClassId!,
          subjectId: _selectedSubjectId!,
          subjectName: _selectedSubjectName!,
          teacherId: AuthService.instance.currentUser!.uid,
          date: dateStr,
          status: status,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الحضور بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

# 3️⃣ شاشة الدرجات (GradesScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/teacher/grades_screen.dart` |
| **قاعدة البيانات** | `watchTeacherClasses()`, `watchTeacherSubjects()`, `watchStudentsByClass()`, `addGrade()` |

## هيكل التخطيط
```
Scaffold
└── body: Column
    │
    ├── Container [Header]
    │   └── Column
    │       └── Text "رصد الدرجات"
    │
    ├── _buildFilters
    │   └── Column
    │       ├── Row
    │       │   ├── DropdownButtonFormField [الصف]
    │       │   └── DropdownButtonFormField [المادة]
    │       └── DropdownButtonFormField [نوع الاختبار]
    │           └── items: [شهري1, شهري2, نهائي]
    │
    ├── _buildAverageCard [شرطي]
    │   └── Container
    │       └── Row
    │           ├── Text "متوسط الصف:"
    │           └── Text (المتوسط)
    │
    └── Expanded
        └── StreamBuilder<List<UserModel>>
            └── ListView.builder
                └── _buildStudentGradeCard
                    └── Container
                        └── Row
                            ├── CircleAvatar
                            ├── Expanded [الاسم]
                            └── SizedBox (width: 80)
                                └── TextFormField [الدرجة]

    bottomNavigationBar:
        └── ElevatedButton [حفظ الدرجات]
```

## Widgets الرئيسية

### 1. اختيار نوع الاختبار
```dart
DropdownButtonFormField<String>(
  value: _selectedExamType,
  decoration: InputDecoration(
    labelText: 'نوع الاختبار',
    prefixIcon: Icon(Icons.quiz),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  items: [
    DropdownMenuItem(
      value: 'monthly1',
      child: Text('الاختبار الشهري الأول'),
    ),
    DropdownMenuItem(
      value: 'monthly2',
      child: Text('الاختبار الشهري الثاني'),
    ),
    DropdownMenuItem(
      value: 'final',
      child: Text('الاختبار النهائي'),
    ),
  ],
  onChanged: (value) => setState(() => _selectedExamType = value),
)
```

### 2. حقل إدخال الدرجة
```dart
// Map لتخزين الدرجات
Map<String, TextEditingController> _gradeControllers = {};

// إنشاء controller لكل طالب
TextEditingController _getController(String studentId) {
  if (!_gradeControllers.containsKey(studentId)) {
    _gradeControllers[studentId] = TextEditingController();
  }
  return _gradeControllers[studentId]!;
}

// حقل الإدخال
SizedBox(
  width: 80,
  child: TextFormField(
    controller: _getController(student.uid),
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    decoration: InputDecoration(
      hintText: '0-100',
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return null; // اختياري
      final grade = double.tryParse(value);
      if (grade == null || grade < 0 || grade > 100) {
        return '0-100';
      }
      return null;
    },
  ),
)
```

### 3. حساب المتوسط
```dart
double _calculateAverage() {
  final grades = _gradeControllers.values
      .map((c) => double.tryParse(c.text))
      .where((g) => g != null)
      .cast<double>()
      .toList();
  
  if (grades.isEmpty) return 0;
  return grades.reduce((a, b) => a + b) / grades.length;
}

// عرض المتوسط
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: _getAverageColor(_calculateAverage()),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('متوسط الصف:', style: TextStyle(fontWeight: FontWeight.bold)),
      Text(
        '${_calculateAverage().toStringAsFixed(1)}%',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  ),
)

Color _getAverageColor(double avg) {
  if (avg >= 85) return AppTheme.successColor.withOpacity(0.2);
  if (avg >= 60) return AppTheme.warningColor.withOpacity(0.2);
  return AppTheme.errorColor.withOpacity(0.2);
}
```

---

# 4️⃣ قائمة الطلاب (StudentsListScreen)

## هيكل التخطيط
```
Scaffold
├── appBar: AppBar
│   └── bottom: PreferredSize
│       └── TextField [البحث]
│
└── body: Column
    │
    ├── DropdownButtonFormField [اختيار الصف]
    │
    └── Expanded
        └── StreamBuilder<List<UserModel>>
            └── ListView.builder
                └── _buildStudentCard
                    └── Card
                        └── ListTile
                            ├── leading: CircleAvatar
                            ├── title: Text [الاسم]
                            ├── subtitle: Text [البريد]
                            └── trailing: Icon (arrow)
```

## Widgets الرئيسية

### 1. شريط البحث
```dart
AppBar(
  title: Text('قائمة الطلاب'),
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو البريد...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    ),
  ),
)
```

### 2. فلترة الطلاب
```dart
List<UserModel> _filterStudents(List<UserModel> students) {
  final query = _searchController.text.toLowerCase();
  
  return students.where((student) {
    final nameMatch = student.name.toLowerCase().contains(query);
    final emailMatch = student.email.toLowerCase().contains(query);
    return nameMatch || emailMatch;
  }).toList();
}
```

---

# 5️⃣ شاشة التكاليف (TeacherAssignmentsScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/teacher/teacher_assignments_screen.dart` |
| **قاعدة البيانات** | `watchTeacherAssignments()`, `addAssignment()`, `watchAssignmentSubmissions()` |

## هيكل التخطيط
```
Scaffold
├── floatingActionButton: FAB [إضافة تكليف]
│
└── body: CustomScrollView
    └── slivers: [
        │
        ├── SliverAppBar [Header]
        │
        └── StreamBuilder<List<AssignmentModel>>
            └── SliverList
                └── _buildAssignmentCard (لكل تكليف)
                    └── Card
                        └── Column
                            ├── ListTile
                            │   ├── title: Text [العنوان]
                            │   ├── subtitle: Column
                            │   │   ├── Text [المادة]
                            │   │   └── Text [تاريخ التسليم]
                            │   └── trailing: Chip [الحالة]
                            │
                            └── ButtonBar
                                ├── TextButton [التسليمات]
                                └── TextButton [حذف]
    ]
```

## Widgets الرئيسية

### 1. بطاقة التكليف
```dart
Card(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Column(
    children: [
      ListTile(
        title: Text(
          assignment.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.book, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(assignment.subjectName),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('التسليم: ${assignment.dueDate}'),
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(assignment),
      ),
      Divider(),
      ButtonBar(
        children: [
          TextButton.icon(
            icon: Icon(Icons.people),
            label: Text('التسليمات'),
            onPressed: () => _showSubmissions(assignment),
          ),
          TextButton.icon(
            icon: Icon(Icons.delete, color: Colors.red),
            label: Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () => _deleteAssignment(assignment),
          ),
        ],
      ),
    ],
  ),
)
```

### 2. Chip الحالة
```dart
Widget _buildStatusChip(AssignmentModel assignment) {
  final isOverdue = assignment.isOverdue;
  
  return Chip(
    label: Text(
      isOverdue ? 'منتهي' : 'نشط',
      style: TextStyle(
        color: isOverdue ? Colors.white : AppTheme.successColor,
        fontSize: 12,
      ),
    ),
    backgroundColor: isOverdue 
      ? Colors.grey 
      : AppTheme.successColor.withOpacity(0.1),
  );
}
```

### 3. نموذج إضافة تكليف
```dart
void _showAddAssignmentDialog() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Form(
        key: _formKey,
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
            
            Text('إضافة تكليف جديد', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
            )),
            SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'عنوان التكليف'),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            SizedBox(height: 12),
            
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'الوصف'),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            
            // اختيار المادة
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'المادة'),
              items: _subjects.map((s) => 
                DropdownMenuItem(value: s.id, child: Text(s.name))
              ).toList(),
              onChanged: (v) => _selectedSubjectId = v,
            ),
            SizedBox(height: 12),
            
            // اختيار الصف
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'الصف'),
              items: _classes.map((c) => 
                DropdownMenuItem(value: c.id, child: Text(c.name))
              ).toList(),
              onChanged: (v) => _selectedClassId = v,
            ),
            SizedBox(height: 12),
            
            // اختيار تاريخ التسليم
            InkWell(
              onTap: _selectDueDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'تاريخ التسليم'),
                child: Text(_dueDate != null 
                  ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                  : 'اختر التاريخ'
                ),
              ),
            ),
            SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _saveAssignment,
              child: Text('حفظ'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
```

### 4. عرض التسليمات
```dart
void _showSubmissions(AssignmentModel assignment) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                child: Text('تسليمات: ${assignment.title}'),
              ),
              
              // القائمة
              Expanded(
                child: StreamBuilder<List<SubmissionModel>>(
                  stream: FirestoreService.instance
                      .watchAssignmentSubmissions(assignment.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    
                    final submissions = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: submissions.length,
                      itemBuilder: (context, index) {
                        final sub = submissions[index];
                        return ListTile(
                          title: Text(sub.studentName),
                          subtitle: Text(sub.fileName ?? 'بدون ملف'),
                          trailing: sub.isGraded
                            ? Text('${sub.grade}')
                            : ElevatedButton(
                                child: Text('تقييم'),
                                onPressed: () => _gradeSubmission(sub),
                              ),
                        );
                      },
                    );
                  },
                ),
              ),
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
| **DraggableScrollableSheet** | ورقة قابلة للسحب |
| **initialChildSize** | الحجم الابتدائي (70%) |
| **minChildSize** | أصغر حجم (50%) |
| **maxChildSize** | أكبر حجم (95%) |

---

# 🔗 العلاقات بين الشاشات

```
                    ┌─────────────────────┐
                    │  TeacherDashboard   │
                    │  (الشاشة الرئيسية)  │
                    └──────────┬──────────┘
                               │
        ┌──────────┬───────────┼───────────┬──────────┐
        ▼          ▼           ▼           ▼          ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │ الحضور  │ │ الدرجات │ │ الطلاب  │ │التكاليف │
   └─────────┘ └─────────┘ └─────────┘ └────┬────┘
                                            │
                                       ┌────▼────┐
                                       │التسليمات│
                                       └─────────┘
```

---

# 🗄️ علاقة قاعدة البيانات

| الشاشة | القراءة (Stream) | الكتابة |
|--------|-----------------|---------|
| Dashboard | `watchTeacherSubjects()`, `watchTeacherClasses()`, `watchTeacherAssignments()` | - |
| Attendance | `watchTeacherClasses()`, `watchTeacherSubjects()`, `watchStudentsByClass()` | `addAttendance()` |
| Grades | `watchTeacherClasses()`, `watchTeacherSubjects()`, `watchStudentsByClass()` | `addGrade()` |
| Students | `watchTeacherClasses()`, `watchStudentsByClass()` | - |
| Assignments | `watchTeacherAssignments()`, `watchAssignmentSubmissions()` | `addAssignment()`, `deleteAssignment()` |

---

# 🎨 ملخص التصميم

| العنصر | التصميم |
|--------|---------|
| **اللون الرئيسي** | `AppTheme.teacherColor` (برتقالي) |
| **Header** | تدرج برتقالي + بطاقة ترحيب glass |
| **البطاقات** | زوايا مدورة 16px + ظل |
| **الفلاتر** | DropdownButtonFormField في Row |
| **القوائم** | ListView.builder + بطاقات مخصصة |
| **الحالات** | أزرار ملونة (أخضر/أحمر/برتقالي) |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
