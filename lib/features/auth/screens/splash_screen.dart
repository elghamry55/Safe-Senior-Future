import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_app/features/auth/screens/WelcomeScreen/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../OnBoarding/OnboardingScreen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _rippleController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _logoScale = Tween<double>(begin: .35, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _backgroundAnimation = Tween<double>(
      begin: -60,
      end: 60,
    ).animate(_backgroundController);

    _pulseAnimation = Tween<double>(begin: 1, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -.05, end: 0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOutBack),
    );

    _rippleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rippleController);

    _logoController.forward();

    _backgroundController.repeat(reverse: true);

    _pulseController.repeat(reverse: true);

    _rotationController.forward();

    _rippleController.repeat();

    _particleController.repeat();

    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final showHome = prefs.getBool('showHome') ?? false;

      if (showHome) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
          ),
        );
      } else {
        await prefs.setBool('showHome', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _rippleController.dispose();
    _particleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _pulseController,
          _rippleController,
          _particleController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              /// Animated Gradient
              AnimatedContainer(
                duration: const Duration(seconds: 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0D47A1),
                      Color(0xff1565C0),
                      Color(0xff42A5F5),
                      Color(0xffBBDEFB),
                    ],
                  ),
                ),
              ),

              /// Floating Blur
              Positioned(
                top: -60 + _backgroundAnimation.value,
                left: -80,
                child: _blurCircle(240, Colors.white.withOpacity(.12)),
              ),

              Positioned(
                right: -70,
                bottom: -20 + _backgroundAnimation.value,
                child: _blurCircle(280, Colors.cyan.withOpacity(.10)),
              ),

              Positioned(
                left: 60 + _backgroundAnimation.value,
                bottom: 140,
                child: _blurCircle(120, Colors.white.withOpacity(.15)),
              ),

              /// Particles
              ...List.generate(20, (index) {
                final x = (index * 25.0) % MediaQuery.of(context).size.width;

                final y =
                    ((index * 60.0) + (_particleController.value * 400)) %
                    MediaQuery.of(context).size.height;

                return Positioned(
                  left: x,
                  top: y,

                  child: Opacity(
                    opacity: .35,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),

              Center(
                child: FadeTransition(
                  opacity: _logoOpacity,

                  child: RotationTransition(
                    turns: _rotationAnimation,

                    child: ScaleTransition(
                      scale: _pulseAnimation,

                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              /// Ripple
                              ...List.generate(3, (i) {
                                final value =
                                    (_rippleAnimation.value + i * .33) % 1;

                                return Transform.scale(
                                  scale: 1 + value,

                                  child: Opacity(
                                    opacity: 1 - value,

                                    child: Container(
                                      width: 190,
                                      height: 190,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white24,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              Hero(
                                tag: "logo",

                                child: Transform.scale(
                                  scale: _logoScale.value,

                                  child: Container(
                                    width: 180,
                                    height: 180,

                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,

                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(.8),
                                          blurRadius: 35,
                                          spreadRadius: 2,
                                        ),

                                        BoxShadow(
                                          color: Colors.blue.withOpacity(.35),
                                          blurRadius: 80,
                                          spreadRadius: 18,
                                        ),

                                        BoxShadow(
                                          color: Colors.cyan.withOpacity(.25),
                                          blurRadius: 130,
                                          spreadRadius: 40,
                                        ),
                                      ],
                                    ),

                                    child: Padding(
                                      padding: const EdgeInsets.all(30),
                                      child: Image.asset(
                                        "assets/images/logo.png",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xff81D4FA),
                                  Colors.white,
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              "SafeFuture",
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "مستقبلٌ أكثر أمانًا... يبدأ بصحتك",
                            style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 60),

                          Container(
                            width: 170,
                            height: 5,

                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(50),
                            ),

                            child: Align(
                              alignment: Alignment.centerLeft,

                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),

                                width: _particleController.value * 170,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xff81D4FA)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(.5), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
