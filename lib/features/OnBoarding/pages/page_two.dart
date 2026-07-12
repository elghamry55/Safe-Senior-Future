import 'package:flutter/material.dart';
import '../../../core/services/app_texts.dart';
import '../widgets/onboarding_page.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      image: "assets/images/OnBoarding_2.png",

      title: AppTexts.get(
        context,
        "o_title2",
      ),

      description: AppTexts.get(
        context,
        "o_sub2",
      ),
    );
  }
}