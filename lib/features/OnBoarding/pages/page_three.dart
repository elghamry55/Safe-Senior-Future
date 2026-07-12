import 'package:flutter/material.dart';
import '../../../../core/services/app_texts.dart';
import '../widgets/onboarding_page.dart';

class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      image: "assets/images/OnBoarding_3.png",

      title: AppTexts.get(
        context,
        "o_title3",
      ),

      description: AppTexts.get(
        context,
        "o_sub3",
      ),
    );
  }
}