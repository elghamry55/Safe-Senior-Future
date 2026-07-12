import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';

class OnBoardingPage extends StatefulWidget {
  final String image;
  final String title;
  final String description;

  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _imageScale;
  late Animation<double> _imageOpacity;

  late Animation<Offset> _titleAnimation;
  late Animation<Offset> _descAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _imageScale = Tween(
      begin: .75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _imageOpacity = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _titleAnimation = Tween(
      begin: const Offset(0, .35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _descAnimation = Tween(
      begin: const Offset(0, .55),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget blurCircle(double size, Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
          child: Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        blurCircle(
          220,
          Alignment.topLeft,
          (isDark ? AppColors.primary : const Color(0xff6FA8FF)).withOpacity(
            .15,
          ),
        ),

        blurCircle(
          260,
          Alignment.bottomRight,
          (isDark ? AppColors.secondary : Colors.cyan).withOpacity(.12),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Column(
            children: [
              const Spacer(),

              FadeTransition(
                opacity: _imageOpacity,
                child: ScaleTransition(
                  scale: _imageScale,
                  child: Hero(
                    tag: widget.image,
                    child: Image.asset(
                      widget.image,
                      height: 230.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 35.h),
              SlideTransition(
                position: _titleAnimation,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textLight,
                    height: 1.3,
                    fontFamily: "Cairo",
                  ),
                ),
              ),

              SizedBox(height: 18.h),
              SlideTransition(
                position: _descAnimation,
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.subtitleLight,
                    fontSize: 15.sp,
                    height: 1.8,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),

              const Spacer(),

              Container(
                height: 7.h,
                width: 90.w,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(50.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
