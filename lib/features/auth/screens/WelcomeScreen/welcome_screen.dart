import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:graduation_app/features/auth/screens/WelcomeScreen/widgets/animated_background.dart';
import 'package:graduation_app/features/auth/screens/WelcomeScreen/widgets/role_card.dart';
import 'package:graduation_app/features/auth/screens/WelcomeScreen/widgets/welcome_header.dart';

import '../../../../core/services/app_texts.dart';
import '../../../../core/services/locale_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';

import '../../data/auth_repository.dart';
import '../../logic/auth_cubit.dart';

import '../family_signup_screen.dart';
import '../patient_signup_screen.dart';

import '../../../dashboard/screens/dashboard_screen.dart';
import '../../../dashboard/screens/family_dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(repository: AuthRepository())..checkAuthStatus(),
      child: const _WelcomeScreenView(),
    );
  }
}

class _WelcomeScreenView extends StatelessWidget {
  const _WelcomeScreenView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = Theme.of(context).primaryColor;

    final isArabic = context.watch<LocaleCubit>().state.languageCode == "ar";

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,

      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPatientSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(
                  patientID: state.patientID,
                  patientName: state.patientName,
                ),
              ),
            );
          }

          if (state is AuthFamilySuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FamilyDashboardScreen(
                  linkedPatientId: state.linkedPatientId,
                ),
              ),
            );
          }
        },

        child: Scaffold(
          backgroundColor: isDark
              ? const Color(0xff0F172A)
              : const Color(0xffF7FAFF),
          extendBodyBehindAppBar: true,

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
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: primaryColor,
                  size: 28.sp,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ],
          ),

          body: Stack(
            children: [
              AnimatedBackground(isDark: isDark),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),

                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 20.h,
                    ),

                    child: Column(
                      children: [
                        WelcomeHeader(isDark: isDark),
                         SizedBox(height: 40.h),

                        RoleCard(
                          image: "assets/images/welcome_image1.png",

                          title: AppTexts.get(context, "w_patient"),

                          subtitle: AppTexts.get(context, "w_p_desc"),

                          color1: const Color(0xff2F80ED),

                          color2: const Color(0xff1C5ED6),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AuthCubit>(),
                                  child: const PatientSignupScreen(),
                                ),
                              ),
                            );
                          },
                        ),

                         SizedBox(height: 24.h),

                        RoleCard(
                          image: "assets/images/welcome_image2.png",

                          title: AppTexts.get(context, "w_family"),

                          subtitle: AppTexts.get(context, "w_f_desc"),

                          color1: const Color(0xff56CCB2),

                          color2: const Color(0xff2DCE89),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AuthCubit>(),
                                  child: const FamilySignupScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
