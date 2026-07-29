import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/shingo_ai_service.dart';
import '../theme/heritage_colors.dart';
import '../widgets/heritage_icons.dart';

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
    const _ChatMessage(
      text: 'Ayubowan! 🙏 I\'m **Shingo** — your local guide to Sri Lanka\'s incredible heritage.\n\nWhether you want to climb **Sigiriya**, spot leopards in **Yala**, or find the best sunset in **Galle Fort** — I\'ve got you. What do you want to explore?',
      isUser: false,
    ),
  ];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _shingoAi = ShingoAiService();
    _loadChatHistory();
  }

  // ─── Persistence ─────────────────────────────────────────────────────────────
  static const _prefsKey = 'shingo_chat_history_v1';

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded.map((e) {
        final map = e as Map<String, dynamic>;
        return _ChatMessage(
          text: map['text'] as String? ?? '',
          isUser: map['isUser'] as bool? ?? false,
        );
      }).toList();
      if (loaded.isNotEmpty && mounted) {
        setState(() {
          _messages
            ..clear()
            ..addAll(loaded);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only save completed messages (not streaming ones), max 60 messages
      final toSave = _messages
          .where((m) => !m.isStreaming)
          .toList()
          .reversed
          .take(60)
          .toList()
          .reversed
          .toList();
      final encoded = jsonEncode(
        toSave.map((m) => {'text': m.text, 'isUser': m.isUser}).toList(),
      );
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {}
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
          duration: const Duration(milliseconds: 250),
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
          .where((m) => !m.isStreaming && m.text.isNotEmpty)
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'content': m.text})
          .toList();

      final reply = await _shingoAi.chat(history, text);

      if (!mounted) return;
      await _streamReply(reply);
      // Save after AI responds successfully
      await _saveChatHistory();
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(const _ChatMessage(
            text: 'Connection hiccup — tap the **retry arrow** or try again in a moment.',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assistantBaseStyle = theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xF5FFFFFF),
          fontSize: 14.5,
          height: 1.55,
        ) ??
        const TextStyle(color: Color(0xF5FFFFFF), fontSize: 14.5, height: 1.55);

    final assistantMarkdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: assistantBaseStyle,
      pPadding: const EdgeInsets.only(bottom: 8),
      listBullet: assistantBaseStyle.copyWith(color: const Color(0xFFE9C46A), fontWeight: FontWeight.bold),
      listBulletPadding: const EdgeInsets.only(right: 6),
      h1: assistantBaseStyle.copyWith(fontSize: 19, fontWeight: FontWeight.bold, color: HeritageColors.cream, height: 1.35),
      h2: assistantBaseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.bold, color: HeritageColors.cream, height: 1.35),
      h3: assistantBaseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.bold, color: HeritageColors.cream, height: 1.35),
      strong: assistantBaseStyle.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFE9C46A)),
      em: assistantBaseStyle.copyWith(fontStyle: FontStyle.italic, color: const Color(0xE6FFFFFF)),
      code: assistantBaseStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE9C46A),
        backgroundColor: const Color(0x1AE9C46A),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      blockquote: assistantBaseStyle.copyWith(
        color: const Color(0xE6FFFFFF),
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0x14FEFAE0),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Color(0xFFE9C46A), width: 3.5)),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF100E0A),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: const BoxDecoration(
              color: Color(0xFF100E0A),
              boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 40)],
            ),
            child: Column(
              children: [
                _buildCustomHeader(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _ShingoLoadingBubble(),
                          ),
                        );
                      }

                      final message = _messages[i];
                      final isUser = message.isUser;
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 340),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFF4A261) : const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(24),
                              topRight: const Radius.circular(24),
                              bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(4),
                              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
                            ),
                            border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0x33E9C46A),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: HeritageIcons.shingo(color: const Color(0xFFE9C46A), size: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Shingo AI',
                                      style: TextStyle(
                                        color: Color(0xFFE9C46A),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                              isUser
                                  ? Text(
                                      message.text,
                                      style: const TextStyle(
                                        color: Color(0xFF100E0A),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    )
                                  : MarkdownBody(
                                      data: message.text.isEmpty ? '...' : message.text,
                                      selectable: false,
                                      styleSheet: assistantMarkdownStyle,
                                      onTapLink: (_, __, ___) {},
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF100E0A),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xFFE9C46A)),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0x33E9C46A),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4DE9C46A),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: HeritageIcons.shingo(color: const Color(0xFFE9C46A), size: 16),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Shingo AI',
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFFFEFBE0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF100E0A),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              onSubmitted: (_) => _send(),
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              decoration: InputDecoration(
                hintText: 'Ask Shingo about Sri Lanka heritage...',
                hintStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 13.5),
                filled: true,
                fillColor: const Color(0x0DFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: Color(0xFFE9C46A), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE9C46A), Color(0xFFF4A261)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE9C46A).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.send_rounded, color: Color(0xFF100E0A), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;

  const _ChatMessage({required this.text, required this.isUser, this.isStreaming = false});
}

class _ShingoLoadingBubble extends StatefulWidget {
  const _ShingoLoadingBubble();

  @override
  State<_ShingoLoadingBubble> createState() => _ShingoLoadingBubbleState();
}

class _ShingoLoadingBubbleState extends State<_ShingoLoadingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  )..repeat();
  late final List<CurvedAnimation> _animations = List.generate(
    3,
    (i) => CurvedAnimation(
      parent: _controller,
      curve: Interval(i * 0.2, i * 0.2 + 0.6, curve: Curves.easeInOut),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1714),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x26E9C46A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 14),
          const SizedBox(width: 10),
          for (var i = 0; i < 3; i++)
            ScaleTransition(
              scale: _animations[i],
              child: Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9C46A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
