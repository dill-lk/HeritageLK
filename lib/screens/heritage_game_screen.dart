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

class _HeritageGameScreenState extends State<HeritageGameScreen>
    with SingleTickerProviderStateMixin {
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
  // Y position goes from 0.0 (far away horizon) to 1.0 (player location at bottom)
  final List<_GameObject> _gameObjects = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
  }

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
      _gameSpeed += 0.0005; // Gradually speed up

      // Spawn new obstacles or relics randomly
      if (_random.nextDouble() < 0.06) {
        final lane = _random.nextInt(3);
        final isRelic = _random.nextDouble() > 0.4;
        final type = isRelic
            ? _GameObjectType.relic
            : (_random.nextBool()
                ? _GameObjectType.boulder
                : _GameObjectType.ancientGate);

        // Don't spawn if something is already at top of this lane
        final hasOverlap = _gameObjects.any(
            (obj) => obj.lane == lane && obj.yPosition < 0.2);
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
        obj.yPosition += 0.02 * _gameSpeed;

        // Collision Check (when object reaches player at yPosition >= 0.85)
        if (obj.yPosition >= 0.82 && obj.yPosition <= 0.95 && obj.lane == _playerLane) {
          if (obj.type == _GameObjectType.relic) {
            _relicsCollected++;
            _score += 250;
            _gameObjects.removeAt(i);
            HapticFeedback.lightImpact();
            continue;
          } else {
            // Obstacle hit
            if (obj.type == _GameObjectType.ancientGate && _isJumping) {
              // Jumped over low gate successfully!
            } else {
              // Game Over Hit!
              _triggerGameOver();
              return;
            }
          }
        }

        // Remove off-screen objects
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
      backgroundColor: HeritageColors.background,
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
                      // Tap left side to move left, right side to move right, center to jump
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
                        _build3DRunnerTrack(),
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
              Text(
                'HERITAGE RUNNER',
                style: TextStyle(
                  color: HeritageColors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Escape from Sigiriya',
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
                  color: const Color(0xFFE9C46A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9C46A).withValues(alpha: 0.3)),
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
                  color: const Color(0xFF52B788).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF52B788).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$_score',
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

  Widget _build3DRunnerTrack() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C1E14), // Horizon sky/jungle
            Color(0xFF16110D), // Track floor
          ],
        ),
      ),
      child: CustomPaint(
        painter: _TrackPainter(),
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
            // Perspective calculations
            final y = obj.yPosition;
            final scale = 0.2 + (y * 0.8); // Smaller near horizon, bigger near bottom
            final posX = (width / 2) + ((obj.lane - 1) * (width * 0.32) * y);
            final posY = height * (0.2 + (y * 0.75));

            return Positioned(
              left: posX - (24 * scale),
              top: posY - (24 * scale),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE9C46A).withValues(alpha: 0.3),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE9C46A).withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(obj.relicIcon, style: const TextStyle(fontSize: 32)),
      );
    } else if (obj.type == _GameObjectType.boulder) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF7A5C45),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: const Center(
          child: Text('🪨', style: TextStyle(fontSize: 30)),
        ),
      );
    } else {
      // Ancient Gate
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE76F51),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HeritageColors.cream, width: 2),
        ),
        child: const Text('🚪 JUMP!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      );
    }
  }

  Widget _buildPlayerCharacter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final lanePositions = [width * 0.18, width * 0.5 - 28, width * 0.82 - 56];
        final currentX = lanePositions[_playerLane];
        final currentY = height * 0.78 - (_isJumping ? 70 : 0);

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          left: currentX,
          top: currentY,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.rotationZ(_isJumping ? -0.1 : 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HeritageColors.orange.withValues(alpha: 0.2),
                  border: Border.all(color: HeritageColors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: HeritageColors.orange.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text('🏃', style: TextStyle(fontSize: 38)),
              ),
              const SizedBox(height: 4),
              // Shadow under player
              Container(
                width: 36,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: _isJumping ? 0.15 : 0.5),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          ElevatedButton(
            onPressed: _jump,
            style: ElevatedButton.styleFrom(
              backgroundColor: HeritageColors.orange,
              foregroundColor: HeritageColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_upward, size: 20),
                SizedBox(width: 6),
                Text('JUMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _moveRight,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A221C),
              foregroundColor: HeritageColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Icon(Icons.arrow_forward_ios, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStartOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1714),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: HeritageColors.orange.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗿', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'Sigiriya Ancient Run',
                style: GoogleFonts.playfairDisplay(
                  color: HeritageColors.cream,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Run through ancient Lankan ruins! Swipe or tap sides to switch lanes, tap center or swipe up to JUMP over gates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeritageColors.orange,
                    foregroundColor: HeritageColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _startGame,
                  child: const Text('START RUNNING 🏃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1714),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💥', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'Run Ended!',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $_score XP  |  Relics: 💎 $_relicsCollected',
                style: const TextStyle(color: HeritageColors.orange, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'High Score: $_highScore XP',
                style: const TextStyle(color: Color(0xFF52B788), fontSize: 12, fontWeight: FontWeight.w600),
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
                  onPressed: _startGame,
                  child: const Text('PLAY AGAIN 🔄', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
  int lane; // 0, 1, 2
  double yPosition; // 0.0 to 1.0
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

class _TrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    final horizonY = height * 0.2;

    // Center vanishing point
    final vanishingX = width / 2;

    // Draw 3 lanes dividing lines
    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(0, height),
      paint,
    );

    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(width * 0.33, height),
      paint,
    );

    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(width * 0.67, height),
      paint,
    );

    canvas.drawLine(
      Offset(vanishingX, horizonY),
      Offset(width, height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
