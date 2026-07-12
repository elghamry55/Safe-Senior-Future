import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/app_colors.dart';
import '../logic/auth_cubit.dart';
import 'WelcomeScreen/widgets/animated_background.dart';

class FamilySignupScreen extends StatefulWidget {
  const FamilySignupScreen({super.key});

  @override
  State<FamilySignupScreen> createState() => _FamilySignupScreenState();
}

class _FamilySignupScreenState extends State<FamilySignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();

  String _name = '';
  String _relation = '';

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryBlue = Theme.of(context).primaryColor;

    final isArabic = context.watch<LocaleCubit>().state.languageCode == "ar";

    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                state.error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: "Cairo"),
              ),
            ),
          );
        }

        if (state is AuthFamilySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "تم الربط بنجاح! جاري الانتقال...",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Cairo"),
              ),
            ),
          );
        }
      },
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: primaryBlue),
            title: Text(
              "ربط حساب العائلة",
              style: TextStyle(
                color: primaryBlue,
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.language_rounded, color: primaryBlue),
                onPressed: () {
                  context.read<LocaleCubit>().toggleLanguage();
                },
              ),
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: primaryBlue,
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.r, sigmaY: 20.r),
                      child: Container(
                        padding: EdgeInsets.all(24.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(.08)
                              : Colors.white.withOpacity(.65),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(.25),
                            width: 1.3,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: 15.h),

                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 1000),
                                tween: Tween(begin: .7, end: 1),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Hero(
                                  tag: "family_signup",
                                  child: Container(
                                    width: 130.w,
                                    height: 130.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? Colors.white.withOpacity(.05)
                                          : Colors.blue.shade50,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryBlue.withOpacity(.18),
                                          blurRadius: 45.r,
                                          spreadRadius: 5.r,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.family_restroom_rounded,
                                      size: 78.sp,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 30.h),

                              Text(
                                "متابعة حالة المريض",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              SizedBox(height: 10.h),

                              Text(
                                "قم بإدخال بياناتك وكود المريض ليتم ربط الحساب",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  fontSize: 18.sp,
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.blueGrey.shade700,
                                ),
                              ),

                              SizedBox(height: 40.h),

                              _buildTextField(
                                label: "اسمك الشخصي",
                                icon: Icons.person_outline_rounded,
                                textDark: textColor,
                                primaryBlue: primaryBlue,
                                onSaved: (value) => _name = value ?? "",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجى إدخال اسمك";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 20.h),

                              _buildTextField(
                                label: "صلة القرابة",
                                hint: "مثال: ابن - ابنة - أخ - زوجة",
                                icon: Icons.group_outlined,
                                textDark: textColor,
                                primaryBlue: primaryBlue,
                                onSaved: (value) => _relation = value ?? "",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجى تحديد صلة القرابة";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 20.h),

                              _buildTextField(
                                controller: _idController,
                                label: "كود المريض",
                                hint: "PA-123456",
                                icon: Icons.qr_code_scanner_rounded,
                                textDark: textColor,
                                primaryBlue: primaryBlue,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجى إدخال كود المريض";
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 35.h),

                              SizedBox(
                                width: double.infinity,
                                height: 55.h,
                                child: BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return ElevatedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _formKey.currentState!.save();

                                                context
                                                    .read<AuthCubit>()
                                                    .registerFamilyMember(
                                                      name: _name,
                                                      relation: _relation,
                                                      patientId: _idController
                                                          .text
                                                          .trim(),
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 8,
                                        backgroundColor: primaryBlue,
                                        foregroundColor: Colors.white,
                                        shadowColor: primaryBlue.withOpacity(
                                          .35,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18.r,
                                          ),
                                        ),
                                      ),
                                      child: state is AuthLoading
                                          ? SizedBox(
                                              width: 25.w,
                                              height: 25.h,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Text(
                                              "تأكيد الربط",
                                              style: TextStyle(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Cairo",
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 18.h),

                              Text(
                                "تأكد من الحصول على الكود الصحيح من جهاز المريض",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "Cairo",
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Color textDark,
    required Color primaryBlue,
    TextEditingController? controller,
    Function(String?)? onSaved,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: primaryBlue,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: textDark,
        fontFamily: "Cairo",
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: primaryBlue,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          fontFamily: "Cairo",
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade500,
          fontFamily: "Cairo",
        ),
        prefixIcon: Container(
          margin: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: primaryBlue, size: 22.sp),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(.05)
            : Colors.white.withOpacity(.85),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide(color: primaryBlue, width: 2.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red, width: 2.r),
        ),
        errorStyle: TextStyle(fontFamily: "Cairo", fontSize: 12.sp),
      ),
    );
  }
}
