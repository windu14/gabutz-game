import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroMarquee extends StatefulWidget {
  final String text;
  const RetroMarquee({super.key, required this.text});

  @override
  State<RetroMarquee> createState() => _RetroMarqueeState();
}

class _RetroMarqueeState extends State<RetroMarquee> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        if (_scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          if (maxScroll > 0) {
            _scrollController.jumpTo(_controller.value * maxScroll);
          }
        }
      });
    _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RetroMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.forward(from: 0).then((_) => _controller.repeat());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(horizontal: BorderSide(color: Colors.white, width: 2)),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            SizedBox(width: 300.w), // Initial padding
            Text(
              widget.text,
              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10.sp),
            ),
            SizedBox(width: 300.w), // End padding
          ],
        ),
      ),
    );
  }
}
