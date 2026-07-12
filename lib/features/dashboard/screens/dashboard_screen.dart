import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../../auth/screens/WelcomeScreen/welcome_screen.dart';
import '../data/dashboard_repository.dart';
import '../logic/patient_cubit.dart';
import '../../medication/screens/add_medication_screen.dart';
import '../../emergency/screens/emergency_screen.dart';
import '../../medication/screens/medication_schedule_screen.dart';
import '../../entertainment/screens/quran_audio_screen.dart';
import '../../entertainment/screens/audio_books_screen.dart';
import '../../entertainment/screens/songs_screen.dart';
import '../../../core/theme/theme_cubit.dart';
import 'dart:convert';
import 'dart:typed_data';


// --- Entry Point ---
class DashboardScreen extends StatelessWidget {
  final String patientID;
  final String patientName;

  const DashboardScreen({super.key, required this.patientID, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientDashboardCubit(
        repository: DashboardRepository(),
        patientID: patientID,
      ),
      child: _DashboardScreenView(patientID: patientID, patientName: patientName),
    );
  }
}

// --- UI View ---
class _DashboardScreenView extends StatelessWidget {
  final String patientID;
  final String patientName;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  _DashboardScreenView({required this.patientID, required this.patientName});

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()), (route) => false);
    }
  }
  Future<Uint8List?> _loadPatientPhoto() async {
    final prefs = await SharedPreferences.getInstance();

    final photo = prefs.getString('patientPhoto');

    if (photo == null || photo.isEmpty) {
      return null;
    }

    try {
      return base64Decode(photo);
    } catch (_) {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgColor,
        drawer: _buildPremiumDrawer(context, isDark, primaryColor),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Custom Premium AppBar ---
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu_rounded, color: primaryColor, size: 30),
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: isArabic ? 0 : 20, right: isArabic ? 20 : 0, bottom: 16),
                title: Text(
                  AppTexts.get(context, 'd_title'),
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontFamily: 'Cairo', fontSize: 22, letterSpacing: 0.5),
                ),
              ),
              actions: [
                IconButton(icon: Icon(Icons.language_rounded, color: primaryColor), onPressed: () => context.read<LocaleCubit>().toggleLanguage()),
                IconButton(icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: primaryColor), onPressed: () => context.read<ThemeCubit>().toggleTheme()),
                const SizedBox(width: 10),
              ],
            ),

            // --- Body Content ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(context, patientName, isDark, primaryColor, textColor),
                    const SizedBox(height: 25),
                    _buildCopyablePatientID(context, patientID, isDark, primaryColor),
                    const SizedBox(height: 35),

                    // --- Vitals Glowing Cards (البيانات اللحظية) ---
                    BlocBuilder<PatientDashboardCubit, PatientDashboardState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildGlowingVitalCard(context, title: AppTexts.get(context, 'd_heart'), value: state.bpm, unit: "BPM", icon: Icons.favorite_rounded, color: const Color(0xFFFF4B4B), isDark: isDark)),
                                const SizedBox(width: 15),
                                Expanded(child: _buildGlowingVitalCard(context, title: AppTexts.get(context, 'd_spo2'), value: state.spo2, unit: "%", icon: Icons.water_drop_rounded, color: const Color(0xFF4BACFF), isDark: isDark)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildGlowingVitalCard(context, title: AppTexts.get(context, 'd_temp'), value: state.temp, unit: "°C", icon: Icons.thermostat_rounded, color: const Color(0xFFFF9800), isDark: isDark, isWide: true),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 35),

                    // --- Medications Modern Card ---
                    _buildFeatureCard(
                      context: context,
                      title: AppTexts.get(context, 'd_med'),
                      subtitle: AppTexts.get(context, 'd_med_sub'),
                      icon: Icons.medication_rounded,
                      gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MedicationScheduleScreen(patientID: patientID))),
                    ),

                    const SizedBox(height: 25),

                    // --- SOS Emergency Button (Pulsing Effect) ---
                    _buildSOSButton(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // مكونات الواجهة (Widgets)
  // =========================================================================

  Widget _buildWelcomeHeader(
      BuildContext context,
      String name,
      bool isDark,
      Color primary,
      Color textColor,
      ) {
    return Row(
      children: [
        FutureBuilder<Uint8List?>(
          future: _loadPatientPhoto(),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primary,
                    primary.withOpacity(0.5),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                backgroundImage: snapshot.hasData
                    ? MemoryImage(snapshot.data!)
                    : null,
                child: snapshot.hasData
                    ? null
                    : const Icon(
                  Icons.person_rounded,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.get(context, 'd_welcome'),
                style:  TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  fontFamily: 'Cairo',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildCopyablePatientID(BuildContext context, String id, bool isDark, Color primary) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: id));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTexts.get(context, 'd_copied'), style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: primary, behavior: SnackBarBehavior.floating));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppTexts.get(context, 'd_id'), style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                Text(id, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary, letterSpacing: 2)),
              ],
            ),
            Icon(Icons.copy_rounded, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingVitalCard(BuildContext context, {required String title, required String value, required String unit, required IconData icon, required Color color, required bool isDark, bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: color.withOpacity(isDark ? 0.1 : 0.15), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 2),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              if (isWide) ...[const SizedBox(width: 15), Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))],
            ],
          ),
          const SizedBox(height: 15),
          if (!isWide) Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              const SizedBox(width: 5),
              Text(unit, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required BuildContext context, required String title, required String subtitle, required IconData icon, required Gradient gradient, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 35)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontFamily: 'Cairo')),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyScreen(patientID: patientID, name: patientName))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF4B4B), Color(0xFFD50000)]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 10), spreadRadius: 2)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 32),
            const SizedBox(width: 15),
            Text(AppTexts.get(context, 'd_sos'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Cairo', letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  // --- Custom Premium Drawer ---
// --- Custom Premium Drawer ---
  Widget _buildPremiumDrawer(BuildContext context, bool isDark, Color primary) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.9),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: primary.withOpacity(0.1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FutureBuilder<Uint8List?>(
                        future: _loadPatientPhoto(),
                        builder: (context, snapshot) {
                          return Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: snapshot.hasData
                                  ? MemoryImage(snapshot.data!)
                                  : null,
                              child: snapshot.hasData
                                  ? null
                                  : const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 35,
                              ),
                            ),
                          );
                        },
                      ),                      const SizedBox(height: 15),
                      Text(patientName, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ],
                  ),
                ),

                _buildDrawerItem(context, AppTexts.get(context, 'd_menu_med'), Icons.medication_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => AddMedicationScreen(patientID: patientID)))),

                // === تم إضافة زر القرآن الكريم هنا بتصميم مميز ===
                _buildDrawerItem(context, "القرآن الكريم", Icons.menu_book_rounded, const Color(0xFF009688), () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const QuranAudioScreen()))),

                _buildDrawerItem(context, AppTexts.get(context, 'd_menu_ent'), Icons.headphones_rounded, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const AudioBooksScreen()))),

                const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Divider()),
                _buildDrawerItem(context, "سجل النبض", Icons.favorite_rounded, Colors.red, () { Navigator.pop(context); _showHistory(context, "heartRate", "سجل نبض القلب", Icons.favorite, Colors.red); }),
                _buildDrawerItem(context, "سجل الأكسجين", Icons.water_drop_rounded, Colors.blueAccent, () { Navigator.pop(context); _showHistory(context, "SPO2", "سجل نسبة الأكسجين", Icons.water_drop, Colors.blueAccent); }),
                _buildDrawerItem(context, "سجل الحرارة", Icons.thermostat_rounded, Colors.orange, () { Navigator.pop(context); _showHistory(context, "temp", "سجل درجات الحرارة", Icons.thermostat, Colors.orange); }),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Divider()),
                _buildDrawerItem(context, AppTexts.get(context, 'd_logout'), Icons.logout_rounded, Colors.redAccent, () => _logout(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
      title: Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
      onTap: onTap,
    );
  }

  // --- دوال عرض السجلات بقيت كما هي لأنها لوجيك مع تظبيط الـ UI الخفيف ---
  void _showHistory(BuildContext context, String fieldToDisplay, String title, IconData icon, Color color) {
    final repo = context.read<PatientDashboardCubit>().repository;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Container(width: 50, height: 6, margin: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              Padding(padding: const EdgeInsets.all(20), child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'Cairo'))),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder(
                  stream: repo.getVitalsHistoryStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: color));
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) return const Center(child: Text("لا توجد سجلات حالياً", style: TextStyle(fontFamily: 'Cairo')));

                    Map<dynamic, dynamic> values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    List<Map<dynamic, dynamic>> items = [];

                    values.forEach((key, value) {
                      var logData = Map<dynamic, dynamic>.from(value);
                      if (logData.containsKey(fieldToDisplay) || logData['type'] == fieldToDisplay) items.add(logData);
                    });

                    if (items.isEmpty) return const Center(child: Text("لم يتم العثور على سجلات لهذا النوع", style: TextStyle(fontFamily: 'Cairo')));
                    items.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.2)),
                      itemBuilder: (context, index) {
                        var item = items[index];
                        String val = (item[fieldToDisplay] ?? item['value'] ?? '--').toString();
                        String unit = (fieldToDisplay.contains("heart")) ? "BPM" : (fieldToDisplay.contains("temp") || fieldToDisplay.contains("temperature")) ? "°C" : "%";
                        DateTime date = item['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(item['timestamp']) : DateTime.now();

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
                          title: Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: isDark ? Colors.white : Colors.black87)), const SizedBox(width: 5), Text(unit, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold))]),
                          subtitle: Text("${DateFormat('yyyy-MM-dd').format(date)}  •  ${DateFormat('hh:mm a').format(date)}", style: const TextStyle(color: Colors.grey)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}