import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleCard extends StatefulWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.onTap,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });

        widget.onTap();
      },

      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },

      child: AnimatedScale(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        scale: isPressed ? .97 : 1,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),

          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.08)
                  : Colors.white.withOpacity(.15),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(25.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,

              end: Alignment.bottomRight,

              colors: [widget.color1, widget.color2],
            ),

            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(.45)
                    : widget.color1.withOpacity(.30),
                blurRadius: 35.r,
                spreadRadius: 2.r,
                offset: Offset(0, 18.h),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.r, sigmaY: 10.r),

              child: Container(
                height: 220.h,
                padding: EdgeInsets.zero,
                child: Stack(
                  children: [
                    /// الصورة
                    Positioned(
                      left: -30.w,
                      bottom: 0,
                      child: Hero(
                        tag: widget.image,
                        child: Image.asset(widget.image, height: 150.h),
                      ),
                    ),

                    /// النص
                    Positioned(
                      top: 15.h,
                      right: 15.w,
                      left: 150.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.title,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: .2,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                            ),
                          ),

                          SizedBox(height: 5.h),
                          Text(
                            widget.subtitle,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              height: 1.6,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Cairo",
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// زر السهم
                    Positioned(
                      bottom: 15.h,
                      right: 20.w,
                      child: Container(
                        width: 43.w,
                        height: 43.w,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xff222B45)
                              : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: widget.color2,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
