import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/features/game/presentation/game_screen.dart';

import 'package:flutter_application_2/core/audio/retro_synth.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  void _startGame(BuildContext context, String mode) {
    RetroSynth().stopBGM();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(gameMode: mode)),
    ).then((_) {
      RetroSynth().playBGM();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'SELECT MODE',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 24.sp,
                // shadows: const [Shadow(color: Colors.white54, offset: Offset(4, 4))]
              ),
            ),
            
            SizedBox(height: 48.h),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  _buildModeCard(
                    context, 
                    title: 'FAST MODE', 
                    icon: Icons.timer, 
                    description: '60 SECONDS OF PURE ADRENALINE. SCORE AS HIGH AS POSSIBLE.',
                    onTap: () => _startGame(context, 'fast')
                  ),
                  _buildModeCard(
                    context, 
                    title: 'SURVIVAL', 
                    icon: Icons.all_inclusive, 
                    description: 'INFINITE TIME. 3 LIVES. ONE MISS = ONE LIFE LOST. SURVIVE!',
                    onTap: () => _startGame(context, 'survival')
                  ),
                  _buildModeCard(
                    context, 
                    title: 'SANDBOX', 
                    icon: Icons.build, 
                    description: 'NO TIMER, NO SCORE, NO DEATH. JUST PURE TRAINING.',
                    onTap: () => _startGame(context, 'sandbox')
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, {required String title, required IconData icon, required String description, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 4),
        // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(6, 6))]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              children: [
                Icon(icon, size: 48.w, color: Colors.black),
                SizedBox(height: 16.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(color: Colors.black, fontSize: 18.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(color: Colors.black87, fontSize: 10.sp, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
