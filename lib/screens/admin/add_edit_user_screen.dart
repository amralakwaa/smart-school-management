// شاشة إضافة/تعديل مستخدم - Premium Design

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../models/class_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class AddEditUserScreen extends StatefulWidget {
  final bool isEdit;
  final String? userId;

  const AddEditUserScreen({super.key, required this.isEdit, this.userId});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'student';
  String? _selectedClassId;
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  bool _isLoadingData = false;
  bool _obscurePassword = true;
  bool _isActive = true;
  UserModel? _existingUser;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    if (widget.isEdit && widget.userId != null) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await FirestoreService.instance.getAllClasses();
      if (!mounted) return;
      setState(() => _classes = classes);
    } catch (e) {
      debugPrint('Error loading classes: $e');
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingData = true);
    try {
      final user = await FirestoreService.instance.getUserById(widget.userId!);
      if (!mounted) return;
      if (user != null) {
        setState(() {
          _existingUser = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
          _passwordController.text = user.password ?? '';
          _selectedRole = user.role;
          _selectedClassId = user.classId;
          _isActive = user.isActive;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUserUid = AuthService.instance.currentUser?.uid;
      final isUpdatingSelf = widget.isEdit && widget.userId == currentUserUid;

      if (widget.isEdit) {
        final updatedUser = _existingUser!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          role: _selectedRole,
          classId: _selectedRole == 'student' ? _selectedClassId : null,
          password: _passwordController.text.trim().isEmpty
              ? _existingUser!.password
              : _passwordController.text.trim(),
          isActive: _isActive,
          updatedAt: DateTime.now(),
        );

        if (isUpdatingSelf &&
            _emailController.text.trim() != _existingUser!.email) {
          await AuthService.instance.updateEmail(_emailController.text.trim());
        }

        if (isUpdatingSelf && _passwordController.text.isNotEmpty) {
          await AuthService.instance.updatePassword(_passwordController.text);
        } else if (!isUpdatingSelf &&
            _passwordController.text.isNotEmpty &&
            _existingUser?.password != null) {
          await AuthService.instance.updateOtherUserPassword(
            email: _existingUser!.email,
            oldPassword: _existingUser!.password!,
            newPassword: _passwordController.text.trim(),
          );
        }

        await FirestoreService.instance.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('تم تحديث البيانات بنجاح'),
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
        }
      } else {
        await AuthService.instance.createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole,
          classId: _selectedRole == 'student' ? _selectedClassId : null,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('تم إنشاء المستخدم بنجاح'),
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
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Premium Header
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: AppTheme.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor,
                              const Color(0xFF6B5FCD),
                              const Color(0xFF7C4DFF),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(60, 40, 20, 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    widget.isEdit
                                        ? Icons.edit_note
                                        : Icons.person_add,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.isEdit
                                          ? 'تعديل مستخدم'
                                          : 'إضافة مستخدم جديد',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.isEdit
                                          ? 'تعديل بيانات المستخدم'
                                          : 'إنشاء حساب جديد',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
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
                  ),

                  // Form Content
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Info Section
                            _buildSectionHeader(
                              'المعلومات الأساسية',
                              Icons.person,
                            ),
                            const SizedBox(height: 16),

                            _buildPremiumTextField(
                              controller: _nameController,
                              label: 'الاسم الكامل',
                              hint: 'أدخل الاسم الكامل',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال الاسم';
                                }
                                if (value.length < 3) {
                                  return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildPremiumTextField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني',
                              hint: 'example@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال البريد الإلكتروني';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'يرجى إدخال بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildPremiumTextField(
                              controller: _passwordController,
                              label: widget.isEdit
                                  ? 'كلمة المرور'
                                  : 'كلمة المرور الجديدة',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              textDirection: TextDirection.ltr,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (!widget.isEdit &&
                                    (value == null || value.isEmpty)) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                if (value != null &&
                                    value.isNotEmpty &&
                                    value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),

                            if (widget.isEdit && _existingUser != null) ...[
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  try {
                                    await AuthService.instance
                                        .sendPasswordResetEmail(
                                          _emailController.text.trim(),
                                        );
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'تم إرسال رابط تعيين كلمة المرور',
                                          ),
                                          backgroundColor:
                                              AppTheme.successColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('خطأ: $e')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.send, size: 16),
                                label: const Text(
                                  'إرسال رابط تعيين كلمة المرور',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            _buildPremiumTextField(
                              controller: _phoneController,
                              label: 'رقم الهاتف (اختياري)',
                              hint: '05xxxxxxxx',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                            ),

                            const SizedBox(height: 32),

                            // Account Status Section
                            _buildSectionHeader('حالة الحساب', Icons.toggle_on),
                            const SizedBox(height: 16),

                            _buildStatusToggle(),

                            const SizedBox(height: 32),

                            // Role Selection Section
                            _buildSectionHeader('نوع المستخدم', Icons.badge),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildRoleCard(
                                    'معلم',
                                    'teacher',
                                    Icons.school,
                                    AppTheme.teacherColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildRoleCard(
                                    'طالب',
                                    'student',
                                    Icons.person,
                                    AppTheme.studentColor,
                                  ),
                                ),
                              ],
                            ),

                            // Class Selection (for students)
                            if (_selectedRole == 'student') ...[
                              const SizedBox(height: 24),
                              _buildSectionHeader('الصف الدراسي', Icons.class_),
                              const SizedBox(height: 16),
                              _buildClassDropdown(),
                            ],

                            const SizedBox(height: 32),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.save, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            widget.isEdit
                                                ? 'تحديث البيانات'
                                                : 'إنشاء الحساب',
                                            style: const TextStyle(
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
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextDirection? textDirection,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F9FE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isActive = !_isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isActive
              ? AppTheme.successColor.withOpacity(0.1)
              : AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isActive ? AppTheme.successColor : AppTheme.errorColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isActive
                    ? AppTheme.successColor.withOpacity(0.2)
                    : AppTheme.errorColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
                color: _isActive ? AppTheme.successColor : AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isActive ? 'الحساب نشط' : 'الحساب معطل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isActive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isActive
                        ? 'المستخدم يمكنه تسجيل الدخول'
                        : 'المستخدم لا يمكنه تسجيل الدخول',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: AppTheme.successColor,
              inactiveThumbColor: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
          if (value != 'student') _selectedClassId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedClassId,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.class_, color: AppTheme.primaryColor),
          labelText: 'اختر الصف',
        ),
        items: _classes.map((classModel) {
          return DropdownMenuItem(
            value: classModel.id,
            child: Text(classModel.name),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedClassId = value),
        validator: (value) {
          if (_selectedRole == 'student' && (value == null || value.isEmpty)) {
            return 'يرجى اختيار الصف';
          }
          return null;
        },
      ),
    );
  }
}
