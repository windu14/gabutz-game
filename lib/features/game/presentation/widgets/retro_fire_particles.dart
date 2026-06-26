import 'dart:math';
import 'package:flutter/material.dart';

class RetroFireParticles extends StatefulWidget {
  final Widget child;
  const RetroFireParticles({super.key, required this.child});

  @override
  State<RetroFireParticles> createState() => _RetroFireParticlesState();
}

class _RetroFireParticlesState extends State<RetroFireParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FireParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _updateParticles();
      });
    _controller.repeat();
  }

  void _updateParticles() {
    // Munculkan partikel secara acak (kotak-kotak api)
    if (_random.nextDouble() < 0.6) {
      _particles.add(FireParticle(
        x: _random.nextDouble(),
        y: 1.0, // Mulai dari bawah
        size: _random.nextDouble() * 6 + 4, // Ukuran kotak 4 s.d 10
        life: 1.0,
        speed: _random.nextDouble() * 0.03 + 0.02,
      ));
    }

    // Update posisi partikel
    for (var i = _particles.length - 1; i >= 0; i--) {
      var p = _particles[i];
      p.y -= p.speed;
      
      // Partikel menyusut saat naik
      p.life -= 0.05; 
      if (p.life <= 0) {
        _particles.removeAt(i);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          top: -30, 
          bottom: 0,
          left: -10,
          right: -10,
          child: CustomPaint(
            painter: FirePainter(_particles),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class FireParticle {
  double x;
  double y;
  double size;
  double life;
  double speed;

  FireParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.life,
    required this.speed,
  });
}

class FirePainter extends CustomPainter {
  final List<FireParticle> particles;

  FirePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.life > 0) {
        final xPos = p.x * size.width;
        final yPos = p.y * size.height;
        final currentSize = p.size * p.life; // Menyusut secara blocky
        
        // Pixelated white fire box
        final paint = Paint()
          ..color = Colors.white.withAlpha((p.life * 255).clamp(0, 255).toInt());
          
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(xPos, yPos), 
            width: currentSize.roundToDouble(), 
            height: currentSize.roundToDouble()
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
