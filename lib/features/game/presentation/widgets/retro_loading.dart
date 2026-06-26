import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class RetroLoading extends StatefulWidget {
  const RetroLoading({super.key});

  @override
  State<RetroLoading> createState() => _RetroLoadingState();
}

class _RetroLoadingState extends State<RetroLoading> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  Timer? _particleTimer;
  
  final Random _random = Random();
  final List<double> _particleHeights = List.generate(10, (index) => 0.0);

  @override
  void initState() {
    super.initState();
    
    // Text blinker
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Particle heights updater
    _particleTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < 10; i++) {
            _particleHeights[i] = _random.nextDouble() * 24.h + 4.h;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Particle Equalizer
        SizedBox(
          height: 32.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(10, (index) {
              return Container(
                width: 8.w,
                height: _particleHeights[index],
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.white : Colors.white54,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 16.h),
        
        // Blinking Text
        AnimatedBuilder(
          animation: _blinkController,
          builder: (context, child) {
            return Opacity(
              opacity: _blinkController.value > 0.5 ? 1.0 : 0.2,
              child: Text(
                'L O A D I N G',
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 16.sp,
                  letterSpacing: 4,
                  shadows: const [
                    Shadow(color: Colors.white, blurRadius: 10),
                  ],
                ),
              ),
            );
          },
        ),
        
        SizedBox(height: 8.h),
        Text(
          'WARPING ENGINE',
          style: GoogleFonts.pressStart2p(
            color: Colors.white54,
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }
}
