# 📱 توثيق واجهات التطبيق والـ Widgets

> دليل شامل لكل واجهة في التطبيق مع شرح تفصيلي للـ Widgets

---

# 🔐 شاشة تسجيل الدخول (LoginScreen)

## معلومات أساسية
| البند | التفاصيل |
|-------|---------|
| **الملف** | `lib/screens/auth/login_screen.dart` |
| **النوع** | `StatefulWidget` |
| **الصلاحيات** | متاحة للجميع (قبل تسجيل الدخول) |
| **قاعدة البيانات** | `FirebaseAuth` + `users` collection |

## هيكل التخطيط
```
Scaffold
└── Stack (طبقات متراكبة)
    ├── Container [خلفية متدرجة]
    ├── Positioned [دائرة زخرفية أعلى]
    ├── Positioned [دائرة زخرفية أسفل]
    └── SafeArea
        └── Center
            └── SingleChildScrollView
                └── Form
                    └── Column
                        ├── Hero [شعار التطبيق]
                        ├── Text [عنوان ترحيبي]
                        ├── Text [نص توضيحي]
                        ├── Container [رسالة الخطأ - شرطي]
                        ├── _buildInputField [حقل البريد]
                        ├── _buildInputField [حقل كلمة المرور]
                        ├── _buildLoginButton [زر الدخول]
                        ├── TextButton [زر عرض بيانات المدير]
                        └── Column [التذييل - معلومات الجامعة]
```

## الـ Widgets بالتفصيل

### 1. Stack
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يضع العناصر فوق بعضها في طبقات |
| **لماذا استخدمناه؟** | لوضع الخلفية والأشكال الزخرفية خلف المحتوى |
| **البديل** | `CustomPaint` - أكثر تعقيداً |
| **علاقة UX** | يخلق عمق بصري وتصميم جذاب |
| **الخصائص** | `children: List<Widget>`, `alignment`, `fit` |

### 2. LinearGradient
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | تدرج لوني خطي |
| **لماذا؟** | خلفية ناعمة وحديثة بدل اللون الواحد |
| **البديل** | `RadialGradient`, `SweepGradient`, صورة |
| **علاقة UX** | يوجه العين ويعطي إحساس بالحركة |
| **الخصائص** | `begin`, `end`, `colors`, `stops` |

### 3. Positioned
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يحدد موقع عنصر داخل Stack |
| **لماذا؟** | لوضع الدوائر الزخرفية في أماكن محددة |
| **البديل** | `Align` - أقل دقة |
| **الخصائص** | `top`, `left`, `right`, `bottom`, `width`, `height` |

### 4. SafeArea
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يبعد المحتوى عن Notch وأزرار النظام |
| **لماذا؟** | تجنب تداخل المحتوى مع عناصر الجهاز |
| **البديل** | `MediaQuery.of(context).padding` يدوياً |
| **علاقة UX** | ضروري للتوافق مع كل الأجهزة |

### 5. SingleChildScrollView
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يجعل المحتوى قابلاً للتمرير |
| **لماذا؟** | عند ظهور الكيبورد لا يخرج المحتوى |
| **البديل** | `ListView` - للقوائم الطويلة |
| **علاقة UX** | يمنع overflow errors |

### 6. Form + GlobalKey
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | حاوية للحقول مع مفتاح للتحقق |
| **لماذا؟** | للتحقق من كل الحقول دفعة واحدة |
| **قاعدة البيانات** | يُرسل البيانات بعد التحقق فقط |
| **الخصائص** | `key`, `autovalidateMode`, `onChanged` |

### 7. TextFormField
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | حقل إدخال نص مع تحقق |
| **لماذا؟** | يدعم validator ويتكامل مع Form |
| **البديل** | `TextField` - بدون Form integration |
| **الخصائص** | `controller`, `obscureText`, `keyboardType`, `validator`, `decoration` |
| **علاقة UX** | تحقق فوري يُحسن تجربة المستخدم |

### 8. Hero
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | حركة انتقالية للشعار بين الشاشات |
| **لماذا؟** | انتقال سلس وجذاب |
| **الخصائص** | `tag` - معرف فريد |

---

# 🏠 لوحات التحكم (Dashboards)

## الهيكل المشترك
```
Directionality (RTL)
└── Scaffold
    └── CustomScrollView
        └── slivers: [
            SliverToBoxAdapter [Header متدرج]
            SliverToBoxAdapter [بطاقة الترحيب]
            SliverToBoxAdapter [قسم الإحصائيات]
            SliverToBoxAdapter [قسم الإجراءات السريعة]
        ]
```

## Widgets لوحات التحكم

### 1. Directionality
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يحدد اتجاه النص والتخطيط |
| **لماذا؟** | دعم اللغة العربية (RTL) |
| **القيم** | `TextDirection.rtl`, `TextDirection.ltr` |
| **علاقة UX** | ضروري للغات من اليمين لليسار |

### 2. CustomScrollView
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة تمرير تدعم Slivers |
| **لماذا؟** | تمرير سلس مع SliverAppBar |
| **البديل** | `ListView` - لا يدعم Slivers |
| **الخصائص** | `slivers`, `physics`, `controller` |

### 3. SliverAppBar
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | شريط تطبيق قابل للانكماش |
| **لماذا؟** | تأثير حديث عند التمرير |
| **البديل** | `AppBar` العادي |
| **الخصائص** | `expandedHeight`, `floating`, `pinned`, `flexibleSpace` |

### 4. StreamBuilder
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يستمع لـ Stream ويُعيد البناء |
| **لماذا؟** | بيانات مباشرة من Firestore |
| **قاعدة البيانات** | يتصل بـ watchStatistics() |
| **البديل** | `FutureBuilder` - لمرة واحدة |
| **الخصائص** | `stream`, `builder`, `initialData` |

### 5. GridView.count
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | شبكة بعدد أعمدة ثابت |
| **لماذا؟** | عرض البطاقات في صفوف منظمة |
| **البديل** | `GridView.builder` - للقوائم الطويلة |
| **الخصائص** | `crossAxisCount`, `childAspectRatio`, `mainAxisSpacing` |

---

# 📋 شاشات القوائم (List Screens)

## الهيكل المشترك
```
Scaffold
└── CustomScrollView
    └── slivers: [
        SliverAppBar [Header]
        SliverToBoxAdapter [فلاتر/بحث]
        SliverList/SliverPadding [القائمة]
    ]
```

## Widgets خاصة بالقوائم

### 1. SliverList
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة داخل CustomScrollView |
| **لماذا؟** | أداء أفضل للقوائم الطويلة |
| **البديل** | `SliverToBoxAdapter` + `Column` |
| **الخصائص** | `delegate: SliverChildBuilderDelegate` |

### 2. ListTile
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | عنصر قائمة جاهز |
| **لماذا؟** | تخطيط موحد وسريع |
| **البديل** | `Row` مخصص - مرونة أكثر |
| **الخصائص** | `leading`, `title`, `subtitle`, `trailing`, `onTap` |

### 3. ExpansionTile
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | عنصر قابل للتوسع |
| **لماذا؟** | إظهار تفاصيل إضافية عند الطلب |
| **البديل** | `AnimatedContainer` يدوي |
| **علاقة UX** | يقلل الفوضى البصرية |
| **الخصائص** | `title`, `children`, `initiallyExpanded` |

### 4. Dismissible
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | عنصر قابل للسحب للحذف |
| **لماذا؟** | حذف سريع بالسحب |
| **الخصائص** | `key`, `direction`, `onDismissed`, `background` |

---

# 📝 شاشات النماذج (Form Screens)

## Widgets النماذج

### 1. DropdownButtonFormField
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | قائمة منسدلة مع Form |
| **لماذا؟** | اختيار من قائمة محددة |
| **البديل** | `PopupMenuButton` |
| **قاعدة البيانات** | يعرض خيارات من Firestore |
| **الخصائص** | `value`, `items`, `onChanged`, `validator` |

### 2. Checkbox / Switch
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | مربع اختيار / مفتاح تبديل |
| **لماذا؟** | قيم نعم/لا |
| **الخصائص** | `value`, `onChanged`, `activeColor` |

### 3. DatePicker
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | نافذة اختيار تاريخ |
| **لماذا؟** | إدخال تاريخ صحيح |
| **الخصائص** | `initialDate`, `firstDate`, `lastDate`, `locale` |

---

# 🎨 Widgets التصميم المشتركة

## 1. Container
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | صندوق متعدد الاستخدامات |
| **الخصائص** | `padding`, `margin`, `decoration`, `constraints` |
| **استخداماته** | خلفيات، حدود، ظلال |

## 2. BoxDecoration
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | زخرفة الـ Container |
| **الخصائص** | `color`, `gradient`, `borderRadius`, `boxShadow`, `border` |

## 3. Row و Column
| Widget | الاتجاه | الاستخدام |
|--------|--------|----------|
| **Row** | أفقي ← | عناصر جنباً لجنب |
| **Column** | عمودي ↓ | عناصر فوق بعض |

### خصائص مشتركة
- `mainAxisAlignment` - توزيع على المحور الرئيسي
- `crossAxisAlignment` - محاذاة على المحور الثانوي
- `children` - العناصر الأبناء

## 4. Expanded و Flexible
| Widget | الوظيفة |
|--------|---------|
| **Expanded** | يملأ المساحة المتبقية |
| **Flexible** | يأخذ حصة من المساحة |

## 5. Padding و SizedBox
| Widget | الوظيفة |
|--------|---------|
| **Padding** | إضافة هوامش داخلية |
| **SizedBox** | مسافة ثابتة بين العناصر |

---

# 🔘 Widgets التفاعل

## 1. InkWell vs GestureDetector
| Widget | المميزات | الاستخدام |
|--------|---------|----------|
| **InkWell** | تأثير موجة Material | أزرار مخصصة |
| **GestureDetector** | بدون تأثير بصري | إيماءات متقدمة |

## 2. ElevatedButton / TextButton / OutlinedButton
| الزر | المظهر | الاستخدام |
|------|--------|----------|
| **ElevatedButton** | مرتفع بظل | الإجراء الرئيسي |
| **TextButton** | نص فقط | الإجراء الثانوي |
| **OutlinedButton** | حد فقط | بديل للرئيسي |

## 3. FloatingActionButton
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | زر عائم للإجراء الرئيسي |
| **الموقع** | أسفل يمين/يسار الشاشة |
| **الخصائص** | `onPressed`, `child`, `backgroundColor` |

---

# 📊 Widgets البيانات

## 1. CircularProgressIndicator
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | مؤشر تحميل دائري |
| **البديل** | `LinearProgressIndicator` |
| **الخصائص** | `value` (null = غير محدد), `strokeWidth` |

## 2. RefreshIndicator
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | سحب للتحديث |
| **الخصائص** | `onRefresh`, `child` |

## 3. EmptyState Pattern
```dart
if (data.isEmpty)
  Column(
    children: [
      Icon(Icons.inbox, size: 80, color: Colors.grey),
      Text('لا توجد بيانات'),
    ],
  )
```

---

# 🗨️ Widgets النوافذ

## 1. showDialog / AlertDialog
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | نافذة تأكيد/تنبيه |
| **الاستخدام** | تأكيد الحذف، رسائل |
| **الخصائص** | `title`, `content`, `actions` |

## 2. showModalBottomSheet
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | ورقة سفلية منبثقة |
| **الاستخدام** | نماذج إضافة، خيارات |
| **الخصائص** | `isScrollControlled`, `shape` |

## 3. SnackBar
| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | رسالة مؤقتة أسفل الشاشة |
| **الاستخدام** | تأكيد العمليات |
| **الخصائص** | `content`, `action`, `duration` |

---

# 🔐 علاقة الـ Widgets بالصلاحيات

| الشاشة | المدير | المعلم | الطالب |
|--------|--------|--------|--------|
| AdminDashboard | ✅ | ❌ | ❌ |
| UsersManagement | ✅ | ❌ | ❌ |
| TeacherDashboard | ❌ | ✅ | ❌ |
| AttendanceScreen | ❌ | ✅ | ❌ |
| GradesScreen | ❌ | ✅ | ❌ |
| StudentDashboard | ❌ | ❌ | ✅ |
| MyGradesScreen | ❌ | ❌ | ✅ |

## كيف يتم التحكم؟
```dart
// في routes.dart
final route = AppRoutes.getDashboardRoute(user.role);
Navigator.pushReplacementNamed(context, route);
```

---

# 📱 علاقة الـ Widgets بـ UX

| المبدأ | الـ Widget | التطبيق |
|--------|-----------|---------|
| **Feedback** | SnackBar, CircularProgressIndicator | إعلام المستخدم بالحالة |
| **Hierarchy** | TextStyle sizes, Colors | أهمية العناصر |
| **Affordance** | ElevatedButton, InkWell | يُظهر أن العنصر قابل للضغط |
| **Consistency** | Theme, TextTheme | توحيد المظهر |
| **Error Prevention** | Validator, Confirmation dialogs | منع الأخطاء |

---

# 🗄️ علاقة الـ Widgets بقاعدة البيانات

| Widget | الاتصال | الـ Service |
|--------|---------|------------|
| **StreamBuilder** | Real-time | `watchXxx()` |
| **FutureBuilder** | One-time | `getXxx()` |
| **Form submit** | Write | `addXxx()`, `updateXxx()` |
| **Dismissible** | Delete | `deleteXxx()` |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
