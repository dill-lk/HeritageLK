import 'package:flutter/material.dart';

import '../services/heritage_api.dart';
import '../theme/heritage_colors.dart';

class ShingoScreen extends StatefulWidget {
  const ShingoScreen({super.key});

  @override
  State<ShingoScreen> createState() => _ShingoScreenState();
}

class _ShingoScreenState extends State<ShingoScreen> {
  final _input = TextEditingController();
  final _api = HeritageApi();
  final _messages = <({bool user, String text})>[
    (
      user: false,
      text: 'Hello! I am Shingo AI. Ask me anything about Sri Lankan heritages, entry fees, weather, historical contexts, or directions to specific sites.',
    ),
  ];
  bool _loading = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add((user: true, text: text));
      _input.clear();
      _loading = true;
    });

    try {
      final reply = await _api.shingoChat(
        _messages
            .map((message) => {
                  'role': message.user ? 'user' : 'assistant',
                  'content': message.text,
                })
            .toList(),
      );
      if (mounted) {
        setState(() => _messages.add(
              (user: false, text: reply.isEmpty ? 'I could not find an answer right now.' : reply),
            ));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _messages.add(
              (user: false, text: 'Sorry, I\'m having trouble connecting right now. Please make sure you\'re connected to the internet and try again later.'),
            ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _round(Icons.arrow_back, () => Navigator.of(context).pushReplacementNamed('/archive')),
                  Row(children: [
                    Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0x33E9C46A), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Color(0xFFE9C46A), size: 16)),
                    const SizedBox(width: 8),
                    const Text('Shingo AI ✨', style: TextStyle(color: HeritageColors.cream, fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Divider(color: Color(0x0DFFFFFF), height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ..._messages.map((message) => Align(
                        alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 340),
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: message.user ? HeritageColors.orange : Colors.white.withOpacity(0.10),
                            border: message.user ? null : Border.all(color: Colors.white.withOpacity(0.05)),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(message.user ? 24 : 4),
                              topRight: Radius.circular(message.user ? 4 : 24),
                              bottomLeft: const Radius.circular(24),
                              bottomRight: const Radius.circular(24),
                            ),
                          ),
                          child: Text(message.text, style: TextStyle(color: message.user ? HeritageColors.background : const Color(0xE6FFFFFF), fontSize: 14, height: 1.6)),
                        ),
                      )),
                  if (_loading) const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(bottom: 24), child: Text('Shingo is thinking...', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13))),),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x0DFFFFFF)))),
              child: Row(children: [
                Expanded(child: TextField(controller: _input, onSubmitted: (_) => _send(), decoration: InputDecoration(hintText: 'Ask Shingo...', hintStyle: const TextStyle(color: Color(0x66FFFFFF), fontSize: 14), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)))),
                const SizedBox(width: 12),
                InkWell(onTap: _send, borderRadius: BorderRadius.circular(30), child: Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFFE9C46A), shape: BoxShape.circle), child: const Icon(Icons.send, color: HeritageColors.background, size: 20))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback action) => InkWell(onTap: action, borderRadius: BorderRadius.circular(24), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white.withOpacity(0.10)), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFE9C46A), size: 20)));
}
