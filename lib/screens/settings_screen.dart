// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100E0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 180,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'Settings',
                style: GoogleFonts.playfairDisplay(
                  color: HeritageColors.cream,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=800&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    color: const Color(0xFF100E0A).withValues(alpha:0.7),
                    colorBlendMode: BlendMode.darken,
                    errorWidget: (_, __, ___) => const ColoredBox(color: HeritageColors.brown),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF100E0A).withValues(alpha:0.1),
                          const Color(0xFF100E0A),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
              child: _round(
                Icons.arrow_back,
                () => Navigator.of(context).pushReplacementNamed('/profile'),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _sectionHeader('ACCOUNT'),
                  _buildSettingsGroup([
                    _CustomNavItem(
                      label: 'Personal Information',
                      icon: Icons.person_outline,
                      onTap: () => Navigator.of(context).pushNamed('/settings/personal'),
                    ),
                    _CustomNavItem(
                      label: 'Security',
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.of(context).pushNamed('/settings/security'),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _sectionHeader('PREFERENCES & PRIVACY'),
                  _buildSettingsGroup([
                    _CustomNavItem(
                      label: 'Notifications',
                      icon: Icons.notifications_none,
                      onTap: () => Navigator.of(context).pushNamed('/settings/notifications'),
                    ),
                    _CustomNavItem(
                      label: 'Privacy & Data',
                      icon: Icons.shield_outlined,
                      onTap: () => Navigator.of(context).pushNamed('/settings/privacy'),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _sectionHeader('SUPPORT'),
                  _buildSettingsGroup([
                    _CustomNavItem(
                      label: 'Help Center',
                      icon: Icons.help_outline,
                      onTap: () => Navigator.of(context).pushNamed('/settings/help'),
                    ),
                    _CustomNavItem(
                      label: 'Give Feedback',
                      icon: Icons.message_outlined,
                      onTap: () => Navigator.of(context).pushNamed('/settings/help'),
                    ),
                  ]),
                  const SizedBox(height: 48),
                  _buildLogoutButton(),
                  const SizedBox(height: 48),
                  _buildVersionFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF4A261),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<_CustomNavItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.05)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final int idx = entry.key;
          final _CustomNavItem item = entry.value;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(idx == 0 ? 16 : 0),
                    bottom: Radius.circular(idx == items.length - 1 ? 16 : 0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(item.icon, color: HeritageColors.orange, size: 22),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withValues(alpha:0.3),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (idx != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha:0.05),
                  indent: 54,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE76F51).withValues(alpha:0.1),
            border: Border.all(color: const Color(0xFFE76F51).withValues(alpha:0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Color(0xFFE76F51), size: 20),
              SizedBox(width: 12),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFE76F51),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: HeritageColors.orange.withValues(alpha:0.8),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PRESERVE THE LEGACY',
                style: TextStyle(
                  color: HeritageColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Version 2.4.1 (Pro Build)',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action, {Color iconColor = HeritageColors.orange}) =>
      InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      );
}

class _CustomNavItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  
  const _CustomNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
