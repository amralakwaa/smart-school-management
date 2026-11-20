// خدمة قاعدة البيانات المحلية SQLite
// Database Helper Service

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// الحصول على قاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_management.db');
    return _database!;
  }

  /// تهيئة قاعدة البيانات
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// إنشاء الجداول
  Future<void> _createDB(Database db, int version) async {
    // جدول المستخدم المحلي (للتسجيل بدون إنترنت)
    await db.execute('''
      CREATE TABLE user_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE NOT NULL,
        email TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        password TEXT,
        name TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('admin', 'teacher', 'student')),
        class_id TEXT,
        subject_ids TEXT,
        phone TEXT,
        is_logged_in INTEGER DEFAULT 1,
        last_sync_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ... (omitted similar parts for brevity if replacing large block, but here I replace targeted)

    await db.execute('CREATE UNIQUE INDEX idx_user_email ON user_cache(email)');
    await db.execute(
      'CREATE INDEX idx_user_logged_in ON user_cache(is_logged_in)',
    );

    // جدول الحضور المحلي
    await db.execute('''
      CREATE TABLE attendance_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        student_name TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        class_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('present', 'absent')),
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_attendance_date ON attendance_local(date)',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_student ON attendance_local(student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_sync ON attendance_local(is_synced)',
    );

    // جدول الدرجات المحلي
    await db.execute('''
      CREATE TABLE grades_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        student_name TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        class_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        exam_type TEXT NOT NULL,
        grade REAL NOT NULL,
        max_grade REAL DEFAULT 100,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_grades_student ON grades_local(student_id)',
    );
    await db.execute(
      'CREATE INDEX idx_grades_subject ON grades_local(subject_id)',
    );
    await db.execute('CREATE INDEX idx_grades_sync ON grades_local(is_synced)');

    // جدول قائمة المزامنة
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
        data TEXT NOT NULL,
        attempts INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'syncing', 'failed', 'completed')),
        error_message TEXT,
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_sync_status ON sync_queue(status)');

    debugPrint('✅ تم إنشاء جداول قاعدة البيانات بنجاح');
  }

  /// ترقية قاعدة البيانات
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // محاولة إضافة العمود، مع تجاهل الخطأ إذا كان موجوداً مسبقاً
      try {
        await db.execute('ALTER TABLE user_cache ADD COLUMN password TEXT');
      } catch (e) {
        debugPrint('⚠️ العمود password قد يكون موجوداً بالفعل: $e');
      }
    }
  }

  /// إغلاق قاعدة البيانات
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  /// حذف قاعدة البيانات (للاختبار)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'school_management.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
