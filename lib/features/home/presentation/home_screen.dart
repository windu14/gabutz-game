import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_2/features/home/providers/score_provider.dart';
import 'package:flutter_application_2/features/home/presentation/shop_screen.dart';
import 'package:flutter_application_2/features/home/presentation/game_pass_screen.dart';
import 'package:flutter_application_2/features/home/providers/balance_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/features/home/presentation/mode_selection_screen.dart';
import 'package:flutter_application_2/features/home/presentation/widgets/glitch_background.dart';
import 'package:flutter_application_2/features/home/presentation/widgets/indie_grid_bg.dart';
import 'package:flutter_application_2/core/widgets/indie_button.dart';
import 'package:flutter_application_2/core/widgets/indie_bottom_nav.dart';
import 'package:flutter_application_2/core/audio/retro_synth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    RetroSynth().playBGM();
  }

  @override
  void dispose() {
    RetroSynth().stopBGM();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndieGridBackground(
        child: Stack(
          children: [
            const Positioned.fill(
              child: GlitchBackground(),
            ),
            SafeArea(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: IndieBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const ShopScreen();
      case 2:
        return const GamePassScreen();
      case 3:
        return _buildComingSoon('SETTINGS');
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final highScore = ref.watch(scoreProvider);
    final coins = ref.watch(coinsProvider);
    final balance = ref.watch(balanceProvider);
    final formatRp = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- TOP BAR (COINS & BALANCE) ---
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2), // Thin border
                // boxShadow: const [BoxShadow(color: Colors.white54, offset: Offset(4, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on, color: Colors.white, size: 16.w),
                  SizedBox(width: 8.w),
                  Text(
                    '$coins C',
                    style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10.sp),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 16.w),
                  SizedBox(width: 8.w),
                  Text(
                    formatRp.format(balance),
                    style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 48.h),

          // --- HERO TITLE ---
          Text(
            'GabutZ',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 42.sp,
              // shadows: const [Shadow(color: Colors.white54, offset: Offset(6, 6))]
            ),
          ),
          Text(
            'GAME',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 42.sp,
              // shadows: const [Shadow(color: Colors.white54, offset: Offset(6, 6))]
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'HIGH SCORE: $highScore',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: Colors.white54,
              fontSize: 12.sp,
            ),
          ),
          
          SizedBox(height: 48.h),

          // --- PLAY BUTTON ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: IndieButton(
              label: 'START GAME',
              icon: Icons.play_arrow,
              isPrimary: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
                );
              },
            ),
          ),
          
          SizedBox(height: 48.h),

          // --- INFO CARDS ---
          _buildInfoCard(
            title: 'DAILY MISSION',
            icon: Icons.assignment,
            content: 'PLAY 3 GAMES TODAY\nREWARD: 500 C',
          ),
          _buildInfoCard(
            title: 'PRO TIPS',
            icon: Icons.lightbulb,
            content: 'USE BLASTER FOR HIGHER\nACCURACY IN ROUND 2',
          ),
          _buildInfoCard(
            title: 'SUPPORT US',
            icon: Icons.favorite,
            content: 'WATCH AD FOR EXTRA LIVES',
          ),
          
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required String content}) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 2), // Thin border
        // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(4, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32.w),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  content,
                  style: GoogleFonts.pressStart2p(color: Colors.white54, fontSize: 8.sp, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Colors.white54, size: 64.w),
          SizedBox(height: 24.h),
          Text(
            title,
            style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'COMING SOON',
            style: GoogleFonts.pressStart2p(color: Colors.white54, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}
