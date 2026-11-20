// ثوابت التطبيق - App Constants

class AppConstants {
  // اسم التطبيق
  static const String appName = 'نظام إدارة المدرسة الذكي';
  static const String appNameEn = 'Smart School Management';

  // معلومات أكاديمية
  static const String studentName = 'عمر الاكوع';
  static const String universityName = 'جامعة ذمار';
  static const String collegeName = 'كلية الحاسبات والمعلوماتية';
  static const String courseName = 'تطوير تطبيقات الموبايل';

  // أنواع المستخدمين
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // حالات الحضور
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';

  // أنواع الاختبارات
  static const String examMonthly1 = 'monthly1';
  static const String examMonthly2 = 'monthly2';
  static const String examFinal = 'final';

  // حالات التكليف
  static const String submissionStatusSubmitted = 'submitted';
  static const String submissionStatusGraded = 'graded';
}

/// أسماء الأنواع بالعربي
class ArabicNames {
  static String getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'teacher':
        return 'معلم';
      case 'student':
        return 'طالب';
      default:
        return role;
    }
  }

  static String getAttendanceStatus(String status) {
    switch (status) {
      case 'present':
        return 'حاضر';
      case 'absent':
        return 'غائب';
      default:
        return status;
    }
  }

  static String getExamType(String type) {
    switch (type) {
      case 'monthly1':
        return 'الاختبار الشهري الأول';
      case 'monthly2':
        return 'الاختبار الشهري الثاني';
      case 'final':
        return 'الاختبار النهائي';
      default:
        return type;
    }
  }

  static String getSubmissionStatus(String status) {
    switch (status) {
      case 'submitted':
        return 'في الانتظار';
      case 'graded':
        return 'تم التقييم';
      default:
        return status;
    }
  }
}
