import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24.w),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'SYSTEM INFO',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white, 
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w), // Balance
                ],
              ),
            ),

            const Spacer(),
            
            // --- INFO PANEL ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('> ENGINE: FLUTTER x PHASER 3', style: GoogleFonts.vt323(color: Colors.white, fontSize: 24.sp)),
                    SizedBox(height: 12.h),
                    Text('> VERSION: 1.0.0', style: GoogleFonts.vt323(color: Colors.white, fontSize: 24.sp)),
                    SizedBox(height: 12.h),
                    Text('> LICENSE: OPEN SOURCE', style: GoogleFonts.vt323(color: Colors.white, fontSize: 24.sp)),
                    SizedBox(height: 24.h),
                    Text('> DEVELOPER: WINDU', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16.sp, height: 1.5)),
                    SizedBox(height: 8.h),
                    Text('  (ALL RIGHTS RESERVED)', style: GoogleFonts.vt323(color: Colors.white54, fontSize: 16.sp)),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
