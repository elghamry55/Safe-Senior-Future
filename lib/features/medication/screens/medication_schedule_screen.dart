import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../data/medication_repository.dart';
import '../logic/medication_cubit.dart';


class MedicationScheduleScreen extends StatelessWidget {
  final String patientID;
  const MedicationScheduleScreen({super.key, required this.patientID});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationCubit(repository: MedicationRepository()),
      child: _MedicationScheduleScreenView(patientID: patientID),
    );
  }
}

class _MedicationScheduleScreenView extends StatefulWidget {
  final String patientID;
  const _MedicationScheduleScreenView({required this.patientID});

  @override
  State<_MedicationScheduleScreenView> createState() => _MedicationScheduleScreenViewState();
}

class _MedicationScheduleScreenViewState extends State<_MedicationScheduleScreenView> {
  void _editMedication(BuildContext context, String docID, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final doseController = TextEditingController(text: data['dosage']);
    final cubit = context.read<MedicationCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: context.read<LocaleCubit>().state.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppTexts.get(context, 'med_edit'), style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: AppTexts.get(context, 'med_name'))),
              TextField(controller: doseController, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: AppTexts.get(context, 'med_dose'))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppTexts.get(context, 'med_cancel'), style: const TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () { cubit.editMedication(widget.patientID, docID, nameController.text, doseController.text); Navigator.pop(dialogContext); },
              child: Text(AppTexts.get(context, 'med_save'), style: const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docID, String medName) {
    final cubit = context.read<MedicationCubit>();
    final primary = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: context.read<LocaleCubit>().state.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppTexts.get(context, 'med_delete_title'), style: const TextStyle(color: Colors.redAccent, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Text("${AppTexts.get(context, 'med_delete_msg')} $medName؟", style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(AppTexts.get(context, 'med_cancel'), style: const TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () { cubit.deleteMedication(widget.patientID, docID); Navigator.pop(dialogContext); },
              child: Text(AppTexts.get(context, 'med_delete_confirm'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MedicationCubit>().repository;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppTexts.get(context, 'med_schedule_title'), style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: isDark ? Colors.white : primary)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: isDark ? Colors.white : primary),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: repo.getMedicationsStream(widget.patientID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primary));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_liquid_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 15),
                  Text(AppTexts.get(context, 'med_no_data'), style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 16)),
                ],
              ));
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var medData = doc.data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    border: Border.all(color: primary.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                      child: Icon(Icons.medication_rounded, color: primary, size: 28),
                    ),
                    title: Text(medData['name'] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${AppTexts.get(context, 'med_dose')} ${medData['dosage']}", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600, fontSize: 13)),
                          Text("${AppTexts.get(context, 'med_time')} ${medData['time']}", style: const TextStyle(fontFamily: 'Cairo', color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent), onPressed: () => _editMedication(context, doc.id, medData)),
                        IconButton(icon: const Icon(Icons.delete_rounded, color: Colors.redAccent), onPressed: () => _confirmDelete(context, doc.id, medData['name'] ?? "")),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}