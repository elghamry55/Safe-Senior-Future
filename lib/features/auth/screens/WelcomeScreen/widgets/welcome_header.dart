import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/services/app_texts.dart';

class WelcomeHeader extends StatelessWidget {
  final bool isDark;

  const WelcomeHeader({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// العنوان
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 34.sp,
            fontWeight: FontWeight.w900,
            fontFamily: "Cairo",
            letterSpacing: .3,
            color: isDark
                ? Colors.white
                : const Color(0xff1B3C73),
          ),
          child: Text(
            AppTexts.get(context, "w_header"),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 14.h),
        /// الوصف
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 320.w,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 18.sp,
              height: 1.8,
              fontWeight: FontWeight.w700,
              fontFamily: "Cairo",
              color: isDark
                  ? Colors.white70
                  : Colors.grey.shade700,
            ),
            child: Text(
              AppTexts.get(context, "w_subtitle"),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}