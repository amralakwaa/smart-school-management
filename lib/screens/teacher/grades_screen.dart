// شاشة إدخال الدرجات - Premium Grades Screen
// Real-time data synchronization directly with Firestore

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../models/subject_model.dart';
import '../../models/grade_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  Map<String, TextEditingController> _gradeControllers = {};
  String? _selectedClassId;
  String? _selectedSubjectId;
  String _selectedExamType = 'monthly1';
  bool _isSaving = false;

  late Stream<List<ClassModel>> _classesStream;
  late Stream<List<SubjectModel>> _subjectsStream;
  Stream<List<UserModel>>? _studentsStream;

  final List<Map<String, String>> _examTypes = [
    {'value': 'monthly1', 'label': 'الاختبار الشهري الأول'},
    {'value': 'monthly2', 'label': 'الاختبار الشهري الثاني'},
    {'value': 'final', 'label': 'الاختبار النهائي'},
  ];

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _classesStream = FirestoreService.instance.watchTeacherClasses(user.uid);
      _subjectsStream = FirestoreService.instance.watchTeacherSubjects(
        user.uid,
      );
    } else {
      _classesStream = Stream.value([]);
      _subjectsStream = Stream.value([]);
    }
  }

  void _updateStudentsStream(String? classId) {
    if (classId != null) {
      setState(() {
        _studentsStream = FirestoreService.instance.watchStudentsByClass(
          classId,
        );
      });
    } else {
      setState(() {
        _studentsStream = null;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      for (var controller in _gradeControllers.values) {
        controller.clear();
      }
    });
  }

  double? _calculateAverage() {
    if (_gradeControllers.isEmpty) return null;
    double total = 0;
    int count = 0;
    for (var controller in _gradeControllers.values) {
      if (controller.text.isNotEmpty) {
        final val = double.tryParse(controller.text);
        if (val != null) {
          total += val;
          count++;
        }
      }
    }
    return count > 0 ? total / count : null;
  }

  Future<void> _saveGrades(List<UserModel> students) async {
    if (_selectedClassId == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار الصف والمادة')));
      return;
    }

    for (var controller in _gradeControllers.values) {
      if (controller.text.isNotEmpty) {
        final val = double.tryParse(controller.text);
        if (val == null || val < 0 || val > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى التأكد من أن جميع الدرجات بين 0 و 100'),
            ),
          );
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    try {
      final teacher = AuthService.instance.currentUser!;
      final subjects = await FirestoreService.instance.getAllSubjects();
      final subject = subjects.firstWhere((s) => s.id == _selectedSubjectId);
      final subjectName = subject.name;

      for (final student in students) {
        final gradeText = _gradeControllers[student.uid]?.text ?? '';
        if (gradeText.isEmpty) continue;

        final gradeValue = double.tryParse(gradeText);
        if (gradeValue == null) continue;

        final grade = GradeModel(
          id: '',
          studentId: student.uid,
          studentName: student.name,
          subjectId: _selectedSubjectId!,
          subjectName: subjectName,
          classId: _selectedClassId!,
          teacherId: teacher.uid,
          examType: _selectedExamType,
          grade: gradeValue,
          maxGrade: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await FirestoreService.instance.addGrade(grade);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('تم حفظ الدرجات بنجاح في الخادم ✓'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الحفظ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: CustomScrollView(
          slivers: [
            // Premium Header
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        Color(0xFFFF8A65),
                        Color(0xFFFFB74D),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.quiz_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'رصد الدرجات',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'إدارة نتائج الطلاب والاختبارات',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'حفظ مباشر',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Filters Section
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -15),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Exam Type
                      _buildDropdown(
                        value: _selectedExamType,
                        hint: 'نوع الاختبار',
                        icon: Icons.assignment_turned_in_rounded,
                        items: _examTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type['value'],
                                child: Text(type['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedExamType = value!),
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 12),

                      // Row for Class and Subject
                      Row(
                        children: [
                          Expanded(
                            child: StreamBuilder<List<ClassModel>>(
                              stream: _classesStream,
                              builder: (context, snapshot) {
                                final classes = snapshot.data ?? [];
                                return _buildDropdown(
                                  value: _selectedClassId,
                                  hint: 'الصف',
                                  icon: Icons.class_rounded,
                                  items: classes
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClassId = value;
                                      for (var controller
                                          in _gradeControllers.values) {
                                        controller.dispose();
                                      }
                                      _gradeControllers = {};
                                    });
                                    _updateStudentsStream(value);
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<List<SubjectModel>>(
                              stream: _subjectsStream,
                              builder: (context, snapshot) {
                                final subjects = snapshot.data ?? [];
                                return _buildDropdown(
                                  value: _selectedSubjectId,
                                  hint: 'المادة',
                                  icon: Icons.menu_book_rounded,
                                  items: subjects
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) => setState(
                                    () => _selectedSubjectId = value,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Students Content
            if (_selectedClassId == null || _selectedSubjectId == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          size: 64,
                          color: AppTheme.primaryColor.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'اختر الصف والمادة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابدأ بإدخال الدرجات بعد تحديد الخيارات أعلاه',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              StreamBuilder<List<UserModel>>(
                stream: _studentsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final students = snapshot.data ?? [];
                  for (var student in students) {
                    _gradeControllers.putIfAbsent(
                      student.uid,
                      () => TextEditingController(),
                    );
                  }

                  if (students.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'لا يوجد طلاب مسجلين',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0) {
                          return _buildQuickActions();
                        }
                        final student = students[index - 1];
                        return _buildStudentGradeCard(student, index);
                      }, childCount: students.length + 1),
                    ),
                  );
                },
              ),
          ],
        ),
        bottomNavigationBar:
            _selectedClassId != null && _selectedSubjectId != null
            ? _buildBottomButton()
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  hint,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _clearAll,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.clear_all_rounded,
                  color: AppTheme.errorColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'مسح جميع الحقول (Clear All)',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGradeCard(UserModel student, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    'رقم الطالب: ${student.uid.substring(0, 5)}...',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _gradeControllers[student.uid],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                ),
                decoration: InputDecoration(
                  hintText: '-',
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final avg = _calculateAverage();
    return StreamBuilder<List<UserModel>>(
      stream: _studentsStream,
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];
        if (students.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'متوسط درجات الفصل:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            avg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveGrades(students),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_rounded),
                              SizedBox(width: 10),
                              Text(
                                'حفظ النتائج نهائياً',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
