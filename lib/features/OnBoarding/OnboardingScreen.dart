import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_app/features/OnBoarding/pages/page_four.dart';
import 'package:graduation_app/features/OnBoarding/pages/page_one.dart';
import 'package:graduation_app/features/OnBoarding/pages/page_three.dart';
import 'package:graduation_app/features/OnBoarding/pages/page_two.dart';
import 'package:graduation_app/features/OnBoarding/widgets/bottom_buttons.dart';
import 'package:graduation_app/features/OnBoarding/widgets/indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/app_texts.dart';
import '../../core/services/locale_cubit.dart';
import '../../core/theme/theme_cubit.dart';
import '../auth/screens/WelcomeScreen/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  Future finishOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("first_time", false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }

  final List<Widget> pages = [
    const PageOne(),
    const PageTwo(),
    const PageThree(),
    const PageFour(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.language_rounded,
              color: primaryColor,
              size: 28.sp,
            ),
            onPressed: () {
              context.read<LocaleCubit>().toggleLanguage();
            },
          ),
          IconButton(
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: primaryColor,
              size: 28.sp,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 10.h,
                right: 20.w,
                left: 20.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (currentPage != pages.length - 1)
                    TextButton(
                      onPressed: finishOnBoarding,
                      child: Text(
                        AppTexts.get(context, "skip"),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                children: pages,
              ),
            ),
            SizedBox(height: 15.h),
            Indicator(
              currentIndex: currentPage,
              pageCount: pages.length,
            ),
            SizedBox(height: 25.h),
            BottomButtons(
              currentIndex: currentPage,
              pageCount: pages.length,
              onNext: () {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                );
              },
              onFinish: finishOnBoarding,
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + 18.h,
            ),
          ],
        ),
      ),
    );
  }
}