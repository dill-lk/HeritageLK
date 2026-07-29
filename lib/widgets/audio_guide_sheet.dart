import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_guide_service.dart';
import '../theme/heritage_colors.dart';

class AudioGuideSheet extends StatefulWidget {
  final String siteId;
  final String siteName;

  const AudioGuideSheet({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<AudioGuideSheet> createState() => _AudioGuideSheetState();
}

class _AudioGuideSheetState extends State<AudioGuideSheet> {
  late List<AudioScript> _scripts;
  late AudioScript _selectedScript;
  bool _isPlaying = false;
  double _progress = 0.0;
  double _playbackSpeed = 1.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scripts = AudioGuideService.getScriptsForSite(widget.siteId);
    _selectedScript = _scripts.first;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      const step = 0.02;
      _timer = Timer.periodic(
        Duration(milliseconds: (1000 ~/ _playbackSpeed)),
        (timer) {
          if (!mounted) return;
          setState(() {
            _progress += step;
            if (_progress >= 1.0) {
              _progress = 0.0;
              _isPlaying = false;
              _timer?.cancel();
            }
          });
        },
      );
    } else {
      _timer?.cancel();
    }
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.25;
      } else if (_playbackSpeed == 1.25) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 0.8;
      } else {
        _playbackSpeed = 1.0;
      }
    });
    if (_isPlaying) {
      _timer?.cancel();
      _togglePlay();
      _togglePlay(); // Restart timer with new speed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: HeritageColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF342116), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HeritageColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.headphones, color: HeritageColors.orange, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.siteName,
                      style: GoogleFonts.plusJakartaSans(
                        color: HeritageColors.cream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Audio Heritage Guide • Text-To-Speech',
                      style: TextStyle(
                        color: HeritageColors.cream.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Language Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _scripts.map((script) {
                final isSelected = script.langCode == _selectedScript.langCode;
                final langName = script.langCode == 'en'
                    ? 'English 🇬🇧'
                    : script.langCode == 'si'
                        ? 'Sinhala 🇱🇰'
                        : 'Tamil 🇱🇰';
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(langName),
                    selected: isSelected,
                    selectedColor: HeritageColors.orange,
                    backgroundColor: const Color(0xFF1E1B15),
                    labelStyle: TextStyle(
                      color: isSelected ? HeritageColors.background : HeritageColors.cream,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedScript = script;
                          _progress = 0.0;
                          if (_isPlaying) _togglePlay();
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Script Content Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF191612),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedScript.title,
                  style: GoogleFonts.playfairDisplay(
                    color: HeritageColors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedScript.bodyText,
                  style: TextStyle(
                    color: HeritageColors.cream.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress Bar
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(HeritageColors.orange),
            borderRadius: BorderRadius.circular(4),
          ),

          const SizedBox(height: 16),

          // Player Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _changeSpeed,
                style: TextButton.styleFrom(
                  foregroundColor: HeritageColors.orange,
                  backgroundColor: const Color(0xFF221E18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('${_playbackSpeed}x Speed'),
              ),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: HeritageColors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: HeritageColors.orange.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: HeritageColors.background,
                    size: 32,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio guide script cached for offline listening! 🎧'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.download_for_offline_outlined, color: HeritageColors.cream),
                tooltip: 'Download Offline',
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
