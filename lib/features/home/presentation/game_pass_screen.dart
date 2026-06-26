import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/core/widgets/indie_button.dart';
import 'package:flutter_application_2/features/home/providers/score_provider.dart';
import 'package:flutter_application_2/features/home/providers/balance_provider.dart';
import 'package:flutter_application_2/features/home/providers/equipment_provider.dart';
import 'package:intl/intl.dart';

class GamePassScreen extends ConsumerStatefulWidget {
  const GamePassScreen({super.key});

  @override
  ConsumerState<GamePassScreen> createState() => _GamePassScreenState();
}

class _GamePassScreenState extends ConsumerState<GamePassScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _buyBundlePass() {
    final balance = ref.read(balanceProvider);
    if (balance >= 99000) {
      ref.read(balanceProvider.notifier).subtractBalance(99000);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Rp 99.000 transaction...')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        ref.read(purchasedItemsProvider.notifier).unlock('trail_pink');
        ref.read(purchasedItemsProvider.notifier).unlock('trail_blue');
        ref.read(purchasedItemsProvider.notifier).unlock('glitch_powerup');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bundle Pass Purchased! Unlocked Pink & Blue Trails + Glitch Powerup.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough Rp balance! Exchange coins first.')),
      );
    }
  }

  void _exchangePoints(int points, int rupiah) {
    final currentCoins = ref.read(coinsProvider);
    if (currentCoins >= points) {
      ref.read(coinsProvider.notifier).addCoins(-points);
      ref.read(balanceProvider.notifier).addBalance(rupiah);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exchanged $points C for Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(rupiah)}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16.h),
        Text(
          'STORE',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 24.sp,
            color: Colors.white,
            // shadows: [const BoxShadow(color: Colors.white, blurRadius: 10)],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'SWIPE TO VIEW OFFERS',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 10.sp,
            color: Colors.white54,
          ),
        ),
        SizedBox(height: 24.h),
        
        Expanded(
          child: PageView(
            controller: _pageController,
            children: [
              _buildBundleCard(0),
              _buildExchangeCard(1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBundleCard(int index) {
    final scale = (_currentPage - index).abs();
    final s = 1.0 - (scale * 0.1);
    final transform = Matrix4.diagonal3Values(s, s, 1.0);
    
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/game_pass_retro.png',
                height: 200.h,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      'STARTER BUNDLE',
                      style: GoogleFonts.pressStart2p(fontSize: 16.sp, color: Colors.white),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '- PINK TRAIL FX\n- BLUE TRAIL FX\n- GLITCH POWERUP',
                      style: GoogleFonts.pressStart2p(fontSize: 12.sp, color: Colors.white70, height: 1.5),
                    ),
                    SizedBox(height: 24.h),
                    IndieButton(
                      label: 'BUY Rp 99.000',
                      onTap: _buyBundlePass,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeCard(int index) {
    final scale = (_currentPage - index).abs();
    final s = 1.0 - (scale * 0.1);
    final transform = Matrix4.diagonal3Values(s, s, 1.0);

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/exchange_retro.png',
                height: 200.h,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      'COIN EXCHANGE',
                      style: GoogleFonts.pressStart2p(fontSize: 16.sp, color: Colors.white),
                    ),
                    SizedBox(height: 16.h),
                    _buildExchangeOption(1000, 25000),
                    SizedBox(height: 8.h),
                    _buildExchangeOption(3000, 70000),
                    SizedBox(height: 8.h),
                    _buildExchangeOption(5000, 99000),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeOption(int coins, int rupiah) {
    final formatRp = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54, width: 2),
      ),
      child: ListTile(
        title: Text(
          '$coins C',
          style: GoogleFonts.pressStart2p(fontSize: 12.sp, color: Colors.white),
        ),
        trailing: IndieButton(
          label: formatRp.format(rupiah),
          onTap: () => _exchangePoints(coins, rupiah),
        ),
      ),
    );
  }
}
