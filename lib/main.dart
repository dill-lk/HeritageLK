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
import 'screens/placeholder_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/heritage_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  }
  runApp(const HeritageLkApp());
}

class HeritageLkApp extends StatelessWidget {
  const HeritageLkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeritageLK',
      debugShowCheckedModeBanner: false,
      theme: buildHeritageTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const MainHomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
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
        if (settings.name == '/auth/callback') {
          return MaterialPageRoute<void>(builder: (_) => const LoginScreen(), settings: settings);
        }
        return MaterialPageRoute<void>(builder: (_) => const PlaceholderScreen(title: 'Not Found'), settings: settings);
      },
    );
  }
}
