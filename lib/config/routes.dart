// مسارات التنقل - App Routes

import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/users_management_screen.dart';
import '../screens/admin/add_edit_user_screen.dart';
import '../screens/admin/subjects_management_screen.dart';
import '../screens/admin/classes_management_screen.dart';
import '../screens/admin/reports_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/teacher/students_list_screen.dart';
import '../screens/teacher/attendance_screen.dart';
import '../screens/teacher/grades_screen.dart';
import '../screens/teacher/teacher_assignments_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/my_subjects_screen.dart';
import '../screens/student/my_grades_screen.dart';
import '../screens/student/my_attendance_screen.dart';
import '../screens/student/upload_assignment_screen.dart';

class AppRoutes {
  // مسارات المصادقة
  static const String login = '/login';

  // مسارات المدير
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminAddUser = '/admin/users/add';
  static const String adminEditUser = '/admin/users/edit';
  static const String adminSubjects = '/admin/subjects';
  static const String adminClasses = '/admin/classes';
  static const String adminReports = '/admin/reports';

  // مسارات المعلم
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherStudents = '/teacher/students';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherGrades = '/teacher/grades';
  static const String teacherAssignments = '/teacher/assignments';

  // مسارات الطالب
  static const String studentDashboard = '/student/dashboard';
  static const String studentSubjects = '/student/subjects';
  static const String studentGrades = '/student/grades';
  static const String studentAttendance = '/student/attendance';
  static const String studentAssignments = '/student/assignments';

  /// توليد المسارات
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // المصادقة
      case login:
        return _createRoute(const LoginScreen());

      // المدير
      case adminDashboard:
        return _createRoute(const AdminDashboardScreen());
      case adminUsers:
        return _createRoute(const UsersManagementScreen());
      case adminAddUser:
        return _createRoute(const AddEditUserScreen(isEdit: false));
      case adminEditUser:
        final userId = settings.arguments as String?;
        return _createRoute(AddEditUserScreen(isEdit: true, userId: userId));
      case adminSubjects:
        return _createRoute(const SubjectsManagementScreen());
      case adminClasses:
        return _createRoute(const ClassesManagementScreen());
      case adminReports:
        return _createRoute(const ReportsScreen());

      // المعلم
      case teacherDashboard:
        return _createRoute(const TeacherDashboardScreen());
      case teacherStudents:
        return _createRoute(const StudentsListScreen());
      case teacherAttendance:
        return _createRoute(const AttendanceScreen());
      case teacherGrades:
        return _createRoute(const GradesScreen());
      case teacherAssignments:
        return _createRoute(const TeacherAssignmentsScreen());

      // الطالب
      case studentDashboard:
        return _createRoute(const StudentDashboardScreen());
      case studentSubjects:
        return _createRoute(const MySubjectsScreen());
      case studentGrades:
        return _createRoute(const MyGradesScreen());
      case studentAttendance:
        return _createRoute(const MyAttendanceScreen());
      case studentAssignments:
        return _createRoute(const UploadAssignmentScreen());

      default:
        return _createRoute(const LoginScreen());
    }
  }

  /// إنشاء مسار مع انتقال
  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// الحصول على لوحة التحكم حسب الدور
  static String getDashboardRoute(String role) {
    switch (role) {
      case 'admin':
        return adminDashboard;
      case 'teacher':
        return teacherDashboard;
      case 'student':
        return studentDashboard;
      default:
        return login;
    }
  }
}
