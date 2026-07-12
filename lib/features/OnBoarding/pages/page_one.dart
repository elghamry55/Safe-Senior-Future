import 'package:flutter/material.dart';
import '../../../../core/services/app_texts.dart';
import '../widgets/onboarding_page.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      image: "assets/images/OnBoarding_1.png",

      title: AppTexts.get(context, "o_title1"),

      description: AppTexts.get(context, "o_sub1"),
    );
  }
}