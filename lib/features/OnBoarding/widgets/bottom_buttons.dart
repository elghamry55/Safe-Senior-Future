import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/app_texts.dart';
import '../../../core/utils/app_colors.dart';

class BottomButtons extends StatelessWidget {
  final int currentIndex;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const BottomButtons({
    super.key,
    required this.currentIndex,
    required this.pageCount,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = currentIndex == pageCount - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        height: 58.h,
        child: ElevatedButton(
          onPressed: isLastPage ? onFinish : onNext,
          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: isDark ? Colors.white12 : Colors.transparent,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: isDark
                ? Colors.black.withOpacity(.45)
                : AppColors.primary.withOpacity(.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              isLastPage
                  ? AppTexts.get(context, "start")
                  : AppTexts.get(context, "next"),
              key: ValueKey(isLastPage),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: "Cairo",
                letterSpacing: .3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}