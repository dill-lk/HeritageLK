import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../services/heritage_api.dart';
import '../theme/heritage_colors.dart';

class ShingoScreen extends StatefulWidget {
  const ShingoScreen({super.key});

  @override
  State<ShingoScreen> createState() => _ShingoScreenState();
}

class _ShingoScreenState extends State<ShingoScreen> {
  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final _api = HeritageApi();
  final _messages = <({bool user, String text})>[
    (user: false, text: 'Hello! I am Shingo AI. Ask me anything about Sri Lankan heritages, entry fees, weather, historical contexts, or directions to specific sites.'),
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
      _messages.add((user: true, text: text));
      _input.clear();
      _loading = true;
    });
    _scrollToBottom();

    try {
      String reply;
      if (!AppConfig.hasSupabase || AppConfig.apiBaseUrl.contains('localhost')) {
        reply = _demoReply(text);
      } else {
        try {
          reply = await _api.shingoChat(
            _messages.map((message) => {'role': message.user ? 'user' : 'assistant', 'content': message.text}).toList(),
          );
        } catch (_) {
          reply = _demoReply(text);
        }
      }
      if (mounted) {
        setState(() => _messages.add((user: false, text: reply.isEmpty ? 'I could not find an answer right now.' : reply)));
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _messages.add((user: false, text: "Sorry, I'm having trouble connecting right now. Please make sure you're connected to the internet and try again later.")));
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _demoReply(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('galle fort')) return 'Galle Fort is a UNESCO World Heritage Site built by the Portuguese and later fortified by the Dutch. Entry is free and it offers amazing views, museums, and cobblestone streets. Best visited in the morning or late afternoon.';
    if (lower.contains('sigiriya')) return 'Sigiriya, also known as Lion Rock, is an ancient fortress built by King Kashyapa. Ticket prices are approximately \$30 for foreigners. Climb early in the morning to avoid the midday heat and crowds.';
    if (lower.contains('temple') || lower.contains('tooth')) return 'The Temple of the Sacred Tooth Relic in Kandy houses the relic of the Buddha\'s tooth. Dress modestly (covered shoulders and knees). Entry is free, but there may be a small fee for the museum.';
    if (lower.contains('weather') || lower.contains('temperature')) return 'Sri Lanka is tropical and generally hot and humid. Coastal areas like Galle average 28-32°C. The hill country is cooler at 18-24°C. Check the local forecast before heading out.';
    if (lower.contains('directions') || lower.contains('how to get')) return 'From Colombo to Galle, you can take the coastal train (about 2.5 hours) which is scenic, or drive via the Southern Expressway (about 1.5 hours).';
    return 'That\'s a great question about Sri Lankan heritage! Based on historical records, our island nation has over 2,500 years of documented history. Could you ask about a specific site, entry fee, or travel tip?';
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
                  return Align(alignment: Alignment.centerLeft, child: Container(
                    constraints: const BoxConstraints(maxWidth: 340),
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.10), border: Border.all(color: Colors.white.withValues(alpha:0.05)), borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(24), bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _bouncingDot(0),
                      const SizedBox(width: 4),
                      _bouncingDot(1),
                      const SizedBox(width: 4),
                      _bouncingDot(2),
                    ]),
                  ));
                }
                final message = _messages[i];
                return Align(
                  alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 340),
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: message.user ? HeritageColors.orange : Colors.white.withValues(alpha:0.10),
                      border: message.user ? null : Border.all(color: Colors.white.withValues(alpha:0.05)),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(message.user ? 24 : 4),
                        topRight: Radius.circular(message.user ? 4 : 24),
                        bottomLeft: const Radius.circular(24),
                        bottomRight: const Radius.circular(24),
                      ),
                    ),
                    child: Text(message.text, style: TextStyle(color: message.user ? HeritageColors.background : const Color(0xE6FFFFFF), fontSize: 14, height: 1.6)),
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
                  fillColor: Colors.white.withValues(alpha:0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha:0.10))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withValues(alpha:0.10))),
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

  Widget _bouncingDot(int index) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 600),
    builder: (_, __, ___) => AnimatedContainer(
      duration: Duration(milliseconds: 400 + index * 200),
      width: 8, height: 8,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.40), shape: BoxShape.circle),
    ),
  );

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.05), border: Border.all(color: Colors.white.withValues(alpha:0.10)), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFE9C46A), size: 20)));
}

