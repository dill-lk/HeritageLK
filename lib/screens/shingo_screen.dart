import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/shingo_ai_service.dart';
import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/heritage_icons.dart';

class ShingoScreen extends StatefulWidget {
  const ShingoScreen({super.key});

  @override
  State<ShingoScreen> createState() => _ShingoScreenState();
}

class _ShingoScreenState extends State<ShingoScreen> {
  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  late ShingoAiService _shingoAi;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Ayubowan! 🙏 I\'m **Shingo** — your local guide to Sri Lanka\'s incredible heritage.\n\nWhether you want to climb **Sigiriya**, spot leopards in **Yala**, identify ancient artifacts, or find the best sunset in **Galle Fort** — I\'ve got you!\n\n💡 *Tip: Tap the 📸 camera icon below to upload a photo for visual identification!*',
      isUser: false,
    ),
  ];

  bool _loading = false;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  static const _prefsKey = 'shingo_chat_history_v2';

  // Quick Action Prompts
  static const List<({String label, String icon, String prompt})> _quickChips = [
    (label: 'Identify Photo', icon: '📸', prompt: 'I have attached a photo. Can you tell me what heritage site or cultural artifact this is?'),
    (label: 'Sigiriya Guide', icon: '🏰', prompt: 'Tell me everything about Sigiriya Rock Fortress, ticket prices, and best time to visit!'),
    (label: 'Galle Fort', icon: '🏛️', prompt: 'What are the top things to do in Galle Dutch Fort at sunset?'),
    (label: 'Tooth Relic', icon: '🛕', prompt: 'What happens during the Tooth Temple puja ceremonies in Kandy?'),
    (label: 'Yala Safari', icon: '🐆', prompt: 'How do I plan a leopard safari in Yala National Park?'),
    (label: 'Ella Train', icon: '🚞', prompt: 'How can I get tickets for the famous Kandy to Ella train ride?'),
    (label: 'Earn XP', icon: '🛡️', prompt: 'How do I earn XP and badges by reporting heritage damage in HeritageLK?'),
    (label: 'Local Food', icon: '🍛', prompt: 'What are Sri Lanka\'s must-try traditional heritage foods and dishes?'),
  ];

  @override
  void initState() {
    super.initState();
    _shingoAi = ShingoAiService();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Persistence ─────────────────────────────────────────────────────────────
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded.map((e) {
        final map = e as Map<String, dynamic>;
        final imgPath = map['imagePath'] as String?;
        return _ChatMessage(
          text: map['text'] as String? ?? '',
          isUser: map['isUser'] as bool? ?? false,
          imagePath: imgPath != null && File(imgPath).existsSync() ? imgPath : null,
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
      final toSave = _messages
          .where((m) => !m.isStreaming)
          .toList()
          .reversed
          .take(40)
          .toList()
          .reversed
          .toList();
      final encoded = jsonEncode(
        toSave.map((m) => {
          'text': m.text,
          'isUser': m.isUser,
          'imagePath': m.imagePath,
        }).toList(),
      );
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {}
  }

  Future<void> _clearChatHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1A14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Conversation?', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to clear your chat history with Shingo?', style: TextStyle(color: Color(0xD9FFFFFF))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE76F51)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      if (mounted) {
        setState(() {
          _messages
            ..clear()
            ..add(const _ChatMessage(
              text: 'Chat cleared! Ayubowan 🙏 I\'m Shingo — ready for your next Sri Lankan heritage question!',
              isUser: false,
            ));
        });
      }
    }
  }

  // ─── Image Selection ─────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1714),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attach Heritage Photo', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: HeritageColors.orange.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.photo_camera_rounded, color: HeritageColors.orange),
              ),
              title: const Text('Take a Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: const Text('Capture a site, carving, or artifact right now', style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE9C46A).withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFFE9C46A)),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: const Text('Select a saved monument or travel picture', style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sending Messages ─────────────────────────────────────────────────────────
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
    final imageBytes = _selectedImageBytes;
    final imagePath = _selectedImage?.path;

    if (text.isEmpty && imageBytes == null) return;
    if (_loading) return;

    if (customText == null) _input.clear();

    setState(() {
      _messages.add(_ChatMessage(
        text: text.isEmpty && imageBytes != null ? '📸 Attached Image' : text,
        isUser: true,
        imageBytes: imageBytes,
        imagePath: imagePath,
      ));
      _loading = true;
      _selectedImage = null;
      _selectedImageBytes = null;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => !m.isStreaming && m.text.isNotEmpty)
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'content': m.text})
          .toList();

      final reply = await _shingoAi.chat(
        history,
        text,
        imageBytes: imageBytes,
        imageMimeType: 'image/jpeg',
      );

      if (!mounted) return;
      await _streamReply(reply);
      await _saveChatHistory();
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(const _ChatMessage(
            text: 'Connection hiccup — tap to retry or check your internet connection!',
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

  // ─── Question Suggestions Modal ────────────────────────────────────────────────
  void _showQuestionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1714),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFE9C46A), size: 24),
                const SizedBox(width: 10),
                Text('Ask Shingo Questions', style: GoogleFonts.playfairDisplay(color: HeritageColors.cream, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Tap any preset question to ask Shingo immediately!', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 20),

            _buildQuestionCategory('🏛️ Ancient UNESCO Wonders', [
              'What is the story behind Sigiriya rock fortress?',
              'What are the 5 main cave temples in Dambulla?',
              'How was the Polonnaruwa Vatadage constructed?',
              'Why is the Sri Maha Bodhi tree in Anuradhapura famous?',
            ]),
            _buildQuestionCategory('🌿 Nature & Safaris', [
              'When is the best season to see leopards in Yala?',
              'What is "The Gathering" of elephants in Minneriya?',
              'What rare birds and animals live in Sinharaja Forest?',
            ]),
            _buildQuestionCategory('🚗 Travel & Culture', [
              'How do I book tickets for Kandy to Ella train?',
              'What should I wear when visiting Buddhist temples?',
              'What are the best street foods to try in Colombo and Galle?',
            ]),
            _buildQuestionCategory('🛡️ HeritageLK App Features', [
              'How do I report damage to a heritage site?',
              'How do I earn XP and unlock badges in my Passport?',
              'Where can I find audio guides for ancient sites?',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCategory(String title, List<String> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(title, style: const TextStyle(color: Color(0xFFE9C46A), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        ...questions.map((q) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              _send(q);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(q, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500)),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE9C46A), size: 12),
                ],
              ),
            ),
          ),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Main Build ──────────────────────────────────────────────────────────────
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
      backgroundColor: HeritageColors.background,
      bottomNavigationBar: const HeritageBottomNav(currentIndex: 5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                  return _buildMessageBubble(message, assistantMarkdownStyle);
                },
              ),
            ),
            _buildQuickChipsBar(),
            if (_selectedImageBytes != null) _buildSelectedImagePreview(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ─── Header Widget ───────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15120E),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 4))],
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE9C46A), size: 20),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0x33E9C46A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x66E9C46A), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x4DE9C46A), blurRadius: 12, spreadRadius: 1),
                  ],
                ),
                child: Center(
                  child: HeritageIcons.shingo(color: const Color(0xFFE9C46A), size: 20),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF52B788),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF15120E), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Shingo AI',
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFFEFBE0),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Local Heritage & Culture Guide',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showQuestionsModal,
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFE9C46A), size: 22),
            tooltip: 'Preset Questions',
          ),
          IconButton(
            onPressed: _clearChatHistory,
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54, size: 22),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
    );
  }

  // ─── Message Bubble Widget ──────────────────────────────────────────────────
  Widget _buildMessageBubble(_ChatMessage message, MarkdownStyleSheet markdownStyle) {
    final isUser = message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth > 600 ? 440.0 : screenWidth * 0.82;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFF4A261) : const Color(0xFF1E1A15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: isUser ? const Radius.circular(22) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(22),
          ),
          border: isUser
              ? null
              : Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0x33E9C46A),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HeritageIcons.shingo(color: const Color(0xFFE9C46A), size: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Shingo AI',
                    style: TextStyle(
                      color: Color(0xFFE9C46A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Display Image if attached to message
            if (message.imageBytes != null || (message.imagePath != null && File(message.imagePath!).existsSync())) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: message.imageBytes != null
                      ? Image.memory(message.imageBytes!, fit: BoxFit.cover)
                      : Image.file(File(message.imagePath!), fit: BoxFit.cover),
                ),
              ),
            ],

            isUser
                ? Text(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xFF100E0A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  )
                : MarkdownBody(
                    data: message.text.isEmpty ? '...' : message.text,
                    selectable: false,
                    styleSheet: markdownStyle,
                  ),
          ],
        ),
      ),
    );
  }

  // ─── Quick Prompts Chips Bar ─────────────────────────────────────────────────
  Widget _buildQuickChipsBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickChips.length,
        itemBuilder: (ctx, i) {
          final chip = _quickChips[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                if (chip.label == 'Identify Photo') {
                  _showImageOptions();
                } else {
                  _send(chip.prompt);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x1AE9C46A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4DE9C46A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(chip.icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      chip.label,
                      style: const TextStyle(
                        color: Color(0xFFFEFAE0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Selected Image Preview Pill ─────────────────────────────────────────────
  Widget _buildSelectedImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Photo Attached', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('Ready for Shingo to identify', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _selectedImageBytes = null;
              });
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Input Area Widget ───────────────────────────────────────────────────────
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15120E),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showImageOptions,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0x1AE9C46A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x4DE9C46A)),
              ),
              child: const Center(
                child: Icon(Icons.add_a_photo_rounded, color: Color(0xFFE9C46A), size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _input,
              onSubmitted: (_) => _send(),
              style: const TextStyle(color: Colors.white, fontSize: 14.5),
              decoration: InputDecoration(
                hintText: _selectedImageBytes != null
                    ? 'Ask Shingo about this photo...'
                    : 'Ask Shingo about Sri Lanka heritage...',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(),
            child: Container(
              width: 46,
              height: 46,
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
  final String? imagePath;
  final Uint8List? imageBytes;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
    this.imagePath,
    this.imageBytes,
  });
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
