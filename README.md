<div dir="rtl">

# نظام إدارة المدرسة الذكي | Smart School Management System

**تطبيق Flutter عربي (من اليمين لليسار) لإدارة المدرسة** بثلاثة أدوار: المدير والمعلّم والطالب. يحفظ البيانات في Cloud Firestore، ويعمل بدون إنترنت عبر SQLite ثم يزامن البيانات عند عودة الاتصال.

أُنجز كمشروع لمقرر تطوير تطبيقات الموبايل، ومعه توثيق كامل في مجلد [`docs/`](docs).

</div>

---

## ماذا يحتوي المشروع؟ | What's inside

<div dir="rtl">

### المدير
- لوحة تحكم بالإحصاءات.
- إدارة المستخدمين: إضافة وتعديل المدراء والمعلّمين والطلاب.
- إدارة الصفوف والمواد، وشاشة تقارير.

### المعلّم
- لوحة تحكم، وقائمة طلابه.
- تسجيل الحضور، ورصد الدرجات، وإنشاء التكاليف (الواجبات).

### الطالب
- لوحة تحكم، وعرض مواده ودرجاته وسجل حضوره.
- تسليم التكاليف باختيار ملف من الجهاز (file_picker).

### البنية التقنية
- **المصادقة:** Firebase Auth مع كلمات مرور مشفّرة (crypto)، وتوجيه المستخدم بعد الدخول إلى واجهة دوره.
- **قاعدة بيانات مزدوجة:** Cloud Firestore في السحابة، وSQLite على الجهاز.
- **خدمة مزامنة** تتابع حالة الاتصال (connectivity_plus) وترفع ما حُفظ محلياً عند عودة الإنترنت. البيانات تتحدث مباشرة عبر Streams (RxDart).
- **تقسيم واضح للكود:** `config` (الثيم والثوابت والمسارات)، و`models` (المستخدم، الصف، المادة، الدرجة، الحضور، التكليف)، و`services`، و`screens` لكل دور، و`widgets`.
- قواعد أمان Firestore وStorage موجودة في `firestore.rules` و`storage.rules`.

</div>

## التقنيات | Tech stack

| | |
| --- | --- |
| App | Flutter, Dart 3.9+, Provider, RxDart |
| Backend | Firebase Auth, Cloud Firestore |
| Offline | sqflite, shared_preferences, connectivity_plus |
| Other | crypto, file_picker, intl, flutter_localizations |

## التشغيل محلياً | Local setup

<div dir="rtl">

ملفات إعداد Firebase **غير مرفوعة عمداً**. لتشغيل التطبيق اربطه بمشروع Firebase خاص بك:

</div>

```bash
git clone https://github.com/amralakwaa/smart-school-management.git
cd smart-school-management
flutter pub get

dart pub global activate flutterfire_cli
flutterfire configure    # creates lib/firebase_options.dart and google-services.json

firebase deploy --only firestore:rules,storage
flutter run
```

<div dir="rtl">

> **مهم:** عند أول تشغيل يعرض التطبيق إنشاء حساب مدير افتراضي ببيانات تجريبية (`admin@example.com` / `CHANGE_ME_123`) مكتوبة في `lib/screens/auth/login_screen.dart`. غيّرها قبل أي استخدام حقيقي.
>
> القواعد في `firestore.rules` و`storage.rules` قواعد تطويرية تسمح لأي مستخدم مسجّل بالقراءة والكتابة. شدّدها حسب الأدوار قبل النشر.

---

## المطوّر | Developer

صمّم التطبيق وطوّره **عمر بلال الأكوع** ([@amralakwaa](https://github.com/amralakwaa)).

## الحقوق

جميع الحقوق محفوظة.

</div>
