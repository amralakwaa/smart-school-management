import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج التكليف - Assignment Model

class AssignmentModel {
  final String id;
  final String title;
  final String? description;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String teacherId;
  final String teacherName;
  final String dueDate; // YYYY-MM-DD
  final double maxGrade;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.teacherId,
    required this.teacherName,
    required this.dueDate,
    this.maxGrade = 20,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
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

    return AssignmentModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      dueDate: map['dueDate'] ?? '',
      maxGrade: (map['maxGrade'] ?? 20).toDouble(),
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'classId': classId,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'dueDate': dueDate,
      'maxGrade': maxGrade,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// هل انتهى الموعد؟
  bool get isOverdue {
    final due = DateTime.parse(dueDate);
    return DateTime.now().isAfter(due);
  }

  AssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    String? classId,
    String? teacherId,
    String? teacherName,
    String? dueDate,
    double? maxGrade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      dueDate: dueDate ?? this.dueDate,
      maxGrade: maxGrade ?? this.maxGrade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AssignmentModel(title: $title, dueDate: $dueDate)';
  }
}

/// نموذج تسليم التكليف - Submission Model
class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String? fileUrl;
  final String? fileName;
  final String? notes;
  final String status; // submitted, graded
  final double? grade;
  final String? teacherNotes;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    this.fileUrl,
    this.fileName,
    this.notes,
    required this.status,
    this.grade,
    this.teacherNotes,
    required this.submittedAt,
    this.gradedAt,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
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

    return SubmissionModel(
      id: docId ?? map['id'] ?? '',
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      notes: map['notes'],
      status: map['status'] ?? 'submitted',
      grade: map['grade']?.toDouble(),
      teacherNotes: map['teacherNotes'],
      submittedAt: parseDateTime(map['submittedAt']),
      gradedAt: map['gradedAt'] != null ? parseDateTime(map['gradedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'notes': notes,
      'status': status,
      'grade': grade,
      'teacherNotes': teacherNotes,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
    };
  }

  bool get isGraded => status == 'graded';
  bool get isSubmitted => status == 'submitted';

  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? studentName,
    String? fileUrl,
    String? fileName,
    String? notes,
    String? status,
    double? grade,
    String? teacherNotes,
    DateTime? submittedAt,
    DateTime? gradedAt,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }

  @override
  String toString() {
    return 'SubmissionModel(studentName: $studentName, status: $status)';
  }
}
