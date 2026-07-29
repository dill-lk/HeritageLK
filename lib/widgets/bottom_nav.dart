import 'package:flutter/material.dart';

import '../theme/heritage_colors.dart';
import 'heritage_icons.dart';

class HeritageBottomNav extends StatelessWidget {
  const HeritageBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  Widget _getIcon(int index, Color color) {
    switch (index) {
      case 0:
        return HeritageIcons.home(color: color, size: 22);
      case 1:
        return HeritageIcons.explore(color: color, size: 22);
      case 2:
        return HeritageIcons.camera(color: color, size: 22);
      case 3:
        return Icon(Icons.hotel_rounded, color: color, size: 22);
      case 4:
        return HeritageIcons.archive(color: color, size: 22);
      case 5:
        return HeritageIcons.shingo(color: color, size: 22);
      default:
        return HeritageIcons.home(color: color, size: 22);
    }
  }

  static const _items = [
    ('Home', '/home'),
    ('Explore', '/explore'),
    ('Camera', '/scanner'),
    ('Hotels', '/hotels'),
    ('Archive', '/archive'),
    ('Shingo', '/archive/shingo'),
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
          border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.20)),
          borderRadius: BorderRadius.circular(42),
          boxShadow: const [BoxShadow(color: Color(0x8C000000), blurRadius: 24, offset: Offset(0, 12))],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = currentIndex == index;
            final color = selected ? HeritageColors.orange : Colors.white;
            return Expanded(
              child: InkWell(
                onTap: () => Navigator.of(context).pushReplacementNamed(item.$2),
                borderRadius: BorderRadius.circular(30),
                child: Opacity(
                  opacity: selected ? 1 : 0.40,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _getIcon(index, color),
                    const SizedBox(height: 4),
                    Text(item.$1.toUpperCase(), style: TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.bold, color: color)),
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

