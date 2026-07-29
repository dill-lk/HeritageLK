// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class HeritageGameQuestion {
  final String title;
  final String category;
  final String image;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const HeritageGameQuestion({
    required this.title,
    required this.category,
    required this.image,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class HeritageGameScreen extends StatefulWidget {
  const HeritageGameScreen({super.key});

  @override
  State<HeritageGameScreen> createState() => _HeritageGameScreenState();
}

class _HeritageGameScreenState extends State<HeritageGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _selectedOption = -1;
  bool _answered = false;
  int _timerSeconds = 15;
  Timer? _timer;
  bool _gameOver = false;

  static const List<HeritageGameQuestion> _questions = [
    HeritageGameQuestion(
      title: 'Sigiriya Rock Fortress',
      category: 'ANCIENT ARCHITECTURE',
      image: 'https://images.unsplash.com/photo-1586224372551-7f91854580bf?q=80&w=800&auto=format&fit=crop',
      question: 'Which 5th-century king constructed the royal palace atop Sigiriya Rock?',
      options: ['King Dutugemunu', 'King Kashyapa', 'King Parakramabahu I', 'King Devanampiya Tissa'],
      correctIndex: 1,
      explanation: 'King Kashyapa (477–495 AD) built his capital and citadel on top of the 200m granite rock to defend against potential invasions.',
    ),
    HeritageGameQuestion(
      title: 'Temple of the Tooth',
      category: 'SACRED HERITAGE',
      image: 'https://images.unsplash.com/photo-1625805541012-e8ad54933a2a?q=80&w=800&auto=format&fit=crop',
      question: 'In which kingdom city is the Sri Dalada Maligawa located?',
      options: ['Anuradhapura', 'Polonnaruwa', 'Kandy', 'Yapahuwa'],
      correctIndex: 2,
      explanation: 'The sacred tooth relic of Lord Buddha is housed in Kandy, which was the final royal capital of ancient Sri Lankan kings.',
    ),
    HeritageGameQuestion(
      title: 'Galle Dutch Fort',
      category: 'COLONIAL HISTORY',
      image: 'https://images.unsplash.com/photo-1549473889-14f410d83298?q=80&w=800&auto=format&fit=crop',
      question: 'Which European power originally built the initial fort before the Dutch heavily fortified it in 1663?',
      options: ['The British', 'The Portuguese', 'The French', 'The Spanish'],
      correctIndex: 1,
      explanation: 'The Portuguese first built a basic fortification called Santa Cruz in 1588, which was later captured and extensively rebuilt by the Dutch.',
    ),
    HeritageGameQuestion(
      title: 'Nine Arches Bridge',
      category: 'ENGINEERING MARVELS',
      image: 'https://images.unsplash.com/photo-1586116104802-d1e86c5d9f6e?q=80&w=800&auto=format&fit=crop',
      question: 'What unique structural feature characterizes the construction of Nine Arches Bridge in Ella?',
      options: ['Built entirely without steel bars', 'Constructed with solid marble blocks', 'Suspended with iron cables', 'Carved out of single bedrock'],
      correctIndex: 0,
      explanation: 'Built during WWI, when steel was diverted for war efforts, it was built entirely using bricks, stone blocks, and cement mortar.',
    ),
    HeritageGameQuestion(
      title: 'Dambulla Cave Temple',
      category: 'UNESCO HERITAGE',
      image: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=800&auto=format&fit=crop',
      question: 'How many primary cave sanctuaries compose the Golden Temple complex of Dambulla?',
      options: ['3 Caves', '5 Caves', '8 Caves', '12 Caves'],
      correctIndex: 1,
      explanation: 'The complex features 5 major caves containing over 150 Buddha statues and ancient murals covering 2,100 square meters.',
    ),
    HeritageGameQuestion(
      title: 'Polonnaruwa Vatadage',
      category: 'ANCIENT CAPITALS',
      image: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=800&auto=format&fit=crop',
      question: 'What was the primary purpose of a "Vatadage" in ancient Sri Lankan architecture?',
      options: ['A royal palace guardhouse', 'A circular protection shrine for a stupa', 'An ancient reservoir sluice gate', 'A monks\' dining hall'],
      correctIndex: 1,
      explanation: 'A Vatadage is a circular Buddhist structure built to enclose and protect small stupas housing sacred relics.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 15);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0 && !_answered) {
        setState(() => _timerSeconds--);
      } else if (_timerSeconds == 0 && !_answered) {
        _handleAnswer(-1); // Timeout
      }
    });
  }

  void _handleAnswer(int optionIndex) {
    if (_answered) return;
    _timer?.cancel();

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = optionIndex == currentQuestion.correctIndex;

    setState(() {
      _selectedOption = optionIndex;
      _answered = true;
      if (isCorrect) {
        _streak++;
        _score += 100 + (_streak * 20) + (_timerSeconds * 5);
      } else {
        _streak = 0;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = -1;
        _answered = false;
      });
      _startTimer();
    } else {
      setState(() => _gameOver = true);
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _selectedOption = -1;
      _answered = false;
      _gameOver = false;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            if (_gameOver)
              _buildGameOverView()
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildProgressAndTimer(),
                  const SizedBox(height: 20),
                  _buildQuestionCard(),
                  const SizedBox(height: 24),
                  _buildOptionsList(),
                  if (_answered) ...[
                    const SizedBox(height: 20),
                    _buildExplanationCard(),
                    const SizedBox(height: 20),
                    _buildNextButton(),
                  ],
                ],
              ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: HeritageBottomNav(currentIndex: 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.arrow_back, color: HeritageColors.orange, size: 18),
          ),
        ),
        Column(
          children: [
            Text(
              'HERITAGE QUEST GAME',
              style: TextStyle(
                color: HeritageColors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Lankan Explorer Challenge',
              style: GoogleFonts.playfairDisplay(
                color: HeritageColors.cream,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE9C46A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFFE9C46A), size: 16),
              const SizedBox(width: 4),
              Text(
                '$_score',
                style: const TextStyle(
                  color: Color(0xFFE9C46A),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressAndTimer() {
    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentIndex + 1} of ${_questions.length}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                if (_streak > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: HeritageColors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🔥 $_streak Streak',
                      style: const TextStyle(color: HeritageColors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Icon(
                  Icons.timer,
                  color: _timerSeconds <= 5 ? Colors.redAccent : const Color(0xFF52B788),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_timerSeconds}s',
                  style: TextStyle(
                    color: _timerSeconds <= 5 ? Colors.redAccent : const Color(0xFF52B788),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: HeritageColors.orange,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final q = _questions[_currentIndex];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      overflow: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                q.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: HeritageColors.brown.withValues(alpha: 0.3),
                  child: const Center(child: Icon(Icons.castle, color: HeritageColors.orange, size: 48)),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    q.category,
                    style: const TextStyle(
                      color: HeritageColors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.title,
                  style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    final q = _questions[_currentIndex];

    return Column(
      children: List.generate(q.options.length, (idx) {
        final option = q.options[idx];
        final isSelected = _selectedOption == idx;
        final isCorrect = idx == q.correctIndex;

        Color borderColor = Colors.white.withValues(alpha: 0.08);
        Color bgColor = const Color(0xFF1A1714);
        Color textColor = Colors.white;

        if (_answered) {
          if (isCorrect) {
            borderColor = const Color(0xFF52B788);
            bgColor = const Color(0xFF52B788).withValues(alpha: 0.15);
            textColor = const Color(0xFF52B788);
          } else if (isSelected) {
            borderColor = Colors.redAccent;
            bgColor = Colors.redAccent.withValues(alpha: 0.15);
            textColor = Colors.redAccent;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _handleAnswer(idx),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: _answered && (isCorrect || isSelected) ? 2 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + idx),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_answered && isCorrect)
                    const Icon(Icons.check_circle, color: Color(0xFF52B788), size: 20),
                  if (_answered && isSelected && !isCorrect)
                    const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExplanationCard() {
    final q = _questions[_currentIndex];
    final isCorrect = _selectedOption == q.correctIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? const Color(0xFF52B788) : Colors.redAccent).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ? const Color(0xFF52B788) : Colors.redAccent).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.lightbulb : Icons.info_outline,
                color: isCorrect ? const Color(0xFF52B788) : Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct! Heritage Insight:' : 'Incorrect! Did you know?',
                style: TextStyle(
                  color: isCorrect ? const Color(0xFF52B788) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isLast = _currentIndex == _questions.length - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: HeritageColors.orange,
          foregroundColor: HeritageColors.background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _nextQuestion,
        child: Text(
          isLast ? 'View Challenge Results 🎉' : 'Next Question ➔',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildGameOverView() {
    final maxPossible = _questions.length * 200;
    final percentage = ((_score / maxPossible) * 100).clamp(0, 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1714),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: HeritageColors.orange.withValues(alpha: 0.1),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  'Challenge Completed!',
                  style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.cream,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You scored $_score XP ($percentage% Accuracy)',
                  style: const TextStyle(
                    color: HeritageColors.orange,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _resultStat('Questions', '${_questions.length}'),
                      _resultStat('Final Score', '$_score XP'),
                      _resultStat('Badge Earned', '🥇 Master'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HeritageColors.orange,
                      foregroundColor: HeritageColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _restartGame,
                    child: const Text('Play Again 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                    child: const Text('Back to Home', style: TextStyle(color: Colors.white60)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: HeritageColors.cream, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
      ],
    );
  }
}
