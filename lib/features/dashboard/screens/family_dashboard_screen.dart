import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart'; // 🚨 مكتبة الصوت

import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/screens/WelcomeScreen/welcome_screen.dart';
import '../../emergency/screens/fall_alert_screen.dart';
import '../data/dashboard_repository.dart';
import '../logic/family_cubit.dart';
import '../../medication/screens/add_patient_medication_screen.dart';
import '../../../core/theme/theme_cubit.dart';

// 🚨 استدعاء الـ Repository والـ Cubit الخاصين بالأدوية للتعديل والحذف
import '../../medication/data/medication_repository.dart';
import '../../medication/logic/medication_cubit.dart';

// --- Entry Point ---
class FamilyDashboardScreen extends StatelessWidget {
  final String linkedPatientId;
  const FamilyDashboardScreen({super.key, required this.linkedPatientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FamilyDashboardCubit(
        repository: DashboardRepository(),
        patientID: linkedPatientId,
      ),
      child: _FamilyDashboardScreenView(linkedPatientId: linkedPatientId),
    );
  }
}

// --- UI View ---
class _FamilyDashboardScreenView extends StatefulWidget {
  final String linkedPatientId;
  const _FamilyDashboardScreenView({required this.linkedPatientId});

  @override
  State<_FamilyDashboardScreenView> createState() => _FamilyDashboardScreenViewState();
}

class _FamilyDashboardScreenViewState extends State<_FamilyDashboardScreenView> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _shakeController;

  // 🚨 متغيرات نظام السقوط والإنذارات
  StreamSubscription? _fallSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _acknowledgedAlerts = {};
  bool _isFallAlarmPlaying = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 🚨 تهيئة الإشعارات ومراقبة السقوط
    NotificationService.initialize();
    _loadFallAlertsData();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fallSubscription?.cancel(); // إغلاق المستمع
    _audioPlayer.dispose();      // إغلاق مشغل الصوت
    super.dispose();
  }

  // 🚨 دوال السقوط والإنذارات
  Future<void> _loadFallAlertsData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _acknowledgedAlerts = (prefs.getStringList('ack_alerts') ?? []).toSet();
      });
      _listenToFallAlerts();
    }
  }

  void _listenToFallAlerts() {
    _fallSubscription = FirebaseFirestore.instance
        .collection('fall_alerts')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final data = doc.data();
      final Timestamp? ts = data['timestamp'] as Timestamp?;

      if (ts == null) return;

      final diff = DateTime.now().difference(ts.toDate()).inMinutes.abs();
      final isEmergency = data['status'] == "EMERGENCY";
      final isNew = !_acknowledgedAlerts.contains(doc.id);

      String message = data['message']?.toString() ?? '🚨 تحذير: رصد حالة سقوط محتملة!';
      String confidence = data['confidence']?.toString() ?? '70%';

      if (isNew && diff < 30 && isEmergency) {

        _startFallAlarm(); // تشغيل الصوت والاهتزاز

        NotificationService.showEmergencyNotification(
          title: "🚨 تحذير سقوط عاجل كبار السن!",
          body: message,
        );

        setState(() {
          _acknowledgedAlerts.add(doc.id);
        });

        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList('ack_alerts', _acknowledgedAlerts.toList());
        });

        // الانبثاق التلقائي لشاشة السقوط
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FallAlertScreen(
                message: message,
                confidence: confidence,
              ),
            ),
          ).then((_) {
            // إيقاف الإنذار عند إغلاق الشاشة
            _stopFallAlarm();
          });
        }
      }
    });
  }

  void _startFallAlarm() async {
    if (!_isFallAlarmPlaying) {
      setState(() => _isFallAlarmPlaying = true);
      if (!_shakeController.isAnimating) _shakeController.repeat(reverse: true);
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/alarm.wav'));
      } catch (e) {
        debugPrint("Error playing alarm sound: $e");
      }
    }
  }

  void _stopFallAlarm() {
    if (_isFallAlarmPlaying) {
      if (mounted) setState(() => _isFallAlarmPlaying = false);
      _shakeController.stop();
      _audioPlayer.stop();
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // =========================================================================
  // 🚨 دوال تعديل وحذف الأدوية (تم إضافتها هنا لتعمل مع الـ Sub-collection)
  // =========================================================================
  void _editMedication(BuildContext context, MedicationCubit cubit, String docID, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final doseController = TextEditingController(text: data['dosage']);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: context.read<LocaleCubit>().state.languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppTexts.get(context, 'med_edit') ?? 'تعديل البيانات', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: AppTexts.get(context, 'med_name') ?? 'الاسم')),
              TextField(controller: doseController, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: AppTexts.get(context, 'med_dose') ?? 'الجرعة')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppTexts.get(context, 'med_cancel') ?? 'إلغاء', style: const TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                cubit.editMedication(widget.linkedPatientId, docID, nameController.text, doseController.text);
                Navigator.pop(dialogContext);
              },
              child: Text(AppTexts.get(context, 'med_save') ?? 'حفظ', style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicationCubit cubit, String docID, String medName) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: context.read<LocaleCubit>().state.languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppTexts.get(context, 'med_delete_title') ?? 'حذف الدواء', style: const TextStyle(color: Colors.redAccent, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Text("${AppTexts.get(context, 'med_delete_msg') ?? 'هل أنت متأكد من حذف'} $medName؟", style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppTexts.get(context, 'med_cancel') ?? 'إلغاء', style: const TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                cubit.deleteMedication(widget.linkedPatientId, docID);
                Navigator.pop(dialogContext);
              },
              child: Text(AppTexts.get(context, 'med_delete_confirm') ?? 'حذف', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';

    return MultiBlocListener(
      listeners: [
        BlocListener<FamilyDashboardCubit, FamilyDashboardState>(
          listenWhen: (previous, current) => previous.isAlarmPlaying != current.isAlarmPlaying,
          listener: (context, state) {
            // اهتزاز الشاشة لإنذارات الـ SOS العادية
            if (state.isAlarmPlaying) {
              if (!_shakeController.isAnimating) _shakeController.repeat(reverse: true);
            } else if (!_isFallAlarmPlaying) {
              _shakeController.stop();
            }
          },
        ),
      ],
      child: Directionality(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: _buildPremiumAppBar(context, primaryColor, isDark),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
                child: child,
              ));
            },
            child: _getSelectedPage(),
          ),
          bottomNavigationBar: _buildPremiumBottomNav(context, primaryColor, isDark),
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0: return _buildHomeScreen(key: const ValueKey(0));
      case 1: return _buildMedicationPage(key: const ValueKey(1));
      case 2: return _buildHistorySelectionPage(key: const ValueKey(2));
      default: return _buildHomeScreen(key: const ValueKey(0));
    }
  }

  // =========================================================================
  // 1. الشاشة الرئيسية (Home)
  // =========================================================================
  Widget _buildHomeScreen({required Key key}) {
    final repo = context.read<FamilyDashboardCubit>().repository;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      key: key,
      stream: repo.getPatientDataStream(widget.linkedPatientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final String patientName = data['name'] ?? 'مريض غير معروف';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveAlarmSection(),
              _buildEnhancedHeader(patientName, widget.linkedPatientId, isDark),
              const SizedBox(height: 30),

              Text(
                  AppTexts.get(context, 'f_dash_vitals'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: 'Cairo')
              ),
              const SizedBox(height: 15),

              StreamBuilder(
                stream: repo.getVitalsStream(),
                builder: (context, AsyncSnapshot<DatabaseEvent> rtdbSnapshot) {
                  Map<dynamic, dynamic> vitals = {};
                  if (rtdbSnapshot.hasData && rtdbSnapshot.data!.snapshot.value != null) {
                    vitals = rtdbSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  }

                  return Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.05,
                        children: [
                          _buildStatCard("نبض القلب", "${vitals['heartRate'] ?? '--'}", "bpm", Icons.favorite_rounded, const Color(0xFFFF4B4B), isDark),
                          _buildStatCard("الأكسجين", "${vitals['SPO2'] ?? '--'}", "%", Icons.water_drop_rounded, const Color(0xFF4BACFF), isDark),
                          _buildStatCard("الحرارة", "${vitals['temperature'] ?? '--'}", "°C", Icons.thermostat_rounded, const Color(0xFFFF9800), isDark),
                          _buildStatCard(AppTexts.get(context, 'f_dash_status'), data['status'] ?? "مستقرة", "", Icons.check_circle_rounded, const Color(0xFF00C853), isDark),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildAlertsHistoryButton(isDark),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // مكونات الشاشة الرئيسية
  // =========================================================================
  Widget _buildActiveAlarmSection() {
    final cubit = context.read<FamilyDashboardCubit>();
    final repo = cubit.repository;

    return StreamBuilder<QuerySnapshot>(
      stream: repo.getPatientAlertsStream(widget.linkedPatientId).take(1),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();

        var alertDoc = snapshot.data!.docs.first;
        var alertData = alertDoc.data() as Map<String, dynamic>;

        return BlocBuilder<FamilyDashboardCubit, FamilyDashboardState>(
          builder: (context, state) {
            final Timestamp? ts = alertData['timestamp'] as Timestamp?;
            if (ts == null || state.acknowledgedAlerts.contains(alertDoc.id)) return const SizedBox.shrink();
            if (DateTime.now().difference(ts.toDate()).inMinutes > 15) return const SizedBox.shrink();
            if (alertData['type'] != "EMERGENCY") return const SizedBox.shrink();

            return AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                double offset = (state.isAlarmPlaying || _isFallAlarmPlaying) ? (sin(_shakeController.value * pi * 10) * 5) : 0;
                return Transform.translate(offset: Offset(offset, 0), child: child);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFD50000)]),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            alertData['message'] ?? "نداء استغاثة عاجل!",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo', fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () => cubit.acknowledgeAlert(alertDoc.id),
                      child: const Text("إيقاف الإنذار وتأكيد الاستلام", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedHeader(String name, String id, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.5)]),
            ),
            child: const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, size: 45, color: Colors.grey)),
          ),
          const SizedBox(height: 15),
          Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontFamily: 'Cairo')),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: id));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTexts.get(context, 'd_copied')), behavior: SnackBarBehavior.floating));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("ID: $id", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Icon(Icons.copy_rounded, size: 16, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: color.withOpacity(isDark ? 0.05 : 0.1), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              if (unit.isNotEmpty) ...[const SizedBox(width: 2), Text(unit, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))],
            ],
          ),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAlertsHistoryButton(bool isDark) {
    return InkWell(
      onTap: _showAlertsHistorySheet,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.notifications_active_rounded, color: Colors.redAccent, size: 24)),
            const SizedBox(width: 15),
            Text(AppTexts.get(context, 'f_dash_alerts'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. صفحة الأدوية (Medications) - مع زراير التعديل والحذف 🚨
  // =========================================================================


  Widget _buildMedicationPage({required Key key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return BlocProvider(
      create: (context) => MedicationCubit(repository: MedicationRepository()),
      child: Builder(
          builder: (medContext) {
            final medCubit = medContext.read<MedicationCubit>();

            return StreamBuilder<QuerySnapshot>(
              key: key,
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .doc(widget.linkedPatientId)
                  .collection('medications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }

                final docs = snapshot.data?.docs ?? [];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPatientMedicationScreen(patientId: widget.linkedPatientId),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        label: Text(
                          AppTexts.get(context, 'f_dash_add_med') ?? 'إضافة جرعة دواء للمريض',
                          style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 5,
                            shadowColor: primaryColor.withOpacity(0.5)),
                      ),
                    ),
                    Expanded(
                      child: docs.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication_liquid_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                            const SizedBox(height: 15),
                            Text(AppTexts.get(context, 'f_dash_no_meds') ?? 'لا توجد أدوية', style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                          : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var doc = docs[index];
                          var med = doc.data() as Map<String, dynamic>;

                          // --- الفحص الذكي لتاريخ اليوم لمزامنة الأهل ---
                          String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                          bool isTakenToday = med['lastTakenDate'] == todayStr;
                          // ----------------------------------------------

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Dismissible(
                              key: Key(doc.id),
                              // تحديد اتجاه السحب ناحية الشمال للحذف
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                alignment: AlignmentDirectional.centerEnd,
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
                              ),
                              confirmDismiss: (direction) async {
                                // إظهار نافذة التأكيد قبل الحذف
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => Directionality(
                                    textDirection: context.read<LocaleCubit>().state.languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                    child: AlertDialog(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text(AppTexts.get(context, 'med_delete_title') ?? 'حذف الدواء', style: const TextStyle(color: Colors.redAccent, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                                      content: Text("${AppTexts.get(context, 'med_delete_msg') ?? 'هل أنت متأكد من حذف'} ${med['name']}؟", style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(dialogContext, false),
                                            child: Text(AppTexts.get(context, 'med_cancel') ?? 'إلغاء', style: const TextStyle(color: Colors.grey))
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                          onPressed: () {
                                            medCubit.deleteMedication(widget.linkedPatientId, doc.id);
                                            Navigator.pop(dialogContext, true);
                                          },
                                          child: Text(AppTexts.get(context, 'med_delete_confirm') ?? 'حذف', style: const TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                                    border: Border.all(color: Colors.grey.withOpacity(0.1))),
                                child: ListTile(
                                  onTap: () {
                                    _editMedication(context, medCubit, doc.id, med);
                                  },
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                                    child: Icon(Icons.medication_rounded, color: primaryColor, size: 28),
                                  ),

                                  // --- تعديل الـ title ليحتوي على الشارة الذكية ---
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        med['name'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                          fontSize: 18,
                                          color: isDark ? Colors.white : Colors.black87,
                                          height: 1.3,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isTakenToday
                                              ? Colors.green.withOpacity(0.12)
                                              : Colors.orange.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isTakenToday
                                                  ? Icons.check_circle_rounded
                                                  : Icons.radio_button_unchecked_rounded,
                                              color: isTakenToday ? Colors.green : Colors.orange,
                                              size: 15,
                                            ),

                                            const SizedBox(width: 5),

                                            Text(
                                              isTakenToday
                                                  ? "تم الأخذ اليوم"
                                                  : "لم يؤخذ بعد",
                                              style: TextStyle(
                                                color: isTakenToday ? Colors.green : Colors.orange,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // --- تعديل الـ subtitle ليحتوي على وقت الأخذ ---
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.scale_rounded, size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 5),
                                            Text("${med['dosage'] ?? ''}", style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
                                          ],
                                        ),
                                        if (isTakenToday && med['lastTakenTime'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "أُخذ الساعة: ${med['lastTakenTime']}",
                                              style: const TextStyle(fontFamily: 'Cairo', color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                    child: Text(med['time'] ?? '', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }
      ),
    );
  }  // =========================================================================
  // 3. صفحة السجلات (History)
  // =========================================================================
  Widget _buildHistorySelectionPage({required Key key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      key: key,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        _buildCategoryButton("سجلات نبض القلب", Icons.favorite_rounded, const Color(0xFFFF4B4B), "heartRate", "bpm", isDark),
        _buildCategoryButton("سجلات الأكسجين", Icons.water_drop_rounded, const Color(0xFF4BACFF), "SPO2", "%", isDark),
        _buildCategoryButton("سجلات الحرارة", Icons.thermostat_rounded, const Color(0xFFFF9800), "temp", "°C", isDark),
      ],
    );
  }

  Widget _buildCategoryButton(String title, IconData icon, Color color, String field, String unit, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        onTap: () => _showHistoryDetails(title, field, unit, color, icon),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
      ),
    );
  }

  // =========================================================================
  // Navigation & App Bar
  // =========================================================================
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context, Color primary, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
          _selectedIndex == 0 ? AppTexts.get(context, 'f_dash_title') : _selectedIndex == 1 ? AppTexts.get(context, 'f_dash_meds') : AppTexts.get(context, 'f_dash_hist'),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontWeight: FontWeight.w900, fontFamily: 'Cairo', fontSize: 22)
      ),
      actions: [
        IconButton(icon: Icon(Icons.language_rounded, color: primary), onPressed: () => context.read<LocaleCubit>().toggleLanguage()),
        IconButton(icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: primary), onPressed: () => context.read<ThemeCubit>().toggleTheme()),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(AppTexts.get(context, 'f_dash_logout'), style: TextStyle(fontFamily: 'Cairo', color: primary, fontWeight: FontWeight.bold)),
                content: Text(AppTexts.get(context, 'f_dash_logout_msg'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(AppTexts.get(context, 'f_dash_cancel'), style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey))),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _logout,
                      child: Text(AppTexts.get(context, 'f_dash_exit'), style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold))
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context, Color primary, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: primary,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: const Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.dashboard_rounded, size: 26)), label: AppTexts.get(context, 'f_dash_title')),
              BottomNavigationBarItem(icon: const Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.medication_rounded, size: 26)), label: AppTexts.get(context, 'f_dash_meds')),
              BottomNavigationBarItem(icon: const Padding(padding: EdgeInsets.only(bottom: 5), child: Icon(Icons.history_edu_rounded, size: 26)), label: AppTexts.get(context, 'f_dash_hist')),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // دوال عرض السجلات (Full UI Logic Restored)
  // =========================================================================
  void _showAlertsHistorySheet() {
    final repo = context.read<FamilyDashboardCubit>().repository;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppTexts.get(context, 'f_dash_alerts'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87))
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: repo.getPatientAlertsStream(widget.linkedPatientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 15),
                          Text(AppTexts.get(context, 'f_dash_no_alerts'), style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16))
                        ]
                    ));
                  }
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.15)),
                    itemBuilder: (context, index) {
                      var alert = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      Timestamp? ts = alert['timestamp'] as Timestamp?;
                      String dateStr = ts != null ? DateFormat('yyyy-MM-dd').format(ts.toDate()) : '--';
                      String timeStr = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '--';
                      bool isEmergency = alert['type'] == "EMERGENCY";

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isEmergency ? Colors.redAccent.withOpacity(0.15) : Colors.orange.withOpacity(0.15), shape: BoxShape.circle),
                            child: Icon(isEmergency ? Icons.warning_rounded : Icons.info_outline_rounded, color: isEmergency ? Colors.redAccent : Colors.orange)
                        ),
                        title: Text(alert['message'] ?? 'إنذار من النظام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87)),
                        subtitle: Text("$dateStr • $timeStr", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDetails(String title, String field, String unit, Color color, IconData icon) {
    final repo = context.read<FamilyDashboardCubit>().repository;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Cairo', color: color))
            ),
            Expanded(
              child: StreamBuilder(
                stream: repo.getVitalsHistoryStream(),
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: color));
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, size: 60, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 15),
                          const Text("لا توجد بيانات مسجلة حالياً", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16))
                        ]
                    ));
                  }

                  Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<String, dynamic>> logs = [];

                  data.forEach((key, value) {
                    if (value is Map && value.containsKey(field)) {
                      Map<String, dynamic> logEntry = Map<String, dynamic>.from(value);
                      DateTime timestamp = value.containsKey('timestamp') ? DateTime.fromMillisecondsSinceEpoch(value['timestamp']) : DateTime.now();
                      logEntry['date'] = DateFormat('yyyy-MM-dd').format(timestamp);
                      logEntry['time'] = DateFormat('hh:mm a').format(timestamp);
                      logs.add(logEntry);
                    }
                  });
                  logs = logs.reversed.toList();

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.15)),
                    itemBuilder: (context, index) {
                      var log = logs[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                            child: Icon(icon, color: color, size: 24)
                        ),
                        title: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text("${log[field]}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: isDark ? Colors.white : Colors.black87)),
                              const SizedBox(width: 5),
                              Text(unit, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold))
                            ]
                        ),
                        subtitle: Text("${log['date']} • ${log['time']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}