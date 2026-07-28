// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../services/shingo_ai_service.dart';
import '../theme/heritage_colors.dart';

class ShingoScreen extends StatefulWidget {
  const ShingoScreen({super.key});

  @override
  State<ShingoScreen> createState() => _ShingoScreenState();
}

class _ShingoScreenState extends State<ShingoScreen> {
  final _input = TextEditingController();
  final _scrollController = ScrollController();
  late ShingoAiService _shingoAi;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Ayubowan! 🙏 I am Shingo AI, your personal Sri Lankan heritage and travel assistant.\n\nAsk me anything about historical sites, ticket fees, weather, travel routes, or app features!',
      isUser: false,
    ),
  ];

  bool _loading = false;

  final List<String> _suggestions = const [
    '🎟️ Sigiriya Entry Fee?',
    '🏰 Galle Fort Sunset Spot',
    '🛕 Kandy Tooth Temple Rules',
    '🐆 Best Time for Yala Safari',
    '🛡️ How to Report Damage',
    '⚡ Setup Gemini API Key',
  ];

  @override
  void initState() {
    super.initState();
    _shingoAi = ShingoAiService();
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? customText]) async {
    final text = (customText ?? _input.text).trim();
    if (text.isEmpty || _loading) return;

    if (customText == null) _input.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => !m.isStreaming)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final reply = await _shingoAi.chat(history, text);

      if (!mounted) return;
      await _streamReply(reply);
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(const _ChatMessage(
            text: "I'm having trouble connecting right now. Try again in a moment.",
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _streamReply(String fullText) async {
    final index = _messages.length;
    setState(() {
      _messages.add(const _ChatMessage(text: '', isUser: false, isStreaming: true));
    });
    _scrollToBottom();

    const chunkSize = 4;
    final chars = fullText.split('');
    var current = '';

    for (var i = 0; i < chars.length; i += chunkSize) {
      await Future.delayed(const Duration(milliseconds: 14));
      current += chars.sublist(i, min(i + chunkSize, chars.length)).join();
      if (mounted) {
        setState(() {
          _messages[index] = _ChatMessage(text: current, isUser: false, isStreaming: true);
        });
        _scrollToBottom();
      }
    }

    if (mounted) {
      setState(() {
        _messages[index] = _ChatMessage(text: fullText, isUser: false, isStreaming: false);
      });
      _scrollToBottom();
    }
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController(text: AppConfig.userGeminiApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.key, color: Color(0xFFE9C46A)),
            const SizedBox(width: 10),
            Text('Gemini API Key', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API key to enable live AI generative responses directly in Shingo AI.',
              style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: const TextStyle(color: Color(0x4DFFFFFF)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x33E9C46A))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x33E9C46A))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE9C46A))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9C46A),
              foregroundColor: HeritageColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              AppConfig.userGeminiApiKey = keyController.text;
              setState(() {
                _shingoAi = ShingoAiService();
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(keyController.text.isNotEmpty ? 'Gemini API Key saved successfully! ⚡' : 'API Key cleared. Using Heritage LK Knowledge Engine.'),
                  backgroundColor: const Color(0xFF2A2421),
                ),
              );
            },
            child: const Text('Save Key', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = _shingoAi.hasApiKey;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  _round(Icons.arrow_back, () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  }),
                  const SizedBox(width: 12),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0x33E9C46A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Shingo AI',
                              style: GoogleFonts.playfairDisplay(
                                color: HeritageColors.cream,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: hasKey ? const Color(0x3352B788) : const Color(0x33E9C46A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: hasKey ? const Color(0xFF52B788) : const Color(0xFFE9C46A)),
                              ),
                              child: Text(
                                hasKey ? 'GEMINI LIVE' : 'HERITAGE AI',
                                style: TextStyle(
                                  color: hasKey ? const Color(0xFF52B788) : const Color(0xFFE9C46A),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Sri Lanka Cultural & Exploration Guide',
                          style: TextStyle(color: Color(0x80FFFFFF), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _round(Icons.vpn_key_outlined, _showApiKeyDialog),
                  const SizedBox(width: 8),
                  _round(Icons.delete_outline, () {
                    setState(() {
                      _messages.clear();
                      _messages.add(const _ChatMessage(
                        text: 'Chat cleared! What else would you like to explore about Sri Lanka?',
                        isUser: false,
                      ));
                    });
                  }),
                ],
              ),
            ),

            const Divider(color: Color(0x1AFFFFFF), height: 1),

            // API key prompt banner if no key
            if (!hasKey)
              GestureDetector(
                onTap: _showApiKeyDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0x26E9C46A),
                  child: Row(
                    children: const [
                      Icon(Icons.key, color: Color(0xFFE9C46A), size: 16),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap to connect Gemini API key for live AI answers',
                          style: TextStyle(color: Color(0xFFE9C46A), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Color(0xFFE9C46A), size: 18),
                    ],
                  ),
                ),
              ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 4),
                        child: _ShingoLoadingIndicator(),
                      ),
                    );
                  }
                  final message = _messages[i];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 340),
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: message.isUser ? HeritageColors.orange : const Color(0xFF1E1B18),
                        border: message.isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(message.isUser ? 20 : 4),
                          topRight: Radius.circular(message.isUser ? 4 : 20),
                          bottomLeft: const Radius.circular(20),
                          bottomRight: const Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text.isEmpty ? '...' : message.text,
                        style: TextStyle(
                          color: message.isUser ? HeritageColors.background : const Color(0xEEFFFFFF),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Suggestion Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final s = _suggestions[idx];
                  return ActionChip(
                    backgroundColor: const Color(0xFF1C1917),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    label: Text(s, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12, fontWeight: FontWeight.w500)),
                    onPressed: () {
                      if (s.contains('Gemini API')) {
                        _showApiKeyDialog();
                      } else {
                        _send(s.replaceFirst(RegExp(r'^[^\w\s]+\s*'), ''));
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Input Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask Shingo about Sri Lanka heritage...',
                        hintStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE9C46A))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _send(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9C46A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: HeritageColors.background, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFE9C46A), size: 18),
        ),
      );
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;

  const _ChatMessage({required this.text, required this.isUser, this.isStreaming = false});
}

class _ShingoLoadingIndicator extends StatefulWidget {
  const _ShingoLoadingIndicator();

  @override
  State<_ShingoLoadingIndicator> createState() => _ShingoLoadingIndicatorState();
}

class _ShingoLoadingIndicatorState extends State<_ShingoLoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)..repeat();
  late final List<CurvedAnimation> _animations = List.generate(
      3, (i) => CurvedAnimation(parent: _controller, curve: Interval(i * 0.2, i * 0.2 + 0.6, curve: Curves.easeInOut)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          FadeTransition(
            opacity: _animations[i],
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(color: Color(0x80FFFFFF), shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
