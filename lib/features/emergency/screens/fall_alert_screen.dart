import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FallAlertScreen extends StatefulWidget {
  final String message;
  final String confidence;

  const FallAlertScreen({
    super.key,
    required this.message,
    required this.confidence,
  });

  @override
  State<FallAlertScreen> createState() => _FallAlertScreenState();
}

class _FallAlertScreenState extends State<FallAlertScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد حركة النبض (Pulsing Animation) للإنذار
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        // خلفية شفافة عشان تأثير الزجاج يشتغل
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. تأثير الزجاج الشفاف (Glassmorphism)
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: isDark
                    ? const Color(0xFF0F172A).withOpacity(0.85)
                    : const Color(0xFF1B263B).withOpacity(0.6),
              ),
            ),

            // 2. محتوى الإنذار
            SafeArea(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                        offset: const Offset(0, 10),
                      )
                    ],
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(isDark ? 0.3 : 0.1),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- أيقونة الإنذار النابضة ---
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C).withOpacity(0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE74C3C).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            size: 70,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- عنوان الإنذار ---
                      Text(
                        "إنذار طوارئ: رصد سقوط!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1B263B),
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),

                      // --- رسالة الموديل ---
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          height: 1.5,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),

                      // --- نسبة الدقة (AI Confidence) ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.memory_rounded, size: 18, color: Colors.blueGrey),
                            const SizedBox(width: 8),
                            Text(
                              "دقة رصد الموديل: ${widget.confidence}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),

                      // --- زر تأكيد الاستلام ---
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE74C3C).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // اللوجيك بتاعك سليم 100%
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE74C3C),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "تم الاستلام وجاري التصرف",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}