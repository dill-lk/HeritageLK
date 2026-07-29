// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/heritage_colors.dart';
import '../widgets/bottom_nav.dart';

class HeritageGameScreen extends StatefulWidget {
  const HeritageGameScreen({super.key});

  @override
  State<HeritageGameScreen> createState() => _HeritageGameScreenState();
}

class _HeritageGameScreenState extends State<HeritageGameScreen> {
  // Game States
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _highScore = 0;
  int _relicsCollected = 0;

  // Runner Position (0: Left lane, 1: Center lane, 2: Right lane)
  int _playerLane = 1;
  bool _isJumping = false;

  // Game Loop
  Timer? _gameTimer;
  double _gameSpeed = 1.0;

  // Obstacles and Relics
  final List<_GameObject> _gameObjects = [];
  final Random _random = Random();

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _relicsCollected = 0;
      _playerLane = 1;
      _isJumping = false;
      _gameSpeed = 1.0;
      _gameObjects.clear();
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!_isPlaying || _isGameOver) return;

    setState(() {
      _score += (_gameSpeed * 2).toInt();
      _gameSpeed += 0.0006;

      // Spawn items
      if (_random.nextDouble() < 0.07) {
        final lane = _random.nextInt(3);
        final isRelic = _random.nextDouble() > 0.45;
        final type = isRelic
            ? _GameObjectType.relic
            : (_random.nextBool()
                ? _GameObjectType.boulder
                : _GameObjectType.ancientGate);

        final hasOverlap = _gameObjects.any(
            (obj) => obj.lane == lane && obj.yPosition < 0.25);
        if (!hasOverlap) {
          _gameObjects.add(_GameObject(
            lane: lane,
            yPosition: 0.0,
            type: type,
            relicIcon: isRelic ? _getRandomRelicEmoji() : '',
          ));
        }
      }

      // Move objects forward
      for (var i = _gameObjects.length - 1; i >= 0; i--) {
        final obj = _gameObjects[i];
        obj.yPosition += 0.022 * _gameSpeed;

        // Collision Check
        if (obj.yPosition >= 0.78 && obj.yPosition <= 0.94 && obj.lane == _playerLane) {
          if (obj.type == _GameObjectType.relic) {
            _relicsCollected++;
            _score += 300;
            _gameObjects.removeAt(i);
            HapticFeedback.lightImpact();
            continue;
          } else {
            if (obj.type == _GameObjectType.ancientGate && _isJumping) {
              // Jumped over gate successfully
            } else {
              _triggerGameOver();
              return;
            }
          }
        }

        if (obj.yPosition > 1.1) {
          _gameObjects.removeAt(i);
        }
      }
    });
  }

  String _getRandomRelicEmoji() {
    final relics = ['👑', '🛕', '💎', '🏺', '📜', '🪷'];
    return relics[_random.nextInt(relics.length)];
  }

  void _triggerGameOver() {
    _gameTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      if (_score > _highScore) {
        _highScore = _score;
      }
    });
  }

  void _moveLeft() {
    if (!_isPlaying) return;
    if (_playerLane > 0) {
      setState(() => _playerLane--);
      HapticFeedback.selectionClick();
    }
  }

  void _moveRight() {
    if (!_isPlaying) return;
    if (_playerLane < 2) {
      setState(() => _playerLane++);
      HapticFeedback.selectionClick();
    }
  }

  void _jump() {
    if (!_isPlaying || _isJumping) return;
    setState(() => _isJumping = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) setState(() => _isJumping = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C0A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < 0) {
                          _moveLeft();
                        } else if (details.primaryVelocity! > 0) {
                          _moveRight();
                        }
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! < 0) {
                        _jump();
                      }
                    },
                    onTapUp: (details) {
                      final width = MediaQuery.of(context).size.width;
                      final tapX = details.localPosition.dx;
                      if (tapX < width * 0.35) {
                        _moveLeft();
                      } else if (tapX > width * 0.65) {
                        _moveRight();
                      } else {
                        _jump();
                      }
                    },
                    child: Stack(
                      children: [
                        _buildRichTrackBackground(),
                        _buildGameObjectsLayer(),
                        _buildPlayerCharacter(),
                        if (!_isPlaying && !_isGameOver) _buildStartOverlay(),
                        if (_isGameOver) _buildGameOverOverlay(),
                      ],
                    ),
                  ),
                ),
                _buildControlsBar(),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161210),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
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
              const Text(
                'HERITAGE RUNNER',
                style: TextStyle(
                  color: HeritageColors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Sigiriya Ancient Run',
                style: GoogleFonts.playfairDisplay(
                  color: HeritageColors.cream,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9C46A).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '💎 $_relicsCollected',
                  style: const TextStyle(
                    color: Color(0xFFE9C46A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF52B788).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$_score XP',
                  style: const TextStyle(
                    color: Color(0xFF52B788),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRichTrackBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E140C), // Ancient jungle horizon
            Color(0xFF2E2218), // Fortress stone track
            Color(0xFF18120D),
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _VibrantTrackPainter(),
      ),
    );
  }

  Widget _buildGameObjectsLayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: _gameObjects.map((obj) {
            final y = obj.yPosition;
            final scale = (0.2 + (y * 0.95)).clamp(0.2, 1.3);
            final laneOffset = (obj.lane - 1);
            final posX = (width / 2) + (laneOffset * (width * 0.32) * (0.3 + y * 0.7));
            final posY = height * (0.22 + (y * 0.72));

            return Positioned(
              left: posX - (28 * scale),
              top: posY - (28 * scale),
              child: Transform.scale(
                scale: scale,
                child: _buildObjectWidget(obj),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildObjectWidget(_GameObject obj) {
    if (obj.type == _GameObjectType.relic) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE9C46A).withValues(alpha: 0.25),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE9C46A), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE9C46A).withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(obj.relicIcon, style: const TextStyle(fontSize: 30)),
        ),
      );
    } else if (obj.type == _GameObjectType.boulder) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF8D6E63),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF5D4037), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text('🪨', style: TextStyle(fontSize: 32)),
        ),
      );
    } else {
      // Ancient Gate
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          '🚪 JUMP!',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      );
    }
  }

  Widget _buildPlayerCharacter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final lanePositions = [width * 0.16, width * 0.5 - 30, width * 0.84 - 60];
        final currentX = lanePositions[_playerLane];
        final currentY = height * 0.76 - (_isJumping ? 80 : 0);

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          left: currentX,
          top: currentY,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                transform: Matrix4.rotationZ(_isJumping ? -0.15 : 0),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF4A261), Color(0xFFE76F51)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: HeritageColors.cream, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: HeritageColors.orange.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏃', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 6),
              // Dynamic Shadow
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: _isJumping ? 24 : 44,
                height: _isJumping ? 4 : 8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: _isJumping ? 0.2 : 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      decoration: BoxDecoration(
        color: const Color(0xFF161210),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _moveLeft,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A221C),
              foregroundColor: HeritageColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              side: BorderSide(color: HeritageColors.orange.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 22),
          ),
          ElevatedButton(
            onPressed: _jump,
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageColors.orange,
              foregroundColor: HeritageColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 6,
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_upward, size: 22),
                SizedBox(width: 8),
                Text('JUMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _moveRight,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A221C),
              foregroundColor: HeritageColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              side: BorderSide(color: HeritageColors.orange.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.arrow_forward_ios, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B18),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: HeritageColors.orange.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HeritageColors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🏃', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 16),
              Text(
                'Sigiriya Ancient Run',
                style: GoogleFonts.playfairDisplay(
                  color: HeritageColors.cream,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Dodge ancient boulders (🪨) and jump over gates (🚪)! Collect royal gems & relics (💎 🏺 👑) to boost your score.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageColors.orange,
                    foregroundColor: HeritageColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _startGame,
                  child: const Text('START RUNNING 🏃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B18),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE76F51), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE76F51).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💥', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 12),
              Text(
                'Run Ended!',
                style: GoogleFonts.playfairDisplay(
                  color: HeritageColors.cream,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$_score', style: const TextStyle(color: HeritageColors.orange, fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text('SCORE XP', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(width: 1, height: 28, color: Colors.white10),
                    Column(
                      children: [
                        Text('💎 $_relicsCollected', style: const TextStyle(color: Color(0xFFE9C46A), fontSize: 22, fontWeight: FontWeight.bold)),
                        const Text('RELICS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'High Score: $_highScore XP',
                style: const TextStyle(color: Color(0xFF52B788), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageColors.orange,
                    foregroundColor: HeritageColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _startGame,
                  child: const Text('PLAY AGAIN 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameObject {
  int lane;
  double yPosition;
  _GameObjectType type;
  String relicIcon;

  _GameObject({
    required this.lane,
    required this.yPosition,
    required this.type,
    this.relicIcon = '',
  });
}

enum _GameObjectType {
  boulder,
  ancientGate,
  relic,
}

class _VibrantTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final horizonY = height * 0.22;
    final vanishingX = width / 2;

    // Track surface fill
    final path = Path()
      ..moveTo(vanishingX - 20, horizonY)
      ..lineTo(vanishingX + 20, horizonY)
      ..lineTo(width + 40, height)
      ..lineTo(-40, height)
      ..close();

    final trackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF2A1C12),
        const Color(0xFF1E150D),
      ],
    );

    final trackPaint = Paint()
      ..shader = trackGradient.createShader(Rect.fromLTWH(0, horizonY, width, height - horizonY));
    canvas.drawPath(path, trackPaint);

    // Glowing lane lines
    final linePaint = Paint()
      ..color = const Color(0xFFF4A261).withValues(alpha: 0.4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFFF4A261).withValues(alpha: 0.15)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    // Left outer border
    canvas.drawLine(Offset(vanishingX - 20, horizonY), Offset(-40, height), linePaint);
    canvas.drawLine(Offset(vanishingX - 20, horizonY), Offset(-40, height), glowPaint);

    // Lane divider 1
    final p1Start = Offset(vanishingX - 7, horizonY);
    final p1End = Offset(width * 0.33, height);
    canvas.drawLine(p1Start, p1End, linePaint);

    // Lane divider 2
    final p2Start = Offset(vanishingX + 7, horizonY);
    final p2End = Offset(width * 0.67, height);
    canvas.drawLine(p2Start, p2End, linePaint);

    // Right outer border
    canvas.drawLine(Offset(vanishingX + 20, horizonY), Offset(width + 40, height), linePaint);
    canvas.drawLine(Offset(vanishingX + 20, horizonY), Offset(width + 40, height), glowPaint);

    // Horizon glowing line
    final horizonPaint = Paint()
      ..color = const Color(0xFFF4A261).withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, horizonY), Offset(width, horizonY), horizonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
