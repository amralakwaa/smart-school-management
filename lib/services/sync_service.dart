// خدمة المزامنة - Sync Service
// مزامنة البيانات بين SQLite و Firebase

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../models/attendance_model.dart';
import '../models/grade_model.dart';
import 'database_helper.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SyncService._init();

  /// التحقق من الاتصال
  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// مزامنة جميع البيانات المعلقة
  Future<void> syncAll() async {
    final isOnline = await _checkConnectivity();
    if (!isOnline) {
      debugPrint('📴 غير متصل - تم تأجيل المزامنة');
      return;
    }

    await _syncAttendance();
    await _syncGrades();
    await _processSyncQueue();

    debugPrint('✅ تمت المزامنة بنجاح');
  }

  /// مزامنة الحضور
  Future<void> _syncAttendance() async {
    final db = await DatabaseHelper.instance.database;

    // جلب السجلات غير المتزامنة
    final unsyncedRecords = await db.query(
      'attendance_local',
      where: 'is_synced = 0',
    );

    for (final record in unsyncedRecords) {
      try {
        final attendance = AttendanceModel.fromSqlite(record);

        // رفع إلى Firebase
        await _firestore.collection('attendance').add(attendance.toMap());

        // تحديث حالة المزامنة
        await db.update(
          'attendance_local',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [record['id']],
        );

        debugPrint('✅ تم مزامنة حضور: ${attendance.studentName}');
      } catch (e) {
        debugPrint('❌ فشل مزامنة حضور: $e');
        await _addToSyncQueue(
          'attendance_local',
          record['id'] as int,
          'insert',
          jsonEncode(record),
        );
      }
    }
  }

  /// مزامنة الدرجات
  Future<void> _syncGrades() async {
    final db = await DatabaseHelper.instance.database;

    // جلب السجلات غير المتزامنة
    final unsyncedRecords = await db.query(
      'grades_local',
      where: 'is_synced = 0',
    );

    for (final record in unsyncedRecords) {
      try {
        final grade = GradeModel.fromSqlite(record);

        // رفع إلى Firebase
        await _firestore.collection('grades').add(grade.toMap());

        // تحديث حالة المزامنة
        await db.update(
          'grades_local',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [record['id']],
        );

        debugPrint('✅ تم مزامنة درجة: ${grade.studentName}');
      } catch (e) {
        debugPrint('❌ فشل مزامنة درجة: $e');
        await _addToSyncQueue(
          'grades_local',
          record['id'] as int,
          'insert',
          jsonEncode(record),
        );
      }
    }
  }

  /// إضافة إلى قائمة المزامنة
  Future<void> _addToSyncQueue(
    String tableName,
    int recordId,
    String operation,
    String data,
  ) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// معالجة قائمة المزامنة
  Future<void> _processSyncQueue() async {
    final db = await DatabaseHelper.instance.database;

    final pendingItems = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
    );

    for (final item in pendingItems) {
      final attempts = (item['attempts'] as int) + 1;

      if (attempts > 5) {
        // فشل نهائي
        await db.update(
          'sync_queue',
          {'status': 'failed', 'attempts': attempts},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
        continue;
      }

      try {
        await db.update(
          'sync_queue',
          {'status': 'syncing', 'attempts': attempts},
          where: 'id = ?',
          whereArgs: [item['id']],
        );

        final tableName = item['table_name'] as String;
        final data = jsonDecode(item['data'] as String);

        if (tableName == 'attendance_local') {
          final attendance = AttendanceModel.fromSqlite(data);
          await _firestore.collection('attendance').add(attendance.toMap());
        } else if (tableName == 'grades_local') {
          final grade = GradeModel.fromSqlite(data);
          await _firestore.collection('grades').add(grade.toMap());
        }

        // نجاح
        await db.update(
          'sync_queue',
          {
            'status': 'completed',
            'synced_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [item['id']],
        );

        // تحديث السجل الأصلي
        await db.update(
          tableName,
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [item['record_id']],
        );
      } catch (e) {
        await db.update(
          'sync_queue',
          {
            'status': 'pending',
            'attempts': attempts,
            'error_message': e.toString(),
          },
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }
  }

  /// حالة المزامنة
  Future<Map<String, int>> getSyncStatus() async {
    final db = await DatabaseHelper.instance.database;

    final attendanceUnsynced = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM attendance_local WHERE is_synced = 0',
      ),
    );

    final gradesUnsynced = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM grades_local WHERE is_synced = 0',
      ),
    );

    final queuePending = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM sync_queue WHERE status = 'pending'",
      ),
    );

    return {
      'attendance': attendanceUnsynced ?? 0,
      'grades': gradesUnsynced ?? 0,
      'queue': queuePending ?? 0,
    };
  }
}
