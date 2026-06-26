import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class IndieButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final double? width;
  final bool isPrimary;
  
  const IndieButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.width,
    this.isPrimary = false,
  });

  @override
  State<IndieButton> createState() => _IndieButtonState();
}

class _IndieButtonState extends State<IndieButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Brutalist colors
    final bgColor = widget.isPrimary ? Colors.white : Colors.black;
    final fgColor = widget.isPrimary ? Colors.black : Colors.white;
    final borderColor = Colors.white;
    // final shadowColor = Colors.white54;
    
    // Calculate the dynamic offset based on pressed state
    // final double offset = _isPressed ? 0.0 : 6.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        margin: EdgeInsets.only(top: _isPressed ? 6.0 : 0.0), // Move widget down to simulate press
        width: widget.width,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2),
          // boxShadow: [
          //   BoxShadow(
          //     color: shadowColor,
          //     offset: Offset(offset, offset),
          //   )
          // ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fgColor, size: 24.w),
              SizedBox(width: 12.w),
            ],
            Text(
              widget.label,
              style: GoogleFonts.pressStart2p(color: fgColor, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
