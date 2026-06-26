import 'dart:math';
import 'package:flutter/material.dart';

class GlitchBackground extends StatefulWidget {
  const GlitchBackground({super.key});

  @override
  State<GlitchBackground> createState() => _GlitchBackgroundState();
}

class _GlitchBackgroundState extends State<GlitchBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  
  final List<_GlitchBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Slightly slower for block glitches
    )..addListener(() {
        if (_random.nextDouble() > 0.5) {
          _generateBlocks();
        } else {
          // Occasionally clear to create flashing effect
          if (_random.nextDouble() > 0.5) {
             _blocks.clear();
          }
        }
        setState(() {});
      })..repeat();
  }

  void _generateBlocks() {
    _blocks.clear();
    int count = _random.nextInt(20) + 10; // 10 to 30 blocks
    for (int i = 0; i < count; i++) {
      // Create chunky retro HD blocks
      double sizeBase = _random.nextDouble() * 0.1 + 0.02; // 2% to 12% size
      
      _blocks.add(
        _GlitchBlock(
          top: _random.nextDouble(),
          left: _random.nextDouble(),
          width: sizeBase * (_random.nextBool() ? 2.0 : 1.0), // Sometimes wider
          height: sizeBase * (_random.nextBool() ? 2.0 : 1.0), // Sometimes taller
          opacity: _random.nextDouble() * 0.15 + 0.02, // 2% to 17% opacity
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _blocks.map((block) {
            return Positioned(
              top: block.top * constraints.maxHeight,
              left: block.left * constraints.maxWidth,
              width: block.width * constraints.maxWidth,
              height: block.height * constraints.maxHeight,
              child: Container(
                color: Colors.white.withValues(alpha: block.opacity),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _GlitchBlock {
  final double top;
  final double left;
  final double width;
  final double height;
  final double opacity;

  _GlitchBlock({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
    required this.opacity,
  });
}
