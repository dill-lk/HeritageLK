import 'package:flutter/material.dart';

import '../theme/heritage_colors.dart';

class SettingsDetailScreen extends StatelessWidget {
  const SettingsDetailScreen({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Row(children: [_round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/settings')), const SizedBox(width: 16), Text(title, style: const TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 32),
              Text(description, style: const TextStyle(color: Color(0x99FEFAE0), fontSize: 14, height: 1.6)),
              const SizedBox(height: 24),
              ...['Profile visibility', 'Email notifications', 'Location services', 'Personalized recommendations'].map((label) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.07)), borderRadius: BorderRadius.circular(16)), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w500))), Switch(value: true, activeColor: Colors.white, activeTrackColor: HeritageColors.orange, onChanged: (_) {})])))
            ],
          ),
        ),
      );

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), shape: BoxShape.circle), child: Icon(icon, color: HeritageColors.orange, size: 20)));
}
