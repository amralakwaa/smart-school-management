# 👨‍💼 شرح تفصيلي لشاشات المدير (Admin Screens)

---

# 📊 نظرة عامة

| الشاشة | الملف | الوظيفة |
|--------|-------|---------|
| لوحة التحكم | `admin_dashboard_screen.dart` | الصفحة الرئيسية + الإحصائيات |
| إدارة المستخدمين | `users_management_screen.dart` | عرض/حذف المستخدمين |
| إضافة/تعديل مستخدم | `add_edit_user_screen.dart` | نموذج إنشاء وتعديل |
| إدارة الصفوف | `classes_management_screen.dart` | إدارة الصفوف الدراسية |
| إدارة المواد | `subjects_management_screen.dart` | إدارة المواد والمعلمين |
| التقارير | `reports_screen.dart` | إحصائيات شاملة |

---

# 1️⃣ لوحة تحكم المدير (AdminDashboardScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/admin/admin_dashboard_screen.dart` |
| **النوع** | `StatefulWidget` |
| **الصلاحيات** | المدير فقط (role: admin) |
| **قاعدة البيانات** | `watchStatistics()`, `watchAllUsers()` |

## هيكل التخطيط
```
Directionality (RTL)
└── Scaffold
    └── body: CustomScrollView
        └── slivers: [
            │
            ├── SliverToBoxAdapter
            │   └── Container [Header متدرج]
            │       └── Column
            │           ├── Row [AppBar مخصص]
            │           │   ├── Text "لوحة التحكم"
            │           │   └── IconButton [تسجيل خروج]
            │           └── Text "مرحباً، المدير"
            │
            ├── SliverToBoxAdapter
            │   └── Padding
            │       └── StreamBuilder [الإحصائيات]
            │           └── GridView.count (2 أعمدة)
            │               ├── StatCard [المستخدمين]
            │               ├── StatCard [المعلمين]
            │               ├── StatCard [الطلاب]
            │               └── StatCard [المواد]
            │
            ├── SliverToBoxAdapter
            │   └── Padding
            │       └── Text "الإجراءات السريعة"
            │
            └── SliverPadding
                └── SliverGrid (2 أعمدة)
                    ├── DashboardCard [إدارة المستخدمين]
                    ├── DashboardCard [إدارة الصفوف]
                    ├── DashboardCard [إدارة المواد]
                    └── DashboardCard [التقارير]
        ]
```

## Widgets الرئيسية

### 1. CustomScrollView
```dart
CustomScrollView(
  physics: const BouncingScrollPhysics(),
  slivers: [...],
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة تمرير تدعم Slivers |
| **لماذا؟** | لدمج Header ثابت مع محتوى قابل للتمرير |
| **البديل** | `ListView` (لا يدعم Slivers) |

### 2. SliverToBoxAdapter
```dart
SliverToBoxAdapter(
  child: Container(...),
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يحول Widget عادي لـ Sliver |
| **لماذا؟** | CustomScrollView يقبل Slivers فقط |

### 3. StreamBuilder للإحصائيات
```dart
StreamBuilder<Map<String, int>>(
  stream: FirestoreService.instance.watchStatistics(),
  builder: (context, snapshot) {
    if (snapshot.hasError) return ErrorWidget();
    if (!snapshot.hasData) return LoadingWidget();
    
    final stats = snapshot.data!;
    return GridView.count(
      crossAxisCount: 2,
      children: [
        StatCard(title: 'المستخدمين', value: stats['totalUsers']!),
        StatCard(title: 'المعلمين', value: stats['teachers']!),
        // ...
      ],
    );
  },
)
```
| البند | التفاصيل |
|-------|---------|
| **stream** | `watchStatistics()` من FirestoreService |
| **البيانات** | Map يحتوي: totalUsers, teachers, students, subjects, classes |
| **التحديث** | تلقائي عند أي تغيير في Firestore |

### 4. StatCard (بطاقة إحصائية)
```dart
StatCard(
  icon: Icons.people,
  iconColor: AppTheme.primaryColor,
  title: 'إجمالي المستخدمين',
  value: 150,
)
```
| البند | التفاصيل |
|-------|---------|
| **الموقع** | `lib/widgets/dashboard_card.dart` |
| **الخصائص** | `icon`, `iconColor`, `title`, `value` |
| **التصميم** | Container بظل + Row (أيقونة + Column نصوص) |

### 5. DashboardCard (بطاقة إجراء)
```dart
DashboardCard(
  icon: Icons.manage_accounts,
  title: 'إدارة المستخدمين',
  subtitle: 'إضافة وتعديل المستخدمين',
  color: AppTheme.adminColor,
  onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
)
```
| البند | التفاصيل |
|-------|---------|
| **الخصائص** | `icon`, `title`, `subtitle`, `color`, `onTap`, `badge` |
| **badge** | رقم اختياري يظهر في الزاوية |

---

# 2️⃣ إدارة المستخدمين (UsersManagementScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/admin/users_management_screen.dart` |
| **النوع** | `StatefulWidget` |
| **قاعدة البيانات** | `watchAllUsers()`, `deleteUser()` |

## هيكل التخطيط
```
Scaffold
├── appBar: AppBar
│   └── actions: [IconButton بحث, IconButton إضافة]
│
└── body: Column
    │
    ├── Padding
    │   └── Row [فلاتر الأدوار]
    │       ├── FilterChip [الكل]
    │       ├── FilterChip [المدراء]
    │       ├── FilterChip [المعلمين]
    │       └── FilterChip [الطلاب]
    │
    └── Expanded
        └── StreamBuilder<List<UserModel>>
            └── ListView.builder
                └── UserCard (لكل مستخدم)
                    └── ListTile
                        ├── leading: CircleAvatar
                        ├── title: Text (الاسم)
                        ├── subtitle: Text (البريد + الدور)
                        └── trailing: PopupMenuButton
                            ├── تعديل
                            └── حذف
```

## Widgets الرئيسية

### 1. FilterChip (فلتر الأدوار)
```dart
FilterChip(
  label: Text('المعلمين'),
  selected: _selectedRole == 'teacher',
  onSelected: (selected) {
    setState(() => _selectedRole = selected ? 'teacher' : null);
  },
  selectedColor: AppTheme.teacherColor.withOpacity(0.2),
  checkmarkColor: AppTheme.teacherColor,
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | شريحة قابلة للاختيار |
| **وظيفته** | فلترة المستخدمين حسب الدور |
| **البديل** | `ChoiceChip`, `ToggleButtons` |
| **علاقة UX** | تصفية سريعة بنقرة واحدة |

### 2. ListView.builder
```dart
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    final user = users[index];
    return UserCard(user: user);
  },
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة تُبنى حسب الطلب |
| **لماذا؟** | أداء أفضل للقوائم الطويلة |
| **البديل** | `ListView(children: [...])` للقوائم القصيرة |

### 3. ListTile
```dart
ListTile(
  leading: CircleAvatar(
    backgroundColor: AppTheme.getRoleColor(user.role),
    child: Text(user.name[0]),
  ),
  title: Text(user.name),
  subtitle: Text('${user.email}\n${ArabicNames.getRoleName(user.role)}'),
  isThreeLine: true,
  trailing: PopupMenuButton<String>(...),
  onTap: () => _showUserDetails(user),
)
```
| البند | التفاصيل |
|-------|---------|
| **leading** | عنصر في البداية (صورة/أيقونة) |
| **title** | العنوان الرئيسي |
| **subtitle** | نص ثانوي |
| **trailing** | عنصر في النهاية |
| **isThreeLine** | يسمح بسطرين في subtitle |

### 4. PopupMenuButton
```dart
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert),
  onSelected: (value) {
    if (value == 'edit') _editUser(user);
    if (value == 'delete') _confirmDelete(user);
  },
  itemBuilder: (context) => [
    PopupMenuItem(value: 'edit', child: Row(...)),
    PopupMenuItem(value: 'delete', child: Row(...)),
  ],
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة منبثقة |
| **وظيفته** | خيارات للعنصر (تعديل/حذف) |
| **البديل** | `showModalBottomSheet` |

### 5. AlertDialog للحذف
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('تأكيد الحذف'),
    content: Text('هل تريد حذف ${user.name}؟'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await FirestoreService.instance.deleteUser(user.uid);
          Navigator.pop(context);
        },
        child: Text('حذف'),
      ),
    ],
  ),
);
```
| البند | التفاصيل |
|-------|---------|
| **علاقة UX** | تأكيد قبل الحذف (Error Prevention) |
| **علاقة DB** | `deleteUser()` - Soft Delete |

---

# 3️⃣ إضافة/تعديل مستخدم (AddEditUserScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/admin/add_edit_user_screen.dart` |
| **النوع** | `StatefulWidget` |
| **الوضعين** | إضافة (user == null) / تعديل (user != null) |
| **قاعدة البيانات** | `createUser()`, `updateUser()` |

## هيكل التخطيط
```
Scaffold
├── appBar: AppBar
│   └── title: "إضافة مستخدم" أو "تعديل مستخدم"
│
└── body: Form
    └── SingleChildScrollView
        └── Padding
            └── Column
                │
                ├── TextFormField [الاسم]
                ├── TextFormField [البريد]
                ├── TextFormField [كلمة المرور] (إضافة فقط)
                ├── TextFormField [الهاتف]
                │
                ├── DropdownButtonFormField [الدور]
                │   └── items: [admin, teacher, student]
                │
                ├── [شرطي: إذا teacher]
                │   └── MultiSelectChip [المواد]
                │
                ├── [شرطي: إذا student]
                │   └── DropdownButtonFormField [الصف]
                │
                ├── SizedBox
                │
                └── ElevatedButton [حفظ]
```

## Widgets الرئيسية

### 1. DropdownButtonFormField (اختيار الدور)
```dart
DropdownButtonFormField<String>(
  value: _selectedRole,
  decoration: InputDecoration(
    labelText: 'الدور',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  items: [
    DropdownMenuItem(value: 'admin', child: Text('مدير')),
    DropdownMenuItem(value: 'teacher', child: Text('معلم')),
    DropdownMenuItem(value: 'student', child: Text('طالب')),
  ],
  onChanged: (value) => setState(() => _selectedRole = value),
  validator: (value) => value == null ? 'يرجى اختيار الدور' : null,
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة منسدلة مع Form |
| **value** | القيمة المحددة حالياً |
| **items** | قائمة الخيارات |
| **onChanged** | عند تغيير الاختيار |
| **validator** | التحقق من الاختيار |

### 2. MultiSelectChip (اختيار المواد للمعلم)
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: subjects.map((subject) {
    final isSelected = _selectedSubjectIds.contains(subject.id);
    return FilterChip(
      label: Text(subject.name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedSubjectIds.add(subject.id);
          } else {
            _selectedSubjectIds.remove(subject.id);
          }
        });
      },
    );
  }).toList(),
)
```
| البند | التفاصيل |
|-------|---------|
| **Wrap** | يلف العناصر للسطر التالي |
| **FilterChip** | شريحة قابلة للاختيار |
| **spacing** | المسافة الأفقية |
| **runSpacing** | المسافة العمودية |

### 3. الحقول الشرطية
```dart
// يظهر فقط للمعلم
if (_selectedRole == 'teacher') ...[
  Text('المواد'),
  StreamBuilder<List<SubjectModel>>(
    stream: FirestoreService.instance.watchAllSubjects(),
    builder: (context, snapshot) => MultiSelectChips(...),
  ),
],

// يظهر فقط للطالب
if (_selectedRole == 'student') ...[
  DropdownButtonFormField<String>(
    decoration: InputDecoration(labelText: 'الصف'),
    items: classes.map((c) => DropdownMenuItem(...)).toList(),
    ...
  ),
],
```
| البند | التفاصيل |
|-------|---------|
| **الشرط** | `if (condition) ...[widgets]` |
| **Spread** | `...[]` لإضافة عناصر متعددة |
| **علاقة UX** | إظهار الحقول المناسبة فقط |

### 4. زر الحفظ
```dart
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: _isLoading ? null : _saveUser,
    child: _isLoading
      ? CircularProgressIndicator(color: Colors.white)
      : Text(widget.user == null ? 'إضافة' : 'تحديث'),
  ),
)
```

### 5. دالة الحفظ
```dart
Future<void> _saveUser() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    if (widget.user == null) {
      // إضافة مستخدم جديد
      await AuthService.instance.createUser(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        role: _selectedRole!,
        classId: _selectedClassId,
        subjectIds: _selectedSubjectIds,
      );
    } else {
      // تحديث مستخدم موجود
      await FirestoreService.instance.updateUser(
        widget.user!.copyWith(
          name: _nameController.text,
          phone: _phoneController.text,
          classId: _selectedClassId,
          subjectIds: _selectedSubjectIds,
        ),
      );
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(...);
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

# 4️⃣ إدارة الصفوف (ClassesManagementScreen)

## هيكل التخطيط
```
Scaffold
├── appBar: AppBar
│   └── actions: [IconButton إضافة]
│
├── floatingActionButton: FAB [إضافة صف]
│
└── body: StreamBuilder<List<ClassModel>>
    └── ListView.builder
        └── Card (لكل صف)
            └── ListTile
                ├── leading: CircleAvatar [رقم الصف]
                ├── title: Text [اسم الصف]
                ├── subtitle: Text [عدد الطلاب]
                └── trailing: Row
                    ├── IconButton [تعديل]
                    └── IconButton [حذف]
```

## Widgets الرئيسية

### 1. FloatingActionButton
```dart
FloatingActionButton.extended(
  onPressed: () => _showAddClassDialog(),
  icon: Icon(Icons.add),
  label: Text('إضافة صف'),
  backgroundColor: AppTheme.primaryColor,
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | زر عائم للإجراء الرئيسي |
| **extended** | يتضمن نص بجانب الأيقونة |
| **الموقع** | أسفل يسار الشاشة (RTL) |

### 2. showModalBottomSheet (نموذج الإضافة)
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true, // للتحكم بالارتفاع
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom, // فوق الكيبورد
    ),
    child: Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4, color: Colors.grey),
          TextFormField(labelText: 'اسم الصف'),
          TextFormField(labelText: 'رقم الصف'),
          ElevatedButton(child: Text('حفظ')),
        ],
      ),
    ),
  ),
);
```
| البند | التفاصيل |
|-------|---------|
| **isScrollControlled** | يسمح بتحديد الارتفاع |
| **viewInsets.bottom** | ارتفاع الكيبورد |
| **mainAxisSize.min** | أصغر حجم ممكن |

---

# 5️⃣ إدارة المواد (SubjectsManagementScreen)

## هيكل التخطيط
```
Scaffold
├── appBar: AppBar
│
├── floatingActionButton: FAB [إضافة مادة]
│
└── body: StreamBuilder<List<SubjectModel>>
    └── ListView.builder
        └── Card
            └── ExpansionTile
                ├── leading: CircleAvatar [أيقونة]
                ├── title: Text [اسم المادة]
                ├── subtitle: Text [اسم المعلم]
                └── children: [تفاصيل موسعة]
                    ├── Text [الوصف]
                    ├── Wrap [الصفوف المرتبطة]
                    └── Row [أزرار تعديل/حذف]
```

## Widgets الرئيسية

### 1. ExpansionTile
```dart
ExpansionTile(
  leading: CircleAvatar(
    backgroundColor: _getSubjectColor(subject.name),
    child: Icon(Icons.book),
  ),
  title: Text(subject.name),
  subtitle: Text('المعلم: ${subject.teacherName}'),
  children: [
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subject.description != null)
            Text(subject.description!),
          SizedBox(height: 8),
          Text('الصفوف: ${subject.relatedClassIds.length}'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(Icons.edit),
                label: Text('تعديل'),
                onPressed: () => _editSubject(subject),
              ),
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('حذف', style: TextStyle(color: Colors.red)),
                onPressed: () => _deleteSubject(subject),
              ),
            ],
          ),
        ],
      ),
    ),
  ],
)
```
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | عنصر قابل للتوسع |
| **children** | المحتوى الموسع |
| **علاقة UX** | إخفاء التفاصيل حتى الحاجة |

### 2. نموذج إضافة المادة
```dart
showModalBottomSheet(
  builder: (context) => Form(
    child: Column(
      children: [
        TextFormField(labelText: 'اسم المادة'),
        TextFormField(labelText: 'الوصف'),
        
        // اختيار المعلم
        StreamBuilder<List<UserModel>>(
          stream: FirestoreService.instance.watchUsersByRole('teacher'),
          builder: (context, snapshot) {
            return DropdownButtonFormField<String>(
              labelText: 'المعلم',
              items: snapshot.data?.map((t) => 
                DropdownMenuItem(value: t.uid, child: Text(t.name))
              ).toList(),
            );
          },
        ),
        
        // اختيار الصفوف
        StreamBuilder<List<ClassModel>>(
          stream: FirestoreService.instance.watchAllClasses(),
          builder: (context, snapshot) {
            return Wrap(
              children: snapshot.data?.map((c) => 
                FilterChip(
                  label: Text(c.name),
                  selected: _selectedClassIds.contains(c.id),
                  onSelected: (s) => _toggleClass(c.id),
                )
              ).toList() ?? [],
            );
          },
        ),
      ],
    ),
  ),
);
```

---

# 6️⃣ التقارير (ReportsScreen)

## هيكل التخطيط
```
Scaffold
├── appBar: AppBar
│
└── body: StreamBuilder<Map<String, int>>
    └── SingleChildScrollView
        └── Column
            │
            ├── _buildStatisticsSection
            │   └── GridView (2 أعمدة)
            │       ├── StatCard [المستخدمين]
            │       ├── StatCard [المعلمين]
            │       ├── StatCard [الطلاب]
            │       ├── StatCard [الصفوف]
            │       └── StatCard [المواد]
            │
            ├── _buildRecentActivitySection
            │   └── Card
            │       └── Column
            │           ├── ListTile [نشاط 1]
            │           ├── ListTile [نشاط 2]
            │           └── ...
            │
            └── _buildQuickActionsSection
                └── Row
                    ├── ElevatedButton [تصدير]
                    └── ElevatedButton [طباعة]
```

---

# 🔗 العلاقات بين الشاشات

```
                    ┌─────────────────────┐
                    │  AdminDashboard     │
                    │  (الشاشة الرئيسية)  │
                    └──────────┬──────────┘
                               │
        ┌──────────┬───────────┼───────────┬──────────┐
        ▼          ▼           ▼           ▼          ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │المستخدمين│ │الصفوف   │ │المواد   │ │التقارير │ │الإعدادات│
   └────┬────┘ └────┬────┘ └────┬────┘ └─────────┘ └─────────┘
        │           │           │
        ▼           ▼           ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐
   │إضافة/   │ │إضافة/   │ │إضافة/   │
   │تعديل    │ │تعديل    │ │تعديل    │
   └─────────┘ └─────────┘ └─────────┘
```

---

# 🗄️ علاقة قاعدة البيانات

| الشاشة | القراءة (Stream) | الكتابة |
|--------|-----------------|---------|
| Dashboard | `watchStatistics()` | - |
| Users | `watchAllUsers()` | `deleteUser()` |
| AddEditUser | `watchAllSubjects()`, `watchAllClasses()` | `createUser()`, `updateUser()` |
| Classes | `watchAllClasses()` | `addClass()`, `updateClass()`, `deleteClass()` |
| Subjects | `watchAllSubjects()`, `watchUsersByRole()` | `addSubject()`, `updateSubject()`, `deleteSubject()` |
| Reports | `watchStatistics()` | - |

---

# 🎨 ملخص التصميم

| العنصر | التصميم |
|--------|---------|
| **الألوان** | `AppTheme.adminColor` (أحمر) |
| **Header** | تدرج لوني + ظل |
| **البطاقات** | زوايا مدورة 16px + ظل خفيف |
| **الأزرار** | ElevatedButton + FloatingActionButton |
| **القوائم** | ListView.builder + ListTile |
| **النوافذ** | showModalBottomSheet + AlertDialog |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
