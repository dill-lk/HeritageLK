// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';

const _loginHeroUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/b02856ceecd423ab75d2e1d643e2e881960878b0?width=880';
const _signupHeroUrl =
    'https://api.builder.io/api/v1/image/assets/TEMP/47289e9080e6b5ce0ff17dc9efea467aa2e8770b?width=880';

class HeritageAuthShell extends StatefulWidget {
  const HeritageAuthShell({
    super.key,
    required this.heroImageUrl,
    required this.formSection,
    this.brandItalic = false,
  });

  final String heroImageUrl;
  final Widget formSection;
  final bool brandItalic;

  static const loginHero = _loginHeroUrl;
  static const signupHero = _signupHeroUrl;

  @override
  State<HeritageAuthShell> createState() => _HeritageAuthShellState();
}

class _HeritageAuthShellState extends State<HeritageAuthShell> {
  bool _langOpen = false;
  int _langIndex = 0;

  static const _languages = [
    ('English', 'en'),
    ('සිංහල', 'si'),
    ('தமிழ்', 'ta'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ColoredBox(
            color: HeritageColors.background,
            child: Column(
              children: [
                _buildHero(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: widget.formSection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    final lang = _languages[_langIndex];
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.heroImageUrl,
            fit: BoxFit.cover,
            color: Colors.white.withValues(alpha: 0.4),
            colorBlendMode: BlendMode.modulate,
            errorBuilder: (_, __, ___) => ColoredBox(color: HeritageColors.brown.withValues(alpha: 0.5)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HeritageColors.background.withValues(alpha: 0.4),
                  Colors.transparent,
                  HeritageColors.background,
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LanguageControl(
                  open: _langOpen,
                  selectedLabel: lang.$1,
                  onToggle: () => setState(() => _langOpen = !_langOpen),
                  onSelect: (i) => setState(() {
                    _langIndex = i;
                    _langOpen = false;
                  }),
                  languages: _languages,
                ),
                _InfoButton(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('HeritageLK — Preserve Sri Lanka\'s legacy')),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HeritageLK',
                  style: GoogleFonts.inter(
                    color: HeritageColors.orange,
                    fontSize: 32,
                    fontStyle: widget.brandItalic ? FontStyle.italic : FontStyle.normal,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'JOIN THE LEGACY',
                  style: TextStyle(
                    color: HeritageColors.brown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageControl extends StatelessWidget {
  const _LanguageControl({
    required this.open,
    required this.selectedLabel,
    required this.onToggle,
    required this.onSelect,
    required this.languages,
  });

  final bool open;
  final String selectedLabel;
  final VoidCallback onToggle;
  final void Function(int index) onSelect;
  final List<(String, String)> languages;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (open)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < languages.length; i++)
                  TextButton(
                    onPressed: () => onSelect(i),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      languages[i].$1,
                      style: const TextStyle(color: Color(0xFFCA895B), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        Opacity(
          opacity: open ? 0 : 1,
          child: IgnorePointer(
            ignoring: open,
            child: Material(
              color: HeritageColors.brown.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, size: 16, color: HeritageColors.orange),
                      const SizedBox(width: 8),
                      Text(
                        selectedLabel,
                        style: TextStyle(
                          color: HeritageColors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: HeritageColors.orange),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HeritageColors.brown.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.1)),
          ),
          child: Icon(Icons.info_outline, color: HeritageColors.orange, size: 18),
        ),
      ),
    );
  }
}

/// Styled input matching old React auth screens.
class HeritageAuthField extends StatelessWidget {
  const HeritageAuthField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onToggleObscure,
    this.showObscureToggle = false,
    this.obscureVisible = false,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleObscure;
  final bool showObscureToggle;
  final bool obscureVisible;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: HeritageColors.cream, fontSize: 16),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: HeritageColors.brown.withValues(alpha: 0.5), fontSize: 16),
        prefixIcon: Icon(icon, color: HeritageColors.brown, size: 20),
        suffixIcon: showObscureToggle
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: HeritageColors.brown.withValues(alpha: 0.5),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: HeritageColors.brown.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: HeritageColors.brown.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: HeritageColors.brown.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: HeritageColors.orange.withValues(alpha: 0.5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE76F51)),
        ),
      ),
    );
  }
}

class HeritageAuthPrimaryButton extends StatelessWidget {
  const HeritageAuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: HeritageColors.orange,
          foregroundColor: HeritageColors.background,
          disabledBackgroundColor: HeritageColors.orange.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: HeritageColors.background),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }
}

class HeritageAuthSocialRow extends StatelessWidget {
  const HeritageAuthSocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialChip(label: 'Google', icon: Icons.g_mobiledata)),
        const SizedBox(width: 16),
        Expanded(child: _SocialChip(label: 'Apple', icon: Icons.apple)),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: HeritageColors.brown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HeritageColors.brown.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: HeritageColors.cream, size: 22),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: HeritageColors.cream, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

Widget heritageAuthDivider(String label) {
  return Row(
    children: [
      Expanded(child: Divider(color: HeritageColors.brown.withValues(alpha: 0.2))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          label,
          style: TextStyle(
            color: HeritageColors.brown,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
      Expanded(child: Divider(color: HeritageColors.brown.withValues(alpha: 0.2))),
    ],
  );
}
