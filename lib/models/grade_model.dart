import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج الدرجات - Grade Model

class GradeModel {
  final String? id;
  final int? localId; // للـ SQLite
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String teacherId;
  final String examType; // monthly1, monthly2, final
  final double grade;
  final double maxGrade;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradeModel({
    this.id,
    this.localId,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.teacherId,
    required this.examType,
    required this.grade,
    this.maxGrade = 100,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// من Firestore
  factory GradeModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return GradeModel(
      id: docId ?? map['id'],
      studentId: map['studentId']?.toString() ?? '',
      studentName: map['studentName']?.toString() ?? '',
      subjectId: map['subjectId']?.toString() ?? '',
      subjectName: map['subjectName']?.toString() ?? '',
      classId: map['classId']?.toString() ?? '',
      teacherId: map['teacherId']?.toString() ?? '',
      examType: map['examType']?.toString() ?? 'monthly1',
      grade: parseDouble(map['grade']),
      maxGrade: parseDouble(map['maxGrade']),
      isSynced: true,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  /// من SQLite
  factory GradeModel.fromSqlite(Map<String, dynamic> map) {
    return GradeModel(
      localId: map['id'],
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? '',
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      classId: map['class_id'] ?? '',
      teacherId: map['teacher_id'] ?? '',
      examType: map['exam_type'] ?? 'monthly1',
      grade: (map['grade'] ?? 0).toDouble(),
      maxGrade: (map['max_grade'] ?? 100).toDouble(),
      isSynced: map['is_synced'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// إلى Firestore
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

  /// إلى SQLite
  Map<String, dynamic> toSqliteMap() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'subject_id': subjectId,
      'subject_name': subjectName,
      'class_id': classId,
      'teacher_id': teacherId,
      'exam_type': examType,
      'grade': grade,
      'max_grade': maxGrade,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// النسبة المئوية
  double get percentage => (grade / maxGrade) * 100;

  /// اسم نوع الاختبار بالعربي
  String get examTypeName {
    switch (examType) {
      case 'monthly1':
        return 'الاختبار الشهري الأول';
      case 'monthly2':
        return 'الاختبار الشهري الثاني';
      case 'final':
        return 'الاختبار النهائي';
      default:
        return examType;
    }
  }

  GradeModel copyWith({
    String? id,
    int? localId,
    String? studentId,
    String? studentName,
    String? subjectId,
    String? subjectName,
    String? classId,
    String? teacherId,
    String? examType,
    double? grade,
    double? maxGrade,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GradeModel(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      examType: examType ?? this.examType,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GradeModel(studentName: $studentName, subject: $subjectName, grade: $grade/$maxGrade)';
  }
}
