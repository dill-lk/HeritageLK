import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'screens/main_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/shingo_screen.dart';
import 'screens/contribute_screen.dart';
import 'screens/report_damage_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/archive_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/hotels_screen.dart';
import 'screens/settings_detail_screen.dart';
import 'screens/generate_archive_screen.dart';
import 'screens/report_admin_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_callback_screen.dart';
import 'theme/heritage_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseAnonKey);
  }
  runApp(const HeritageLkApp());
}

class HeritageLkApp extends StatefulWidget {
  const HeritageLkApp({super.key});

  @override
  State<HeritageLkApp> createState() => _HeritageLkAppState();
}

class _HeritageLkAppState extends State<HeritageLkApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    if (AppConfig.hasSupabase) {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        final event = data.event;
        if (event == AuthChangeEvent.passwordRecovery && session != null) {
          navigatorKey.currentState?.pushReplacementNamed('/home');
        }
      });
    }
  }

  @override
  void dispose() {
    if (AppConfig.hasSupabase) _authSubscription.cancel();
    super.dispose();
  }

  static Route<T> _createRoute<T>(WidgetBuilder builder) {
    return PageRouteBuilder<T>(
      settings: const RouteSettings(name: ''),
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return FadeTransition(opacity: animation.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve))), child: SlideTransition(position: offsetAnimation, child: child));
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  Route<T> _onGenerateRoute<T>(RouteSettings settings) {
    WidgetBuilder? builder;
    switch (settings.name) {
      case '/':
        builder = (_) => const MainHomeScreen();
      case '/login':
        builder = (_) => const LoginScreen();
      case '/signup':
        builder = (_) => const SignupScreen();
      case '/auth/callback':
        builder = (_) => const AuthCallbackScreen();
      case '/home':
        builder = (_) => const HomeScreen();
      case '/explore':
        builder = (_) => const ExploreScreen();
      case '/scanner':
        builder = (_) => const ScannerScreen();
      case '/hotels':
        builder = (_) => const HotelsScreen();
      case '/archive':
        builder = (_) => const ArchiveScreen();
      case '/archive/shingo':
        builder = (_) => const ShingoScreen();
      case '/archive/upload':
        builder = (_) => const ContributeScreen();
      case '/archive/admin/generate':
        builder = (_) => const GenerateArchiveScreen();
      case '/profile':
        builder = (_) => const ProfileScreen();
      case '/settings':
        builder = (_) => const SettingsScreen();
      case '/settings/personal':
        builder = (_) => const SettingsDetailScreen(title: 'Personal Information', description: 'Manage the information connected to your HeritageLK profile.');
      case '/settings/security':
        builder = (_) => const SettingsDetailScreen(title: 'Security', description: 'Keep your HeritageLK account secure and protected.');
      case '/settings/notifications':
        builder = (_) => const SettingsDetailScreen(title: 'Notifications', description: 'Choose when HeritageLK should notify you.');
      case '/settings/privacy':
        builder = (_) => const SettingsDetailScreen(title: 'Privacy & Data', description: 'Control how your heritage journey data is used.');
      case '/settings/help':
        builder = (_) => const SettingsDetailScreen(title: 'Help & Support', description: 'Find answers and get help with HeritageLK.');
      case '/report-damage':
        builder = (_) => const ReportDamageScreen();
      case '/report-admin':
        builder = (_) => const ReportAdminScreen();
      default:
        if (settings.name != null && settings.name!.startsWith('/archive/')) {
          final archiveId = settings.name!.split('/').last;
          builder = (_) => ArchiveDetailScreen(archiveId: archiveId);
        }
    }

    if (builder != null) {
      return _createRoute(builder);
    }
    return MaterialPageRoute<T>(
      builder: (_) => Scaffold(body: SafeArea(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.location_off, color: Color(0xFFE76F51), size: 64),
        const SizedBox(height: 24),
        const Text('Page Not Found', style: TextStyle(color: Color(0xFFFEFAE0), fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('The page you are looking for does not exist.', style: TextStyle(color: Color(0x80FEFAE0), fontSize: 14)),
        const SizedBox(height: 32),
        FilledButton(onPressed: () => navigatorKey.currentState?.pushReplacementNamed('/home'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF4A261), foregroundColor: const Color(0xFF100E0A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Go Home')),
      ])))),
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeritageLK',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: buildHeritageTheme(),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
