import 'package:flutter/material.dart';

import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class DestinationScreen extends StatelessWidget {
  const DestinationScreen({super.key, required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 130), children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              InkWell(onTap: () => Navigator.of(context).pushReplacementNamed('/home'), borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: HeritageColors.orange))),
              Text(title, style: const TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 22)),
              const SizedBox(width: 40),
            ]),
            const SizedBox(height: 42),
            Container(height: 230, decoration: BoxDecoration(color: HeritageColors.brown.withOpacity(0.14), border: Border.all(color: HeritageColors.brown.withOpacity(0.30)), borderRadius: BorderRadius.circular(24)), child: Center(child: Icon(icon, color: HeritageColors.orange, size: 72))),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(color: HeritageColors.cream, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: HeritageColors.brown, fontSize: 15, height: 1.6)),
            const SizedBox(height: 28),
            ...['Galle Dutch Fort', 'Sigiriya Rock Fortress', 'Temple of the Sacred Tooth Relic'].map((name) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.07)), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(icon, color: HeritageColors.orange), const SizedBox(width: 14), Expanded(child: Text(name, style: const TextStyle(color: HeritageColors.cream, fontWeight: FontWeight.w600))), const Icon(Icons.chevron_right, color: Color(0x80FFFFFF))])))
          ]),
          const Align(alignment: Alignment.bottomCenter, child: HeritageBottomNav()),
        ]),
      ),
    );
  }
}
