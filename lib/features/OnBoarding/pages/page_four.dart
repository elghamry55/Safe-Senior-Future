import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/app_texts.dart';

class PageFour extends StatelessWidget {
  const PageFour({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// الصورة
              Hero(
                tag: "finish",
                child: Transform.translate(
                  offset: Offset(0, -10.h),
                  child: Container(
                    width: 0.88.sw,
                    height: constraints.maxHeight * 0.45,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(isDark ? .10 : .18),
                          blurRadius: 55.r,
                          spreadRadius: 10.r,
                          offset: Offset(0, 18.h),
                        ),
                        BoxShadow(
                          color: Colors.lightBlueAccent.withOpacity(
                            isDark ? .05 : .10,
                          ),
                          blurRadius: 100.r,
                          spreadRadius: 20.r,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/OnBoarding_4.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// العنوان
              Text(
                AppTexts.get(context, "o_title4"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                  color: isDark ? Colors.white : const Color(0xff0D47A1),
                ),
              ),

              SizedBox(height: 18.h),

              /// الوصف
              Text(
                AppTexts.get(context, "o_sub4"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Cairo",
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
