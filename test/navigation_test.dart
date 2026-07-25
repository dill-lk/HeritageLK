import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heritage_lk/main.dart';

void main() {
  group('Navigation Routes', () {
    testWidgets('MainHomeScreen renders with HeritageLK title', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      expect(find.text('HeritageLK'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Login screen renders', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Signup screen renders', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Begin Journey'), findsOneWidget);
    });

    testWidgets('404 page renders for unknown routes', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      final state = tester.state<NavigatorState>(find.byType(Navigator).first);
      state.pushNamed('/nonexistent');
      await tester.pumpAndSettle();
      expect(find.text('Page Not Found'), findsOneWidget);
      expect(find.text('Go Home'), findsOneWidget);
    });

    testWidgets('Home screen renders with dashboard elements', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      // Skip actual auth, navigate directly
      final state = tester.state<NavigatorState>(find.byType(Navigator).first);
      state.pushReplacementNamed('/home');
      await tester.pumpAndSettle();
      expect(find.text('Protect.\nDiscover.'), findsOneWidget);
      expect(find.text('Celebrate.'), findsOneWidget);
    });

    testWidgets('Bottom nav has 6 tabs', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      final state = tester.state<NavigatorState>(find.byType(Navigator).first);
      state.pushReplacementNamed('/home');
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('EXPLORE'), findsOneWidget);
      expect(find.text('CAMERA'), findsOneWidget);
      expect(find.text('QUESTS'), findsOneWidget);
      expect(find.text('ARCHIVE'), findsOneWidget);
      expect(find.text('SHINGO'), findsOneWidget);
    });

    testWidgets('Settings screen renders', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      final state = tester.state<NavigatorState>(find.byType(Navigator).first);
      state.pushReplacementNamed('/settings');
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('PREFERENCES & PRIVACY'), findsOneWidget);
      expect(find.text('SUPPORT'), findsOneWidget);
    });

    testWidgets('Shingo AI screen renders', (tester) async {
      await tester.pumpWidget(const HeritageLkApp());
      final state = tester.state<NavigatorState>(find.byType(Navigator).first);
      state.pushReplacementNamed('/archive/shingo');
      await tester.pumpAndSettle();
      expect(find.text('Shingo AI'), findsWidgets);
      expect(find.text('Ask Shingo...'), findsOneWidget);
    });
  });
}
