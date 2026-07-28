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
  final _shingoAi = ShingoAiService(apiKey: AppConfig.geminiApiKey);

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hello! I am Shingo AI. Ask me anything about Sri Lankan heritages, entry fees, weather, historical contexts, or directions to specific sites.',
      isUser: false,
    ),
  ];

  bool _loading = false;

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _input.clear();
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
          _messages.add(_ChatMessage(
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
      _messages.add(_ChatMessage(text: '', isUser: false, isStreaming: true));
    });
    _scrollToBottom();

    const chunkSize = 4;
    final chars = fullText.split('');
    var current = '';

    for (var i = 0; i < chars.length; i += chunkSize) {
      await Future.delayed(const Duration(milliseconds: 18));
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
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/archive')),
              Row(children: [
                Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0x33E9C46A), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 16)),
                const SizedBox(width: 8),
                Text('Shingo AI', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 14),
              ]),
              const SizedBox(width: 40),
            ]),
          ),
          const Divider(color: Color(0x0DFFFFFF), height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) {
                  return const Align(alignment: Alignment.centerLeft, child: Padding(
                    padding: EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
                    child: _ShingoLoadingIndicator(),
                  ));
                }
                final message = _messages[i];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 340),
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: message.isUser ? HeritageColors.orange : Colors.white.withValues(alpha: 0.10),
                      border: message.isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(message.isUser ? 24 : 4),
                        topRight: Radius.circular(message.isUser ? 4 : 24),
                        bottomLeft: const Radius.circular(24),
                        bottomRight: const Radius.circular(24),
                      ),
                    ),
                    child: Text(message.text.isEmpty ? '...' : message.text, style: TextStyle(color: message.isUser ? HeritageColors.background : const Color(0xE6FFFFFF), fontSize: 14, height: 1.6)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x0DFFFFFF)))),
            child: Row(children: [
              Expanded(child: TextField(
                controller: _input,
                onSubmitted: (_) => _send(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask Shingo...',
                  hintStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Color(0xFFE9C46A))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              )),
              const SizedBox(width: 12),
              GestureDetector(onTap: _send, child: Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFFE9C46A), shape: BoxShape.circle), child: const Icon(Icons.send, color: HeritageColors.background, size: 20))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white.withValues(alpha: 0.10)), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFE9C46A), size: 20)));
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
  late final List<CurvedAnimation> _animations = List.generate(3, (i) => CurvedAnimation(parent: _controller, curve: Interval(i * 0.2, i * 0.2 + 0.6, curve: Curves.easeInOut)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < 3; i++)
        FadeTransition(opacity: _animations[i], child: Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: const BoxDecoration(color: Color(0x80FFFFFF), shape: BoxShape.circle))),
    ]);
  }
}
