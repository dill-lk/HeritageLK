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
import 'screens/quests_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeritageLK',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: buildHeritageTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const MainHomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/auth/callback': (_) => const AuthCallbackScreen(),
        '/home': (_) => const HomeScreen(),
        '/explore': (_) => const ExploreScreen(),
        '/scanner': (_) => const ScannerScreen(),
        '/quests': (_) => const QuestsScreen(),
        '/archive': (_) => const ArchiveScreen(),
        '/archive/shingo': (_) => const ShingoScreen(),
        '/archive/upload': (_) => const ContributeScreen(),
        '/archive/admin/generate': (_) => const GenerateArchiveScreen(),
        '/archive/detail': (_) => const ArchiveDetailScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/settings/personal': (_) => const SettingsDetailScreen(title: 'Personal Information', description: 'Manage the information connected to your HeritageLK profile.'),
        '/settings/security': (_) => const SettingsDetailScreen(title: 'Security', description: 'Keep your HeritageLK account secure and protected.'),
        '/settings/notifications': (_) => const SettingsDetailScreen(title: 'Notifications', description: 'Choose when HeritageLK should notify you.'),
        '/settings/privacy': (_) => const SettingsDetailScreen(title: 'Privacy & Data', description: 'Control how your heritage journey data is used.'),
        '/settings/help': (_) => const SettingsDetailScreen(title: 'Help & Support', description: 'Find answers and get help with HeritageLK.'),
        '/report-damage': (_) => const ReportDamageScreen(),
        '/report-admin': (_) => const ReportAdminScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/archive/')) {
          final archiveId = settings.name!.split('/').last;
          return MaterialPageRoute<void>(builder: (_) => ArchiveDetailScreen(archiveId: archiveId), settings: settings);
        }
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(body: SafeArea(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.location_off, color: Color(0xFFE76F51), size: 64),
            const SizedBox(height: 24),
            const Text('Page Not Found', style: TextStyle(color: Color(0xFFFEFAE0), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('The page you are looking for does not exist.', style: TextStyle(color: Color(0x80FEFAE0), fontSize: 14)),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/home'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF4A261), foregroundColor: const Color(0xFF100E0A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Go Home')),
          ])))),
          settings: settings,
        );
      },
    );
  }
}
