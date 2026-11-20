// خدمة Firestore - Firestore Service
// إدارة البيانات في Firebase Firestore

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import '../models/assignment_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._init();

  // ==================== البث المباشر (Real-time Streams) ====================

  /// بث جميع المستخدمين (مع خيار تصفية حسب النشاط)
  Stream<List<UserModel>> watchAllUsers({bool isActive = true}) {
    return _firestore
        .collection('users')
        .where('isActive', isEqualTo: isActive)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['uid'] = doc.id;
            return UserModel.fromMap(data);
          }).toList(),
        );
  }

  /// بث المستخدمين حسب النوع والنشاط
  Stream<List<UserModel>> watchUsersByRole(
    String role, {
    bool isActive = true,
  }) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .where('isActive', isEqualTo: isActive)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['uid'] = doc.id;
            return UserModel.fromMap(data);
          }).toList(),
        );
  }

  /// بث طلاب الصف
  Stream<List<UserModel>> watchStudentsByClass(String classId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: classId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['uid'] = doc.id;
            return UserModel.fromMap(data);
          }).toList(),
        );
  }

  /// بث جميع المواد
  Stream<List<SubjectModel>> watchAllSubjects() {
    return _firestore
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SubjectModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// بث المواد الخاصة بمعلم معين
  Stream<List<SubjectModel>> watchTeacherSubjects(String teacherId) {
    return _firestore
        .collection('subjects')
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SubjectModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// بث الصفوف التي يدرسها المعلم (مشتقة من المواد)
  Stream<List<ClassModel>> watchTeacherClasses(String teacherId) {
    return Rx.combineLatest2(
      watchTeacherSubjects(teacherId),
      watchAllClasses(),
      (List<SubjectModel> subjects, List<ClassModel> allClasses) {
        final classIds = subjects
            .expand((s) => s.relatedClassIds)
            .toSet(); // Unique IDs
        return allClasses.where((c) => classIds.contains(c.id)).toList();
      },
    );
  }

  /// بث جميع الصفوف
  Stream<List<ClassModel>> watchAllClasses() {
    return _firestore
        .collection('classes')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final classes = snapshot.docs
              .map((doc) => ClassModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          classes.sort((a, b) => a.grade.compareTo(b.grade));
          return classes;
        });
  }

  /// بث حضور طالب
  Stream<List<AttendanceModel>> watchStudentAttendance(String studentId) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AttendanceModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  /// بث حضور صف في تاريخ ومادة معينة
  Stream<List<AttendanceModel>> watchClassAttendance(
    String classId,
    String subjectId,
    String date,
  ) {
    return _firestore
        .collection('attendance')
        .where('classId', isEqualTo: classId)
        .where('subjectId', isEqualTo: subjectId)
        .where('date', isEqualTo: date)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// بث درجات طالب
  Stream<List<GradeModel>> watchStudentGrades(String studentId) {
    return _firestore
        .collection('grades')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GradeModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// بث درجات صف لمادة ونوع اختبار
  Stream<List<GradeModel>> watchClassGrades(
    String classId,
    String subjectId,
    String examType,
  ) {
    return _firestore
        .collection('grades')
        .where('classId', isEqualTo: classId)
        .where('subjectId', isEqualTo: subjectId)
        .where('examType', isEqualTo: examType)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GradeModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// بث التكاليف لصف
  Stream<List<AssignmentModel>> watchClassAssignments(String classId) {
    return _firestore
        .collection('assignments')
        .where('classId', isEqualTo: classId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AssignmentModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
          return list;
        });
  }

  /// بث التكاليف للمعلم
  Stream<List<AssignmentModel>> watchTeacherAssignments(String teacherId) {
    return _firestore
        .collection('assignments')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AssignmentModel.fromMap(doc.data(), docId: doc.id))
              .toList();
          list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
          return list;
        });
  }

  /// بث تسليمات تكليف
  Stream<List<SubmissionModel>> watchAssignmentSubmissions(
    String assignmentId,
  ) {
    return _firestore
        .collection('assignments')
        .doc(assignmentId)
        .collection('submissions')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SubmissionModel.fromMap(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  /// بث الإحصائيات العامة (للوحات التحكم) - Real-time and Robust
  Stream<Map<String, int>> watchStatistics() {
    return Rx.combineLatest3(
      _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      _firestore
          .collection('subjects')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      _firestore
          .collection('classes')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      (usersSnap, subjectsSnap, classesSnap) {
        final totalUsers = usersSnap.docs.length;
        final teachers = usersSnap.docs.where((d) {
          try {
            return d.get('role') == 'teacher';
          } catch (_) {
            return false;
          }
        }).length;
        final students = usersSnap.docs.where((d) {
          try {
            return d.get('role') == 'student';
          } catch (_) {
            return false;
          }
        }).length;

        return {
          'totalUsers': totalUsers,
          'teachers': teachers,
          'students': students,
          'subjects': subjectsSnap.docs.length,
          'classes': classesSnap.docs.length,
        };
      },
    ).handleError((error) {
      debugPrint('❌ watchStatistics Error: $error');
      throw error;
    });
  }

  /// بث إحصائيات الطالب (المعدل، الحضور، التكاليف) - Real-time and Detailed
  Stream<Map<String, dynamic>> watchStudentStats(String studentId) {
    return Rx.combineLatest3(
      watchStudentAttendance(studentId).startWith([]),
      watchStudentGrades(studentId).startWith([]),
      watchStudentSubmissions(studentId).startWith([]),
      (
        List<AttendanceModel> attendance,
        List<GradeModel> grades,
        List<SubmissionModel> submissions,
      ) {
        double avgGrade = 0;
        if (grades.isNotEmpty) {
          avgGrade =
              grades.map((g) => g.percentage).reduce((a, b) => a + b) /
              grades.length;
        }

        double attendanceRate = 0;
        if (attendance.isNotEmpty) {
          int present = attendance.where((a) => a.isPresent).length;
          attendanceRate = (present / attendance.length) * 100;
        }

        return {
          'averageGrade': avgGrade.round(),
          'attendanceRate': attendanceRate.round(),
          'completedAssignments': submissions.length,
        };
      },
    ).handleError((error) {
      debugPrint('❌ watchStudentStats Error: $error');
      // لا ترمي خطأ هنا، بل أعد قيم افتراضية لضمان عمل الواجهة
      return {
        'averageGrade': 0,
        'attendanceRate': 0,
        'completedAssignments': 0,
      };
    });
  }

  /// بث جميع تسليمات الطالب عبر جميع التكاليف
  Stream<List<SubmissionModel>> watchStudentSubmissions(String studentId) {
    return _firestore
        .collectionGroup('submissions')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SubmissionModel.fromMap(doc.data(), docId: doc.id))
              .toList();
        })
        .onErrorReturnWith((error, stackTrace) {
          debugPrint('❌ watchStudentSubmissions Error: $error');
          return <SubmissionModel>[];
        });
  }

  /// بث إحصائيات المعلم (الطلاب، المهام، الدرجات المعلقة)
  Stream<Map<String, dynamic>> watchTeacherStats(String teacherId) {
    return Rx.combineLatest2(
      watchTeacherAssignments(teacherId),
      watchAllUsers(),
      (List<AssignmentModel> assignments, List<UserModel> users) {
        int totalStudents = users.where((u) => u.role == 'student').length;
        int activeAssignments = assignments.length;

        return {
          'totalStudents': totalStudents,
          'pendingGrades': 0, // Placeholder
          'activeSubjects': 0, // Placeholder
          'activeAssignments': activeAssignments,
        };
      },
    );
  }

  // ==================== المستخدمون ====================

  /// جلب جميع المستخدمين
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();
  }

  /// جلب المستخدمين حسب النوع
  Future<List<UserModel>> getUsersByRole(String role) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();
  }

  /// جلب مستخدم بالمعرف
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['uid'] = doc.id;
    return UserModel.fromMap(data);
  }

  /// تحديث بيانات مستخدم
  Future<void> updateUser(UserModel user) async {
    // 1. جلب البيانات القديمة للتحقق من تغيير الاسم
    final oldDoc = await _firestore.collection('users').doc(user.uid).get();
    final oldName = oldDoc.data()?['name'];

    // 2. تحديث وثيقة المستخدم الرئيسية
    await _firestore.collection('users').doc(user.uid).update(user.toMap());

    // 3. إذا تغير الاسم، نقوم بتحديث كل السجلات المرتبطة (Cascading Update)
    if (oldName != null && oldName != user.name) {
      await _updateUserRelatedRecords(user);
    }
  }

  /// تحديث السجلات المرتبطة عند تغيير الاسم (تصحيح البيانات التاريخية)
  Future<void> _updateUserRelatedRecords(UserModel user) async {
    final batch = _firestore.batch();

    // أ) إذا كان طالباً: تحديث الدرجات والحضور والتسليمات
    if (user.role == 'student') {
      // 1. الدرجات
      final gradesQuery = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: user.uid)
          .get();
      for (var doc in gradesQuery.docs) {
        batch.update(doc.reference, {'studentName': user.name});
      }

      // 2. الحضور
      final attendanceQuery = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: user.uid)
          .get();
      for (var doc in attendanceQuery.docs) {
        batch.update(doc.reference, {'studentName': user.name});
      }

      // 3. التسليمات (موجودة كـ Sub-collection داخل Assignments)
      // نستخدم CollectionGroup للوصول لكل التسليمات الخاصة بهذا الطالب
      final submissionsQuery = await _firestore
          .collectionGroup('submissions')
          .where('studentId', isEqualTo: user.uid)
          .get();
      for (var doc in submissionsQuery.docs) {
        batch.update(doc.reference, {'studentName': user.name});
      }
    }

    // ب) إذا كان معلماً: تحديث التكليفات التي أنشأها
    if (user.role == 'teacher') {
      final assignmentsQuery = await _firestore
          .collection('assignments')
          .where('teacherId', isEqualTo: user.uid)
          .get();
      for (var doc in assignmentsQuery.docs) {
        batch.update(doc.reference, {'teacherName': user.name});
      }
    }

    // تنفيذ التحديثات دفعة واحدة
    await batch.commit();
  }

  /// حذف مستخدم (تعطيل - Soft Delete)
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// حذف مستخدم نهائياً مع كافة بياناته (Hard Delete)
  Future<void> deleteUserPermanently(String uid, String role) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);

    // 1. حذف وثيقة المستخدم
    batch.delete(userRef);

    // 2. حذف البيانات المرتبطة (Cascading Delete)
    if (role == 'student') {
      // درجات
      final grades = await _firestore
          .collection('grades')
          .where('studentId', isEqualTo: uid)
          .get();
      for (var doc in grades.docs) batch.delete(doc.reference);

      // حضور
      final attendance = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: uid)
          .get();
      for (var doc in attendance.docs) batch.delete(doc.reference);

      // تسليمات
      final submissions = await _firestore
          .collectionGroup('submissions')
          .where('studentId', isEqualTo: uid)
          .get();
      for (var doc in submissions.docs) batch.delete(doc.reference);
    }

    if (role == 'teacher') {
      // تكليفات المعلم
      final assignments = await _firestore
          .collection('assignments')
          .where('teacherId', isEqualTo: uid)
          .get();
      for (var doc in assignments.docs) batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ==================== المواد ====================

  /// جلب جميع المواد
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return SubjectModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Firestore Error (getAllSubjects): $e');
      rethrow;
    }
  }

  /// إضافة مادة
  Future<String> addSubject(SubjectModel subject) async {
    final doc = await _firestore.collection('subjects').add(subject.toMap());
    return doc.id;
  }

  /// تحديث مادة
  Future<void> updateSubject(SubjectModel subject) async {
    await _firestore.collection('subjects').doc(subject.id).update({
      ...subject.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// حذف مادة
  Future<void> deleteSubject(String id) async {
    await _firestore.collection('subjects').doc(id).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== الصفوف ====================

  /// جلب صف بالمعرف
  Future<ClassModel?> getClassById(String id) async {
    final doc = await _firestore.collection('classes').doc(id).get();
    if (!doc.exists) return null;
    return ClassModel.fromMap(doc.data()!, docId: doc.id);
  }

  /// جلب جميع الصفوف
  Future<List<ClassModel>> getAllClasses() async {
    try {
      final snapshot = await _firestore
          .collection('classes')
          .where('isActive', isEqualTo: true)
          .orderBy('grade')
          .get();

      return snapshot.docs.map((doc) {
        return ClassModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      // Fallback: Fetch without orderBy if index is missing
      debugPrint('⚠️ Falling back to in-memory sort for classes: $e');
      try {
        final snapshot = await _firestore
            .collection('classes')
            .where('isActive', isEqualTo: true)
            .get();

        final classes = snapshot.docs.map((doc) {
          return ClassModel.fromMap(doc.data(), docId: doc.id);
        }).toList();

        classes.sort((a, b) => a.grade.compareTo(b.grade));
        return classes;
      } catch (e2) {
        debugPrint('❌ Firestore Error (getAllClasses): $e2');
        rethrow;
      }
    }
  }

  /// إضافة صف
  Future<String> addClass(ClassModel classModel) async {
    final doc = await _firestore.collection('classes').add(classModel.toMap());
    return doc.id;
  }

  /// تحديث صف
  Future<void> updateClass(ClassModel classModel) async {
    await _firestore.collection('classes').doc(classModel.id).update({
      ...classModel.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// حذف صف
  Future<void> deleteClass(String id) async {
    await _firestore.collection('classes').doc(id).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== الحضور ====================

  /// جلب حضور طالب
  Future<List<AttendanceModel>> getStudentAttendance(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Falling back to in-memory sort for attendance: $e');
      final snapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();

      final list = snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
  }

  /// جلب حضور صف في تاريخ ومادة معينة
  Future<List<AttendanceModel>> getClassAttendance(
    String classId,
    String subjectId,
    String date,
  ) async {
    final snapshot = await _firestore
        .collection('attendance')
        .where('classId', isEqualTo: classId)
        .where('subjectId', isEqualTo: subjectId)
        .where('date', isEqualTo: date)
        .get();

    return snapshot.docs.map((doc) {
      return AttendanceModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  /// إضافة حضور
  Future<String> addAttendance(AttendanceModel attendance) async {
    final doc = await _firestore
        .collection('attendance')
        .add(attendance.toMap());
    return doc.id;
  }

  // ==================== الدرجات ====================

  /// جلب درجات طالب
  Future<List<GradeModel>> getStudentGrades(String studentId) async {
    final snapshot = await _firestore
        .collection('grades')
        .where('studentId', isEqualTo: studentId)
        .get();

    return snapshot.docs.map((doc) {
      return GradeModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  /// جلب درجات مادة
  Future<List<GradeModel>> getSubjectGrades(String subjectId) async {
    final snapshot = await _firestore
        .collection('grades')
        .where('subjectId', isEqualTo: subjectId)
        .get();

    return snapshot.docs.map((doc) {
      return GradeModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  /// إضافة درجة
  Future<String> addGrade(GradeModel grade) async {
    final doc = await _firestore.collection('grades').add(grade.toMap());
    return doc.id;
  }

  // ==================== التكاليف ====================

  /// جلب التكاليف لصف
  Future<List<AssignmentModel>> getClassAssignments(String classId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('classId', isEqualTo: classId)
          .orderBy('dueDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AssignmentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Falling back to in-memory sort for class assignments: $e');
      final snapshot = await _firestore
          .collection('assignments')
          .where('classId', isEqualTo: classId)
          .get();

      final list = snapshot.docs.map((doc) {
        return AssignmentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      return list;
    }
  }

  /// جلب التكاليف للمعلم
  Future<List<AssignmentModel>> getTeacherAssignments(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('dueDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AssignmentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    } catch (e) {
      debugPrint(
        '⚠️ Falling back to in-memory sort for teacher assignments: $e',
      );
      final snapshot = await _firestore
          .collection('assignments')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final list = snapshot.docs.map((doc) {
        return AssignmentModel.fromMap(doc.data(), docId: doc.id);
      }).toList();

      list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      return list;
    }
  }

  /// إضافة تكليف
  Future<String> addAssignment(AssignmentModel assignment) async {
    final doc = await _firestore
        .collection('assignments')
        .add(assignment.toMap());
    return doc.id;
  }

  /// جلب تسليمات تكليف
  Future<List<SubmissionModel>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    final snapshot = await _firestore
        .collection('assignments')
        .doc(assignmentId)
        .collection('submissions')
        .get();

    return snapshot.docs.map((doc) {
      return SubmissionModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }

  /// إضافة تسليم
  Future<String> addSubmission(
    String assignmentId,
    SubmissionModel submission,
  ) async {
    final doc = await _firestore
        .collection('assignments')
        .doc(assignmentId)
        .collection('submissions')
        .add(submission.toMap());
    return doc.id;
  }

  /// تقييم تسليم
  /// تقييم تسليم
  Future<void> gradeSubmission(
    String assignmentId,
    String submissionId,
    double grade,
    String? notes,
  ) async {
    await _firestore
        .collection('assignments')
        .doc(assignmentId)
        .collection('submissions')
        .doc(submissionId)
        .update({
          'status': 'graded',
          'grade': grade,
          'teacherNotes': notes,
          'gradedAt': FieldValue.serverTimestamp(),
        });
  }

  // ==================== التقارير ====================

  /// إحصائيات عامة
  Future<Map<String, int>> getStatistics() async {
    final usersSnapshot = await _firestore
        .collection('users')
        .where('isActive', isEqualTo: true)
        .get();

    int totalUsers = usersSnapshot.docs.length;
    int teachers = usersSnapshot.docs
        .where((d) => d['role'] == 'teacher')
        .length;
    int students = usersSnapshot.docs
        .where((d) => d['role'] == 'student')
        .length;

    final subjectsSnapshot = await _firestore
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .get();

    final classesSnapshot = await _firestore
        .collection('classes')
        .where('isActive', isEqualTo: true)
        .get();

    return {
      'totalUsers': totalUsers,
      'teachers': teachers,
      'students': students,
      'subjects': subjectsSnapshot.docs.length,
      'classes': classesSnapshot.docs.length,
    };
  }

  /// جلب الطلاب حسب الصف
  Future<List<UserModel>> getStudentsByClass(String classId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: classId)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();
  }

  // ==================== إحصائيات متقدمة ====================

  /// جلب إحصائيات الطالب للوحة التحكم
  Future<Map<String, dynamic>> getStudentStats(String studentId) async {
    try {
      // 1. المعدل العام
      final grades = await getStudentGrades(studentId);
      double avgGrade = 0;
      if (grades.isNotEmpty) {
        avgGrade =
            grades.map((g) => g.percentage).reduce((a, b) => a + b) /
            grades.length;
      }

      // 2. نسبة الحضور
      final attendance = await getStudentAttendance(studentId);
      double attendanceRate = 0;
      if (attendance.isNotEmpty) {
        int present = attendance.where((a) => a.isPresent).length;
        attendanceRate = (present / attendance.length) * 100;
      }

      // 3. التكاليف المعلقة
      final user = await getUserById(studentId);
      int pendingAssignments = 0;
      if (user?.classId != null) {
        final assignments = await getClassAssignments(user!.classId!);
        for (var assignment in assignments) {
          final submissions = await getAssignmentSubmissions(assignment.id);
          bool submitted = submissions.any((s) => s.studentId == studentId);
          if (!submitted) {
            final dueDate = DateTime.tryParse(assignment.dueDate);
            if (dueDate != null && dueDate.isAfter(DateTime.now())) {
              pendingAssignments++;
            }
          }
        }
      }

      return {
        'avgGrade': avgGrade,
        'attendanceRate': attendanceRate,
        'pendingAssignments': pendingAssignments,
      };
    } catch (e) {
      debugPrint('Error getting student stats: $e');
      return {'avgGrade': 0.0, 'attendanceRate': 0.0, 'pendingAssignments': 0};
    }
  }

  /// جلب إحصائيات المعلم للوحة التحكم
  Future<Map<String, dynamic>> getTeacherStats(String teacherId) async {
    try {
      // 1. عدد الطلاب الإجمالي في مواده
      final subjects = await _firestore
          .collection('subjects')
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .get();

      // الحصول على الصفوف الفريدة المرتبطة بالمواد
      // (ملاحظة: نحتاج مستقبلاً لربط المادة بصفوف محددة، حالياً نفترض جميع طلاب المدرسة في مواده إذا كان يدرسها)
      // للتبسيط حالياً: سنحسب إجمالي عدد الطلاب
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('isActive', isEqualTo: true)
          .get();

      // 2. تكاليف تحتاج تقييم
      final assignments = await getTeacherAssignments(teacherId);
      int pendingGrades = 0;
      for (var assignment in assignments) {
        final submissions = await getAssignmentSubmissions(assignment.id);
        pendingGrades += submissions.where((s) => s.status != 'graded').length;
      }

      return {
        'totalStudents': studentsSnapshot.docs.length,
        'pendingGrades': pendingGrades,
        'activeSubjects': subjects.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting teacher stats: $e');
      return {'totalStudents': 0, 'pendingGrades': 0, 'activeSubjects': 0};
    }
  }

  /// جلب درجات صف لمادة ونوع اختبار معين (للتحميل المسبق)
  Future<List<GradeModel>> getClassGradesRecord(
    String classId,
    String subjectId,
    String examType,
  ) async {
    final snapshot = await _firestore
        .collection('grades')
        .where('classId', isEqualTo: classId)
        .where('subjectId', isEqualTo: subjectId)
        .where('examType', isEqualTo: examType)
        .get();

    return snapshot.docs.map((doc) {
      return GradeModel.fromMap(doc.data(), docId: doc.id);
    }).toList();
  }
}
