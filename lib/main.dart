import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/services/locale_cubit.dart';
import 'features/OnBoarding/OnboardingScreen.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';


import 'core/theme/theme_cubit.dart';
import 'core/utils/app_colors.dart';
import 'features/auth/screens/splash_screen.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'emergency_channel',
  'تنبيهات الطوارئ',
  description: 'تنبيهات حرجة للمريض',
  importance: Importance.max,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.showEmergencyNotification(
    title: message.notification?.title ?? "🚨 حالة طوارئ",
    body: message.notification?.body ?? "تحقق من حالة المريض فوراً",
  );
}

// ============================================================================
// 2. الدالة الرئيسية (Main)
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيز والإشعارات
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // قراءة الذاكرة لمعرفة إذا كان المستخدم رأى الـ Onboarding
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;

  // تشغيل التطبيق مغلفاً بالـ Cubits الخاصة بالثيم واللغة
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => LocaleCubit()),
      ],
      child: SafeSeniorApp(showHome: showHome),
    ),
  );
}

// ============================================================================
// 3. واجهة التطبيق الرئيسية (الدمج بين اللوجيك والـ UI الجديد)
// ============================================================================
class SafeSeniorApp extends StatefulWidget {
  final bool showHome;

  const SafeSeniorApp({super.key, required this.showHome});

  @override
  State<SafeSeniorApp> createState() => _SafeSeniorAppState();
}

class _SafeSeniorAppState extends State<SafeSeniorApp> {
  @override
  void initState() {
    super.initState();

    // الاستماع للإشعارات في الـ Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showEmergencyNotification(
        title: message.notification?.title ?? "🚨 إنذار",
        body: message.notification?.body ?? "",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'SafeFuture System',

                  locale: locale,

                  supportedLocales: const [
                    Locale('ar', 'EG'),
                    Locale('en', 'US'),
                  ],

                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],

                  themeMode: themeMode,

                  theme: ThemeData(
                    brightness: Brightness.light,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.primaryLight,
                    ),
                    scaffoldBackgroundColor: AppColors.backgroundLight,
                    primaryColor: AppColors.primaryLight,
                    useMaterial3: true,
                    fontFamily: 'Cairo',
                  ),

                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.primaryDark,
                      brightness: Brightness.dark,
                    ),
                    scaffoldBackgroundColor: AppColors.backgroundDark,
                    primaryColor: AppColors.primaryDark,
                    useMaterial3: true,
                    fontFamily: 'Cairo',
                  ),

                  home: const SplashScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}