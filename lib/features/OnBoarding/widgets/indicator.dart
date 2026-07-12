import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_colors.dart';

class Indicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const Indicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: currentIndex == index ? 30.w : 10.w,
          height: 10.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: currentIndex == index
                ? AppColors.primary
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            boxShadow: currentIndex == index
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(.35),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ]
                : null,
          ),
        ),
      ),
    );
  }
}