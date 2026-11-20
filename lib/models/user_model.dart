import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المستخدم - User Model
/// يمثل بيانات المستخدم في النظام (مدير، معلم، طالب)

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // admin, teacher, student
  final String? classId; // للطالب فقط
  final List<String>? subjectIds; // للمعلم فقط
  final String? phone;
  final String? password; // مضاف للمدير (اختياري)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.classId,
    this.subjectIds,
    this.phone,
    this.password,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// تحويل من Map (SQLite أو Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
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

    bool parseBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return true;
    }

    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.isNotEmpty) return [value];
      return [];
    }

    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: map['role']?.toString() ?? 'student',
      classId: map['classId']?.toString() ?? map['class_id']?.toString(),
      subjectIds: map['subjectIds'] != null
          ? parseList(map['subjectIds'])
          : map['subject_ids'] != null
          ? parseList(map['subject_ids'])
          : null,
      phone: map['phone']?.toString(),
      password: map['password']?.toString(),
      isActive: parseBool(map['isActive'] ?? map['is_active']),
      createdAt: parseDateTime(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDateTime(map['updatedAt'] ?? map['updated_at']),
    );
  }

  /// تحويل إلى Map (للحفظ في Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'classId': classId,
      'subjectIds': subjectIds,
      'phone': phone,
      'password': password,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// تحويل إلى Map (للحفظ في SQLite)
  Map<String, dynamic> toSqliteMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'class_id': classId,
      'subject_ids': subjectIds?.join(','),
      'phone': phone,
      'password': password,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// نسخة معدلة من المستخدم
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? classId,
    List<String>? subjectIds,
    String? phone,
    String? password,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      classId: classId ?? this.classId,
      subjectIds: subjectIds ?? this.subjectIds,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// هل المستخدم مدير؟
  bool get isAdmin => role == 'admin';

  /// هل المستخدم معلم؟
  bool get isTeacher => role == 'teacher';

  /// هل المستخدم طالب؟
  bool get isStudent => role == 'student';

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
  }
}
