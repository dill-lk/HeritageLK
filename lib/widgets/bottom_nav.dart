import 'package:flutter/material.dart';

import '../theme/heritage_colors.dart';

class HeritageBottomNav extends StatelessWidget {
  const HeritageBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _items = [
    (Icons.home_filled, 'Home', '/home'),
    (Icons.map_outlined, 'Explore', '/explore'),
    (Icons.camera_alt_outlined, 'Camera', '/scanner'),
    (Icons.explore_outlined, 'Quests', '/quests'),
    (Icons.menu_book_outlined, 'Archive', '/archive'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0x99231B12),
          border: Border.all(color: HeritageColors.orange.withOpacity(0.20)),
          borderRadius: BorderRadius.circular(42),
          boxShadow: const [BoxShadow(color: Color(0x8C000000), blurRadius: 24, offset: Offset(0, 12))],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = currentIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => Navigator.of(context).pushReplacementNamed(item.$3),
                borderRadius: BorderRadius.circular(30),
                child: Opacity(
                  opacity: selected ? 1 : 0.40,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(item.$1, size: 22, color: selected ? HeritageColors.orange : Colors.white),
                    const SizedBox(height: 4),
                    Text(item.$2.toUpperCase(), style: TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.bold, color: selected ? HeritageColors.orange : Colors.white)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
