# 🔐 شرح تفصيلي لشاشة تسجيل الدخول (LoginScreen)

---

## 📁 معلومات الملف

| البند | التفاصيل |
|-------|---------|
| **المسار** | `lib/screens/auth/login_screen.dart` |
| **عدد الأسطر** | 664 سطر |
| **النوع** | `StatefulWidget` |
| **الصلاحيات** | متاحة للجميع (قبل تسجيل الدخول) |

---

## 🎯 وظيفة الشاشة

1. **إدخال بيانات المستخدم** (البريد + كلمة المرور)
2. **التحقق من صحة البيانات** (Validation)
3. **المصادقة مع Firebase** (Authentication)
4. **التوجيه للوحة المناسبة** حسب الدور (Admin/Teacher/Student)

---

## 🏗️ هيكل التخطيط الكامل

```
Directionality (textDirection: RTL)
└── Scaffold (backgroundColor: white)
    └── body: Stack
        │
        ├── [الطبقة 1] Container - الخلفية المتدرجة
        │   └── BoxDecoration
        │       └── LinearGradient
        │
        ├── [الطبقة 2] Positioned - دائرة زخرفية علوية
        │   └── Container (250x250)
        │       └── BoxDecoration (circle + RadialGradient)
        │
        ├── [الطبقة 3] Positioned - دائرة زخرفية سفلية
        │   └── Container (200x200)
        │       └── BoxDecoration (circle + RadialGradient)
        │
        └── [الطبقة 4] SafeArea - المحتوى الرئيسي
            └── Center
                └── SingleChildScrollView
                    └── Padding (24px)
                        └── Form (key: _formKey)
                            └── Column
                                │
                                ├── SizedBox (height: 40)
                                │
                                ├── Hero (tag: 'app_logo')
                                │   └── Container (shadow)
                                │       └── CircleAvatar (60 radius)
                                │           └── Icon (school)
                                │
                                ├── SizedBox (height: 32)
                                │
                                ├── Text "مرحباً بك" (عنوان)
                                │
                                ├── SizedBox (height: 8)
                                │
                                ├── Text "قم بتسجيل الدخول..." (وصف)
                                │
                                ├── SizedBox (height: 40)
                                │
                                ├── [شرطي] Container - رسالة الخطأ
                                │   └── Row
                                │       ├── Icon (error)
                                │       └── Expanded → Text (الخطأ)
                                │
                                ├── _buildInputField - حقل البريد
                                │   └── Column
                                │       ├── Text (label)
                                │       └── Container (shadow)
                                │           └── TextFormField
                                │
                                ├── SizedBox (height: 20)
                                │
                                ├── _buildInputField - حقل كلمة المرور
                                │   └── Column
                                │       ├── Text (label)
                                │       └── Container (shadow)
                                │           └── TextFormField
                                │               └── suffixIcon: IconButton (عين)
                                │
                                ├── SizedBox (height: 32)
                                │
                                ├── _buildLoginButton - زر الدخول
                                │   └── Container (gradient + shadow)
                                │       └── ElevatedButton
                                │           └── [شرطي]
                                │               ├── CircularProgressIndicator (تحميل)
                                │               └── Row (نص + سهم)
                                │
                                ├── SizedBox (height: 20)
                                │
                                ├── TextButton "عرض بيانات المدير"
                                │
                                ├── SizedBox (height: 40)
                                │
                                └── Column - التذييل
                                    ├── Divider
                                    ├── Text "جامعة ذمار"
                                    ├── Text "كلية الحاسبات..."
                                    └── Text "مقرر تطوير..."
```

---

## 🧩 شرح كل Widget بالتفصيل

---

### 1. Directionality

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: Scaffold(...),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | Widget يحدد اتجاه النص والتخطيط |
| **وظيفته** | يجعل كل المحتوى من اليمين لليسار |
| **لماذا استخدمناه؟** | التطبيق عربي، والعربية تُكتب RTL |
| **الخصائص** | `textDirection` - الاتجاه |
| **البديل** | إعداد `locale` في `MaterialApp` |
| **علاقة UX** | ضروري لتجربة مستخدم عربية صحيحة |

**القيم الممكنة:**
- `TextDirection.rtl` → من اليمين لليسار (العربية)
- `TextDirection.ltr` → من اليسار لليمين (الإنجليزية)

---

### 2. Scaffold

```dart
Scaffold(
  backgroundColor: Colors.white,
  body: Stack(...),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | الهيكل الأساسي للشاشة في Material Design |
| **وظيفته** | يوفر بنية للـ AppBar, Body, FAB, Drawer |
| **لماذا استخدمناه؟** | كل شاشة Flutter تحتاج Scaffold |
| **الخصائص المستخدمة** | `backgroundColor`, `body` |
| **خصائص أخرى** | `appBar`, `floatingActionButton`, `drawer`, `bottomNavigationBar` |
| **البديل** | لا يوجد - هو الأساس |

---

### 3. Stack

```dart
Stack(
  children: [
    Container(...),      // الخلفية
    Positioned(...),     // دائرة 1
    Positioned(...),     // دائرة 2
    SafeArea(...),       // المحتوى
  ],
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | Widget يضع أبناءه فوق بعضهم في طبقات |
| **وظيفته** | تراكب العناصر (Overlapping) |
| **لماذا استخدمناه؟** | لوضع الخلفية والأشكال الزخرفية خلف المحتوى |
| **الخصائص** | `children`, `alignment`, `fit`, `clipBehavior` |
| **البديل** | `CustomPaint` - أكثر تعقيداً |
| **علاقة UX** | يخلق عمق بصري وتصميم جذاب |

**الترتيب:**
```
الطبقة 4 (الأخيرة) ← المحتوى (الأعلى - مرئي)
الطبقة 3            ← دائرة سفلية
الطبقة 2            ← دائرة علوية
الطبقة 1 (الأولى)   ← الخلفية (الأسفل)
```

---

### 4. Container + LinearGradient (الخلفية)

```dart
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
)
```

| البند | التفاصيل |
|-------|---------|
| **Container** | صندوق متعدد الاستخدامات |
| **BoxDecoration** | زخرفة الصندوق |
| **LinearGradient** | تدرج لوني خطي |
| **وظيفته** | خلفية ناعمة بدلاً من لون واحد |
| **لماذا؟** | مظهر حديث واحترافي |
| **البدائل** | `RadialGradient`, `SweepGradient`, صورة خلفية |
| **علاقة UX** | يوجه العين ويعطي إحساس بالحركة |

**خصائص LinearGradient:**
| الخاصية | الوظيفة |
|---------|---------|
| `begin` | نقطة بداية التدرج |
| `end` | نقطة نهاية التدرج |
| `colors` | قائمة الألوان |
| `stops` | نقاط توقف كل لون (اختياري) |

---

### 5. Positioned (الدوائر الزخرفية)

```dart
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
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يحدد موقع عنصر داخل Stack |
| **وظيفته** | وضع الدوائر في أماكن محددة |
| **لماذا القيم السالبة؟** | لإخفاء جزء من الدائرة خارج الشاشة |
| **الخصائص** | `top`, `left`, `right`, `bottom`, `width`, `height` |
| **البديل** | `Align` - أقل دقة |
| **علاقة UX** | عناصر زخرفية تُحسّن المظهر |

**RadialGradient:**
- تدرج دائري من المركز للخارج
- اللون الأول في المركز، والأخير على الحواف

---

### 6. SafeArea

```dart
SafeArea(
  child: Center(...),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يبعد المحتوى عن المناطق الخطرة |
| **وظيفته** | تجنب Notch وأزرار النظام |
| **لماذا استخدمناه؟** | التوافق مع كل الأجهزة |
| **الخصائص** | `top`, `bottom`, `left`, `right`, `minimum` |
| **البديل** | `MediaQuery.of(context).padding` يدوياً |
| **علاقة UX** | ضروري لعدم إخفاء المحتوى |

**المناطق الخطرة:**
```
┌────────────────────┐
│      Notch         │ ← SafeArea يتجنب هذا
├────────────────────┤
│                    │
│   المحتوى الآمن    │
│                    │
├────────────────────┤
│  Home Indicator    │ ← وهذا
└────────────────────┘
```

---

### 7. Center

```dart
Center(
  child: SingleChildScrollView(...),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يضع الابن في المنتصف |
| **وظيفته** | توسيط المحتوى أفقياً وعمودياً |
| **لماذا؟** | النموذج يظهر في وسط الشاشة |
| **البديل** | `Align(alignment: Alignment.center)` |

---

### 8. SingleChildScrollView

```dart
SingleChildScrollView(
  physics: const BouncingScrollPhysics(),
  child: Padding(...),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يجعل المحتوى قابلاً للتمرير |
| **وظيفته** | التمرير عند امتلاء الشاشة |
| **لماذا استخدمناه؟** | عند ظهور الكيبورد لا يحدث overflow |
| **الخصائص** | `physics`, `scrollDirection`, `reverse`, `controller` |
| **البديل** | `ListView` - للقوائم الطويلة |
| **علاقة UX** | يمنع أخطاء overflow ويُحسّن التجربة |

**physics:**
- `BouncingScrollPhysics` → تأثير ارتداد (iOS style)
- `ClampingScrollPhysics` → توقف عند الحد (Android style)

---

### 9. Padding

```dart
Padding(
  padding: const EdgeInsets.all(24),
  child: Form(...),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يضيف هوامش داخلية |
| **وظيفته** | مسافة بين المحتوى والحواف |
| **لماذا 24px؟** | معيار Material Design للهوامش |
| **البديل** | `Container(padding: ...)` |

**أنواع EdgeInsets:**
```dart
EdgeInsets.all(24)           // كل الجهات
EdgeInsets.symmetric(horizontal: 24, vertical: 16)
EdgeInsets.only(left: 10, top: 20)
EdgeInsets.fromLTRB(left, top, right, bottom)
```

---

### 10. Form + GlobalKey

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(...),
)

// للتحقق:
if (_formKey.currentState!.validate()) {
  // كل الحقول صالحة
}
```

| البند | التفاصيل |
|-------|---------|
| **Form** | حاوية لحقول الإدخال |
| **GlobalKey** | مفتاح للوصول لحالة النموذج |
| **وظيفته** | تجميع الحقول والتحقق منها معاً |
| **لماذا؟** | التحقق من كل الحقول بأمر واحد |
| **علاقة قاعدة البيانات** | يُرسل البيانات بعد التحقق فقط |
| **علاقة UX** | يمنع إرسال بيانات خاطئة |

---

### 11. Column

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [...],
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | يرتب الأبناء عمودياً (↓) |
| **وظيفته** | تخطيط عمودي للعناصر |
| **mainAxisAlignment** | توزيع على المحور الرئيسي (عمودي) |
| **crossAxisAlignment** | محاذاة على المحور الثانوي (أفقي) |
| **البديل** | `ListView` - للقوائم الطويلة |

**قيم MainAxisAlignment:**
```
start   ─ العناصر في البداية
center  ─ العناصر في المنتصف
end     ─ العناصر في النهاية
spaceBetween ─ مسافات متساوية بين العناصر
spaceAround  ─ مسافات حول كل عنصر
spaceEvenly  ─ مسافات متساوية في كل مكان
```

---

### 12. SizedBox (المسافات)

```dart
SizedBox(height: 32),
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | صندوق بحجم ثابت |
| **وظيفته** | إضافة مسافة بين العناصر |
| **لماذا؟** | أبسط من Padding للمسافات |
| **البديل** | `Padding`, `Container`, `Spacer` |

---

### 13. Hero (الشعار)

```dart
Hero(
  tag: 'app_logo',
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(...)],
    ),
    child: CircleAvatar(
      radius: 60,
      backgroundColor: AppTheme.primaryColor,
      child: Icon(Icons.school, size: 60, color: Colors.white),
    ),
  ),
)
```

| البند | التفاصيل |
|-------|---------|
| **Hero** | حركة انتقالية بين الشاشات |
| **tag** | معرف فريد للربط بين الشاشات |
| **وظيفته** | الشعار "يطير" للشاشة التالية |
| **CircleAvatar** | صورة/أيقونة دائرية |
| **boxShadow** | ظل تحت الشعار |
| **علاقة UX** | انتقال سلس وجذاب |

---

### 14. Text (العناوين)

```dart
Text(
  'مرحباً بك',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
  ),
  textAlign: TextAlign.center,
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | عرض نص |
| **الخصائص** | `style`, `textAlign`, `maxLines`, `overflow` |
| **TextStyle** | تنسيق النص (حجم، سُمك، لون) |

**أحجام النصوص المستخدمة:**
| النص | الحجم | السُمك |
|------|-------|--------|
| العنوان الرئيسي | 32 | bold |
| الوصف | 15 | normal |
| التسمية | 14 | w600 |
| الخطأ | 13 | w500 |

---

### 15. Container + رسالة الخطأ (شرطي)

```dart
if (_errorMessage != null) ...[
  Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.errorColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: AppTheme.errorColor),
        SizedBox(width: 12),
        Expanded(child: Text(_errorMessage!, ...)),
      ],
    ),
  ),
  SizedBox(height: 24),
],
```

| البند | التفاصيل |
|-------|---------|
| **الشرط** | `if (_errorMessage != null)` |
| **Spread operator** | `...[]` لإضافة عدة عناصر |
| **وظيفته** | عرض رسالة الخطأ فقط عند وجودها |
| **التصميم** | خلفية حمراء شفافة + حد |
| **علاقة UX** | إعلام المستخدم بالخطأ |

---

### 16. _buildInputField (حقل الإدخال)

```dart
Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  bool isPassword = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // التسمية
      Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 8),
        child: Text(label, style: TextStyle(...)),
      ),
      // الحقل
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(...)],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword ? IconButton(...) : null,
            border: OutlineInputBorder(...),
          ),
          validator: validator,
        ),
      ),
    ],
  );
}
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | دالة تُنشئ حقل إدخال مخصص |
| **لماذا دالة؟** | إعادة الاستخدام وتقليل التكرار |
| **TextEditingController** | للتحكم في النص |
| **obscureText** | إخفاء كلمة المرور |
| **validator** | دالة التحقق |

**خصائص TextFormField:**
| الخاصية | الوظيفة |
|---------|---------|
| `controller` | التحكم في النص |
| `obscureText` | إخفاء النص (للباسورد) |
| `keyboardType` | نوع الكيبورد |
| `validator` | دالة التحقق |
| `decoration` | تصميم الحقل |

**خصائص InputDecoration:**
| الخاصية | الوظيفة |
|---------|---------|
| `hintText` | نص توضيحي |
| `prefixIcon` | أيقونة في البداية |
| `suffixIcon` | أيقونة في النهاية |
| `border` | شكل الحدود |
| `focusedBorder` | الحدود عند التركيز |

---

### 17. IconButton (عين كلمة المرور)

```dart
IconButton(
  icon: Icon(
    _obscurePassword 
      ? Icons.visibility_off_rounded 
      : Icons.visibility_rounded,
    color: Colors.grey[400],
  ),
  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | زر على شكل أيقونة |
| **وظيفته** | تبديل إظهار/إخفاء كلمة المرور |
| **الحالة** | `_obscurePassword` (true/false) |
| **علاقة UX** | يسمح للمستخدم بالتحقق من كلمة المرور |

---

### 18. validator (التحقق)

```dart
// للبريد
validator: (value) {
  if (value == null || value.isEmpty)
    return 'يرجى إدخال البريد الإلكتروني';
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
    return 'بريد إلكتروني غير صالح';
  return null;
},

// لكلمة المرور
validator: (value) {
  if (value == null || value.isEmpty)
    return 'يرجى إدخال كلمة المرور';
  if (value.length < 6)
    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  return null;
},
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | دالة للتحقق من صحة الإدخال |
| **الإرجاع** | `null` = صالح، `String` = رسالة خطأ |
| **RegExp** | تعبير نمطي للتحقق من صيغة البريد |
| **علاقة UX** | منع الأخطاء قبل الإرسال |

---

### 19. _buildLoginButton (زر الدخول)

```dart
Widget _buildLoginButton() {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withOpacity(0.35),
          blurRadius: 20,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: _isLoading
        ? SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
    ),
  );
}
```

| البند | التفاصيل |
|-------|---------|
| **Container** | للتدرج اللوني والظل |
| **ElevatedButton** | الزر الفعلي |
| **backgroundColor: transparent** | لإظهار التدرج |
| **onPressed: null** | تعطيل الزر أثناء التحميل |
| **CircularProgressIndicator** | مؤشر تحميل |
| **علاقة UX** | إظهار حالة التحميل للمستخدم |

---

### 20. TextButton (عرض بيانات المدير)

```dart
TextButton.icon(
  onPressed: _showAdminInfo,
  icon: Icon(Icons.info_outline),
  label: Text('عرض بيانات المدير الافتراضي'),
)
```

| البند | التفاصيل |
|-------|---------|
| **ما هو؟** | زر نصي بأيقونة |
| **وظيفته** | عرض بيانات الدخول للتطوير |
| **ملاحظة** | يُزال في الإصدار النهائي |

---

## 🔄 دورة حياة الشاشة

```
1. initState()
   └── لا شيء خاص

2. build()
   └── بناء الواجهة

3. User Action → _login()
   ├── validate() ← التحقق
   ├── setState(isLoading: true)
   ├── AuthService.signIn() ← المصادقة
   ├── AppRoutes.getDashboardRoute() ← تحديد الوجهة
   └── Navigator.pushReplacementNamed() ← التوجيه

4. dispose()
   ├── _emailController.dispose()
   └── _passwordController.dispose()
```

---

## 🔐 علاقة قاعدة البيانات

```
LoginScreen
     │
     ▼ signIn(email, password)
┌─────────────────────────────────────┐
│           AuthService               │
├─────────────────────────────────────┤
│   _checkConnectivity()              │
│        │                            │
│   ┌────▼────┐    ┌────────────┐     │
│   │ Online? │ نعم│ Firebase   │     │
│   │         │───▶│ Auth       │     │
│   └────┬────┘    └─────┬──────┘     │
│     لا │               │            │
│   ┌────▼────┐          ▼            │
│   │ SQLite  │    ┌──────────────┐   │
│   │ Local   │    │ Firestore    │   │
│   │ Cache   │    │ users/{uid}  │   │
│   └─────────┘    └──────────────┘   │
└─────────────────────────────────────┘
     │
     ▼ UserModel
┌─────────────────────────────────────┐
│   Navigation based on role          │
│   ├── admin → /admin/dashboard      │
│   ├── teacher → /teacher/dashboard  │
│   └── student → /student/dashboard  │
└─────────────────────────────────────┘
```

---

## 🎨 ملخص التصميم

| العنصر | التصميم |
|--------|---------|
| **الخلفية** | LinearGradient + دوائر RadialGradient |
| **الشعار** | CircleAvatar بظل |
| **الحقول** | Container بظل + TextFormField |
| **الزر** | Container بتدرج + ElevatedButton شفاف |
| **الألوان** | primaryColor, white, grey |
| **الزوايا** | 16-18px مدورة |
| **الظلال** | خفيفة (0.03-0.35 opacity) |

---

*تم إنشاء هذا التوثيق - فبراير 2026*
