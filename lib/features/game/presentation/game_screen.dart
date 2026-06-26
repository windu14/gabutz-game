import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_2/features/home/providers/score_provider.dart';
import 'package:flutter_application_2/features/home/providers/equipment_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application_2/features/game/presentation/widgets/retro_loading.dart';
import 'package:flutter_application_2/features/game/presentation/widgets/retro_fire_particles.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class GameScreen extends ConsumerStatefulWidget {
  final String gameMode;
  const GameScreen({super.key, this.gameMode = 'fast'});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  InAppLocalhostServer? localhostServer;
  InAppWebViewController? webViewController;
  bool isServerRunning = false;
  bool _isPhaserReady = false;

  final ValueNotifier<Map<String, dynamic>> hudData = ValueNotifier({
    'score': 0,
    'time': '0.0',
    'combo': 1
  });

  @override
  void initState() {
    super.initState();
    _startServer();
    _setupWebBridge();
  }

  void _setupWebBridge() {
    if (kIsWeb) {
      html.window.onMessage.listen((event) {
        try {
          final msg = event.data.toString();
          if (msg.contains('"type":"HUD"')) {
            final jsonStr = msg.substring(msg.indexOf('{'), msg.lastIndexOf('}') + 1);
            final data = jsonDecode(jsonStr);
            hudData.value = {
              'score': data['score'] ?? 0,
              'time': data['time'] ?? '0.0',
              'lives': data['lives'] ?? 5,
              'combo': data['combo'] ?? 1,
            };
          } else if (msg.contains('"type":"GAMEOVER"')) {
            final jsonStr = msg.substring(msg.indexOf('{'), msg.lastIndexOf('}') + 1);
            final data = jsonDecode(jsonStr);
            final score = data['score'] as int;
            ref.read(scoreProvider.notifier).updateScore(score);
            ref.read(coinsProvider.notifier).addCoins(score ~/ 2);

            if (mounted) {
              Navigator.pop(context);
            }
          } else if (msg.contains('"type":"READY"')) {
            if (mounted) {
              setState(() {
                _isPhaserReady = true;
              });
            }
          }
        } catch (e) {
          // Ignore
        }
      });
    }
  }

  Future<void> _startServer() async {
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          isServerRunning = true;
        });
      }
      return;
    }

    localhostServer = InAppLocalhostServer(port: 8080);
    await localhostServer?.start();
    if (mounted) {
      setState(() {
        isServerRunning = true;
      });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      localhostServer?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isServerRunning) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
          // --- WEBVIEW ---
          InAppWebView(
            initialUrlRequest: URLRequest(
                url: kIsWeb
                    ? WebUri('assets/assets/phaser_shooter/index.html?trailColor=${ref.read(trailColorProvider)}&epicVFX=${ref.read(epicExplosionProvider)}&comboVFX=${ref.read(graphicComboProvider)}&speedBoost=${ref.read(speedBoostProvider)}&longTrail=${ref.read(longTrailProvider)}&glitch=${ref.read(glitchModeProvider)}&mode=${widget.gameMode}&bgm=${ref.read(bgmProvider)}')
                    : WebUri('http://localhost:8080/assets/phaser_shooter/index.html?trailColor=${ref.read(trailColorProvider)}&epicVFX=${ref.read(epicExplosionProvider)}&comboVFX=${ref.read(graphicComboProvider)}&speedBoost=${ref.read(speedBoostProvider)}&longTrail=${ref.read(longTrailProvider)}&glitch=${ref.read(glitchModeProvider)}&mode=${widget.gameMode}&bgm=${ref.read(bgmProvider)}'),
            ),
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              disableContextMenu: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
          ),
          
          // --- NATIVE FLUTTER HUD (HEADER) ---
          if (_isPhaserReady)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sleek Score Box
                        ValueListenableBuilder<Map<String, dynamic>>(
                          valueListenable: hudData,
                          builder: (context, data, _) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.white, width: 2),
                                // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(4, 4))],
                              ),
                              child: Text(
                                widget.gameMode == 'sandbox' ? 'TRAINING' : 'SCORE:\n${data['score']}', 
                                style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10.sp, height: 1.5)
                              ),
                            );
                          }
                        ),
                        // Sleek Time Box
                        ValueListenableBuilder<Map<String, dynamic>>(
                          valueListenable: hudData,
                          builder: (context, data, _) {
                            return Container(
                              padding: widget.gameMode == 'survival' ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: widget.gameMode == 'survival' ? null : BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.white, width: 2),
                                // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(4, 4))],
                              ),
                              child: widget.gameMode == 'survival'
                                ? Stack(
                                    children: [
                                      // Red Outline
                                      Text(
                                        '${data['lives'] ?? 5}',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 48.sp,
                                          height: 1.0,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 2
                                            ..color = Colors.white,
                                        ),
                                      ),
                                      // Transparent Fill
                                      Text(
                                        '${data['lives'] ?? 5}',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 48.sp,
                                          height: 1.0,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'TIME:\n${data['time']}s', 
                                    style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10.sp, height: 1.5), 
                                    textAlign: TextAlign.right
                                  ),
                            );
                          }
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Sleek Combo Box
                    ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: hudData,
                      builder: (context, data, _) {
                        final combo = data['combo'] as int;
                        if (combo <= 1) return const SizedBox.shrink(); // Hide if no combo
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 4),
                            // boxShadow: const [BoxShadow(color: Colors.white54, offset: Offset(6, 6))],
                          ),
                          child: RetroFireParticles(
                            child: Text(
                              'COMBO x$combo',
                              style: GoogleFonts.pressStart2p(color: Colors.black, fontSize: 16.sp),
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          
          // --- THE TRUE LOADING SCREEN ---
          if (!_isPhaserReady)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: RetroLoading(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
