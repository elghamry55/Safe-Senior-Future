import 'dart:ui';
import 'dart:io';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../../../core/utils/app_colors.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../core/theme/theme_cubit.dart';
import 'WelcomeScreen/widgets/animated_background.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _age = '';
  String _diseases = '';

  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  // =========================================================================
  // اللوجيك الأصلي 100% بدون أي تغيير في مسارات الفايربيز أو الـ SharedPreferences
  // =========================================================================

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 25,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text(
                "التقاط صورة بالكاميرا",
                style: TextStyle(fontFamily: "Cairo"),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text(
                "اختيار من معرض الصور",
                style: TextStyle(fontFamily: "Cairo"),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithID(String enteredID) async {
    if (enteredID.isEmpty) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );

      var doc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(enteredID)
          .get();

      if (!mounted) return;
      Navigator.pop(context);

      if (doc.exists) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', 'patient');
        await prefs.setString('patientID', enteredID);
        await prefs.setString('patientName', doc.data()?['name'] ?? 'مريض');
        if (doc.data()?['imageContent'] != null) {
          await prefs.setString('patientPhoto', doc.data()!['imageContent']);
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              patientID: enteredID,
              patientName: doc.data()?['name'] ?? 'مريض',
            ),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "هذا الرقم غير مسجل لدينا",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("عذراً، حدث خطأ: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showLoginDialog() {
    final TextEditingController idController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = Theme.of(context).primaryColor;
    final textDark = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final lightBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: context.watch<LocaleCubit>().state.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "دخول برقم المريض",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اكتب الرقم التعريفي الخاص بك للمتابعة",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  color: textDark,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: idController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                decoration: InputDecoration(
                  hintText: "PA-0000",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: lightBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "رجوع",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
              ),
              onPressed: () {
                Navigator.pop(context);
                _loginWithID(idController.text.trim());
              },
              child: Text(
                "دخول",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePatientToFirestore() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "الرجاء إضافة صورة المريض",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Cairo"),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      _formKey.currentState!.save();

      String patientID =
          "PA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
        List<int> imageBytes = await _imageFile!.readAsBytes();

        String base64Image = base64Encode(imageBytes);

        await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientID)
            .set({
              'patientID': patientID,
              'name': _name,
              'age': _age,
              'chronicDiseases': _diseases,
              'imageContent': base64Image,
              'status': 'stable',
              'createdAt': FieldValue.serverTimestamp(),
            });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString(
          'userRole',
          'patient',
        ); // تمت إضافة رول المريض زي اللوجيك القديم
        await prefs.setString('patientID', patientID);
        await prefs.setString('patientName', _name);
        await prefs.setString('patientPhoto', base64Image);

        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DashboardScreen(patientID: patientID, patientName: _name),
          ),
          (route) => false,
        );
      } catch (e) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // =========================================================================
  // واجهة المستخدم (UI) المحدثة
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryBlue = Theme.of(context).primaryColor;

    final isArabic = context.watch<LocaleCubit>().state.languageCode == "ar";

    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(
        backgroundColor: bgColor,

        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          centerTitle: true,

          iconTheme: IconThemeData(color: primaryBlue),

          title: Text(
            AppTexts.get(context, "p_title"),
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
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

                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),

                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25.r, sigmaY: 25.r),

                    child: Container(
                      padding: EdgeInsets.all(24.h),

                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(.08)
                            : Colors.white.withOpacity(.65),
                        borderRadius: BorderRadius.circular(30.r),

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
                            ),

                            Text(
                              AppTexts.get(context, 'p_welcome'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 30.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),

                            SizedBox(height: 10.h),

                            Text(
                              AppTexts.get(context, 'p_fill'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 18,
                                height: 1.6,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.blueGrey.shade700,
                              ),
                            ),

                            SizedBox(height: 35.h),

                            GestureDetector(
                              onTap: _showPickerOptions,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 130.w,
                                    height: 130.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? Colors.white.withOpacity(.05)
                                          : Colors.blue.shade50,
                                      border: Border.all(
                                        color: primaryBlue,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryBlue.withOpacity(.15),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      image: _imageFile != null
                                          ? DecorationImage(
                                              image: FileImage(_imageFile!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _imageFile == null
                                        ? Icon(
                                            Icons.person_add_alt_1_rounded,
                                            size: 65.sp,
                                            color: primaryBlue,
                                          )
                                        : null,
                                  ),

                                  CircleAvatar(
                                    radius: 18.r,
                                    backgroundColor: primaryBlue,
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12.h),

                            Text(
                              isArabic
                                  ? "إضافة صورة المريض"
                                  : "Add Patient Photo",
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                fontSize: 15.sp,
                              ),
                            ),

                            SizedBox(height: 30.h),

                            _buildTextField(
                              label: AppTexts.get(context, "p_name"),
                              icon: Icons.person_outline_rounded,
                              textDark: textColor,
                              primaryBlue: primaryBlue,
                              lightBg: cardColor,
                              onSaved: (value) => _name = value!,
                              validator: (value) => value!.isEmpty
                                  ? (isArabic
                                        ? "الرجاء كتابة الاسم"
                                        : "Please enter your name")
                                  : null,
                            ),

                            SizedBox(height: 22.h),

                            _buildTextField(
                              label: AppTexts.get(context, "p_age"),
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              textDark: textColor,
                              primaryBlue: primaryBlue,
                              lightBg: cardColor,
                              onSaved: (value) => _age = value!,
                              validator: (value) => value!.isEmpty
                                  ? (isArabic
                                        ? "الرجاء إدخال العمر"
                                        : "Please enter age")
                                  : null,
                            ),

                            SizedBox(height: 22.h),

                            _buildTextField(
                              label: AppTexts.get(context, "p_dis"),
                              icon: Icons.favorite_border_rounded,
                              maxLines: 2,
                              textDark: textColor,
                              primaryBlue: primaryBlue,
                              lightBg: cardColor,
                              onSaved: (value) => _diseases = value ?? "",
                            ),

                            SizedBox(height: 35.h),

                            SizedBox(
                              width: double.infinity,
                              height: 55.h,
                              child: ElevatedButton(
                                onPressed: _savePatientToFirestore,
                                style: ElevatedButton.styleFrom(
                                  elevation: 8,
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  shadowColor: primaryBlue.withOpacity(.35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                ),
                                child: Text(
                                  AppTexts.get(context, "p_save"),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Cairo",
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 22.h),

                            InkWell(
                              borderRadius: BorderRadius.circular(18.r),
                              onTap: _showLoginDialog,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 16.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(.05)
                                      : Colors.blue.shade50,

                                  borderRadius: BorderRadius.circular(18),

                                  border: Border.all(
                                    color: primaryBlue.withOpacity(.20),
                                  ),
                                ),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.vpn_key_outlined,
                                      color: primaryBlue,
                                    ),

                                    SizedBox(width: 5.w),

                                    Text(
                                      AppTexts.get(context, "p_login"),
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Cairo",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
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
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Color textDark,
    required Color primaryBlue,
    required Color lightBg,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: textDark,
        fontFamily: 'Cairo',
      ),
      cursorColor: primaryBlue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        labelStyle: TextStyle(
          color: primaryBlue,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),

        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade500,
          fontFamily: 'Cairo',
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
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.red, width: 2.w),
        ),

        errorStyle: TextStyle(fontFamily: "Cairo", fontSize: 12.sp),
      ),
    );
  }
}
