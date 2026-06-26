import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class IndieBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const IndieBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'HOME'),
            _buildNavItem(1, Icons.shopping_cart, 'SHOP'),
            _buildNavItem(2, Icons.local_activity, 'PASS'),
            _buildNavItem(3, Icons.settings, 'GEAR'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white54,
              size: 24.w,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
}
