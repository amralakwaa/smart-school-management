// نظام إدارة المدرسة الذكي
// Smart School Management System

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
// import 'admin_init_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعداد اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // إعداد شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // تهيئة Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // يمكن المتابعة بدون Firebase للوضع غير المتصل
  }

  // تهيئة التاريخ العربي
  await initializeDateFormatting('ar', null);

  runApp(const SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'نظام إدارة المدرسة الذكي',
      debugShowCheckedModeBanner: false,

      // الثيم
      theme: AppTheme.lightTheme,

      // دعم RTL
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // التنقل
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,

      // البناء
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: RealTimeAuthGuard(
            child: MediaQuery(
              // تحديد حجم الخط الأقصى
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}

/// حارس الأمان اللحظي - Real-time Auth Guard
/// يراقب حالة "isActive" للمستخدم الحالي ويقوم بتسجيل الخروج فوراً إذا تم تعطيله
class RealTimeAuthGuard extends StatefulWidget {
  final Widget child;
  const RealTimeAuthGuard({super.key, required this.child});

  @override
  State<RealTimeAuthGuard> createState() => _RealTimeAuthGuardState();
}

class _RealTimeAuthGuardState extends State<RealTimeAuthGuard> {
  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;

    if (currentUser == null) return widget.child;

    return StreamBuilder(
      stream: AuthService.instance.watchCurrentUser(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final currentPass = AuthService.instance.currentLoginPassword;

          // الخروج إذا تم تعطيل الحساب أو تغيير كلمة المرور من قبل المدير
          if (!user.isActive ||
              (currentPass != null &&
                  user.password != null &&
                  user.password != currentPass)) {
            // تنفيذ تسجيل الخروج الفوري في التيك التالي لتجنب تضارب البناء
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await AuthService.instance.signOut();
              if (mounted) {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );

                scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(
                      !user.isActive
                          ? 'تم تعطيل حسابك. الرجاء مراجعة الإدارة.'
                          : 'تم تغيير كلمة مرورك من قبل الإدارة. يرجى تسجيل الدخول مجدداً.',
                    ),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            });
          }
        }
        return widget.child;
      },
    );
  }
}

/// شاشة البداية للتحقق من الجلسة
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = await AuthService.instance.checkExistingSession();

    if (mounted) {
      if (user != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.getDashboardRoute(user.role),
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.school, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'نظام إدارة المدرسة الذكي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'جامعة ذمار',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
