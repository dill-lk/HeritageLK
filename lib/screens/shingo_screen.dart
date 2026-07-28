import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    const _ChatMessage(
      text: 'Ayubowan. I am Shingo, your Sri Lankan heritage and travel assistant.\n\nAsk me about sites, entry fees, weather, routes, damage reports, or history.',
      isUser: false,
    ),
  ];

  bool _loading = false;

  final List<String> _suggestions = const [
    'Sigiriya entry fee',
    'Galle Fort sunset spots',
    'Kandy Tooth Temple rules',
    'Best time for Yala safari',
    'How to report damage',
    'Colombo to Ella route',
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
            text: 'I could not connect right now. Please try again in a moment.',
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

  void _showAiCustomizationDialog() {
    final keyController = TextEditingController(text: AppConfig.userGeminiApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF171311),
        title: const Text('AI Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add your Gemini API key if you want live AI responses.',
              style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'API key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              AppConfig.userGeminiApiKey = keyController.text;
              setState(() {
                _shingoAi = ShingoAiService();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(const _ChatMessage(
          text: 'Ayubowan. I am Shingo, your Sri Lankan heritage and travel assistant.\n\nAsk me about sites, entry fees, weather, routes, damage reports, or history.',
          isUser: false,
        ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assistantBaseStyle = theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xF2FFFFFF),
          fontSize: 14.5,
          height: 1.55,
        ) ??
        const TextStyle(color: Color(0xF2FFFFFF), fontSize: 14.5, height: 1.55);

    final assistantMarkdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: assistantBaseStyle,
      pPadding: const EdgeInsets.only(bottom: 6),
      listBullet: assistantBaseStyle.copyWith(color: HeritageColors.orange, fontWeight: FontWeight.bold),
      listBulletPadding: const EdgeInsets.only(right: 6),
      h1: assistantBaseStyle.copyWith(fontSize: 19, fontWeight: FontWeight.bold, color: HeritageColors.cream, height: 1.35),
      h2: assistantBaseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.bold, color: HeritageColors.cream, height: 1.35),
      h3: assistantBaseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.bold, color: HeritageColors.cream, height: 1.35),
      strong: assistantBaseStyle.copyWith(fontWeight: FontWeight.bold, color: HeritageColors.cream),
      em: assistantBaseStyle.copyWith(fontStyle: FontStyle.italic, color: const Color(0xE6FFFFFF)),
      // Clean non-developer inline text highlighting
      code: assistantBaseStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: HeritageColors.cream,
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
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0x12FEFAE0),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: HeritageColors.orange, width: 3)),
      ),
    );

    return Scaffold(
      backgroundColor: HeritageColors.background,
      appBar: AppBar(
        backgroundColor: HeritageColors.background,
        elevation: 0,
        title: const Text('Shingo AI'),
        actions: [
          IconButton(
            onPressed: _showAiCustomizationDialog,
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'AI settings',
          ),
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _ShingoLoadingIndicator(),
                      ),
                    );
                  }

                  final message = _messages[i];
                  final isUser = message.isUser;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 360),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser ? HeritageColors.orange : const Color(0xFF1A1714),
                        borderRadius: BorderRadius.circular(16),
                        border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: isUser
                          ? Text(
                              message.text,
                              style: const TextStyle(
                                color: HeritageColors.background,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            )
                          : MarkdownBody(
                              data: message.text.isEmpty ? '...' : message.text,
                              selectable: false,
                              styleSheet: assistantMarkdownStyle,
                              onTapLink: (_, __, ___) {},
                            ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final suggestion = _suggestions[index];
                  return ActionChip(
                    backgroundColor: const Color(0xFF1A1714),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                    label: Text(
                      suggestion,
                      style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 12),
                    ),
                    onPressed: () => _send(suggestion),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                        fillColor: const Color(0xFF171311),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: HeritageColors.orange),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: HeritageColors.orange,
                      foregroundColor: HeritageColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    child: const Icon(Icons.send, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _ShingoLoadingIndicator extends StatefulWidget {
  const _ShingoLoadingIndicator();

  @override
  State<_ShingoLoadingIndicator> createState() => _ShingoLoadingIndicatorState();
}

class _ShingoLoadingIndicatorState extends State<_ShingoLoadingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
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
              decoration: const BoxDecoration(
                color: Color(0x80FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
