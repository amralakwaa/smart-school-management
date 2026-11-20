import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج الحضور - Attendance Model

class AttendanceModel {
  final String? id;
  final int? localId; // للـ SQLite
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String teacherId;
  final String date; // YYYY-MM-DD
  final String status; // present, absent
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceModel({
    this.id,
    this.localId,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.teacherId,
    required this.date,
    required this.status,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// من Firestore
  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? docId}) {
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

    return AttendanceModel(
      id: docId ?? map['id'],
      studentId: map['studentId']?.toString() ?? '',
      studentName: map['studentName']?.toString() ?? '',
      subjectId: map['subjectId']?.toString() ?? '',
      subjectName: map['subjectName']?.toString() ?? '',
      classId: map['classId']?.toString() ?? '',
      teacherId: map['teacherId']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      status: map['status']?.toString() ?? 'absent',
      isSynced: true,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  /// من SQLite
  factory AttendanceModel.fromSqlite(Map<String, dynamic> map) {
    return AttendanceModel(
      localId: map['id'],
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? '',
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      classId: map['class_id'] ?? '',
      teacherId: map['teacher_id'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'absent',
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
      'date': date,
      'status': status,
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
      'date': date,
      'status': status,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';

  AttendanceModel copyWith({
    String? id,
    int? localId,
    String? studentId,
    String? studentName,
    String? subjectId,
    String? subjectName,
    String? classId,
    String? teacherId,
    String? date,
    String? status,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel(studentName: $studentName, date: $date, status: $status)';
  }
}
