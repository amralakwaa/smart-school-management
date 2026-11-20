import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المادة الدراسية - Subject Model

class SubjectModel {
  final String id;
  final String name;
  final String? description;
  final String teacherId;
  final String teacherName;
  final List<String> relatedClassIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.teacherId,
    required this.teacherName,
    this.relatedClassIds = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map, {String? docId}) {
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

    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return SubjectModel(
      id: docId ?? map['id'] ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      teacherId: map['teacherId']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      relatedClassIds: parseList(map['relatedClassIds']),
      isActive: map['isActive'] ?? true,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'relatedClassIds': relatedClassIds,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    String? teacherName,
    List<String>? relatedClassIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      relatedClassIds: relatedClassIds ?? this.relatedClassIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SubjectModel(id: $id, name: $name, teacherName: $teacherName, classes: $relatedClassIds)';
  }
}
