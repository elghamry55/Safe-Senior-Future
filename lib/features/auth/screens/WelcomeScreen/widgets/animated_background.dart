import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isDark;

  const AnimatedBackground({super.key, required this.isDark});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> moveAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    moveAnimation = Tween<double>(
      begin: -35.w,
      end: 35.w,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget glassCircle(double size, Color color, Offset offset) {
    return AnimatedBuilder(
      animation: moveAnimation,
      builder: (_, __) {
        return Positioned(
          left: offset.dx + moveAnimation.value,
          top: offset.dy - moveAnimation.value,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? const [
                      Color(0xff08111F),
                      Color(0xff111C2F),
                      Color(0xff17263C),
                    ]
                  : const [Color(0xffEAF6FF), Color(0xffF8FBFF), Colors.white],
            ),
          ),
        ),

        glassCircle(
          250.w,
          widget.isDark
              ? const Color(0xff4DA8FF).withOpacity(.10)
              : const Color(0xff4DA8FF).withOpacity(.15),
          Offset(-80.w, -60.h),
        ),

        glassCircle(
          210.w,
          widget.isDark
              ? Colors.cyan.withOpacity(.07)
              : const Color(0xff00D2FF).withOpacity(.12),
          Offset(250.w, 420.h),
        ),

        glassCircle(
          150.w,
          widget.isDark
              ? Colors.indigoAccent.withOpacity(.06)
              : Colors.blueAccent.withOpacity(.08),
          Offset(200.w, 120.h),
        ),
        glassCircle(
          110.w,
          widget.isDark
              ? Colors.tealAccent.withOpacity(.05)
              : Colors.cyan.withOpacity(.10),
          Offset(20.w, 500.h),
        ),
        IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: WavePainter(moveAnimation.value, widget.isDark),
          ),
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double offset;
  final bool isDark;

  WavePainter(this.offset, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(.035)
          : Colors.white.withOpacity(.45)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height * .70);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, size.height * .70 + sin((i / 80) + offset / 25) * 18);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.isDark != isDark;
  }
}
