import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج الصف الدراسي - Class Model

class ClassModel {
  final String id;
  final String name;
  final int grade;
  final String? section;
  final int studentCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.grade,
    this.section,
    this.studentCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map, {String? docId}) {
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

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ClassModel(
      id: docId ?? map['id'] ?? '',
      name: map['name']?.toString() ?? '',
      grade: parseInt(map['grade']),
      section: map['section']?.toString(),
      studentCount: parseInt(map['studentCount']),
      isActive: map['isActive'] ?? true,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grade': grade,
      'section': section,
      'studentCount': studentCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    int? grade,
    String? section,
    int? studentCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      studentCount: studentCount ?? this.studentCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ClassModel(id: $id, name: $name, grade: $grade)';
  }
}
