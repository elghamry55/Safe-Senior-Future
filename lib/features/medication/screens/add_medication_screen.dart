import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../data/medication_repository.dart';
import '../logic/medication_cubit.dart';


class AddMedicationScreen extends StatelessWidget {
  final String patientID;
  const AddMedicationScreen({super.key, required this.patientID});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationCubit(repository: MedicationRepository()),
      child: _AddMedicationScreenView(patientID: patientID),
    );
  }
}

class _AddMedicationScreenView extends StatefulWidget {
  final String patientID;
  const _AddMedicationScreenView({required this.patientID});

  @override
  State<_AddMedicationScreenView> createState() => _AddMedicationScreenViewState();
}

class _AddMedicationScreenViewState extends State<_AddMedicationScreenView> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  final List<String> allDays = ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة"];
  List<String> selectedDays = [];

  @override
  void initState() {
    super.initState();
    _setTodayAsDefault();
  }

  void _setTodayAsDefault() {
    Map<int, String> arabicDays = {
      DateTime.monday: "الاثنين", DateTime.tuesday: "الثلاثاء", DateTime.wednesday: "الأربعاء",
      DateTime.thursday: "الخميس", DateTime.friday: "الجمعة", DateTime.saturday: "السبت", DateTime.sunday: "الأحد",
    };
    String? currentDay = arabicDays[DateTime.now().weekday];
    if (currentDay != null) setState(() => selectedDays = [currentDay]);
  }

  void _saveMedication(BuildContext context) {
    if (_nameController.text.isEmpty || _doseController.text.isEmpty || selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى ملء كافة البيانات واختيار يوم واحد على الأقل"), backgroundColor: Colors.redAccent));
      return;
    }
    context.read<MedicationCubit>().addPatientMedication(
      context: context,
      patientID: widget.patientID,
      name: _nameController.text.trim(),
      dose: _doseController.text.trim(),
      time: _selectedTime,
      days: selectedDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';

    return BlocListener<MedicationCubit, MedicationState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: ${state.error}"), backgroundColor: Colors.redAccent));
        }
      },
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(AppTexts.get(context, 'med_add_title'), style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: isDark ? Colors.white : primary)),
            backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
            iconTheme: IconThemeData(color: isDark ? Colors.white : primary),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSectionCard(
                  context: context, title: AppTexts.get(context, 'med_basic_info'), icon: Icons.info_outline_rounded,
                  child: Column(children: [
                    _buildTextField(context, controller: _nameController, label: AppTexts.get(context, 'med_name'), hint: AppTexts.get(context, 'med_name_hint'), icon: Icons.medication_rounded),
                    const SizedBox(height: 15),
                    _buildTextField(context, controller: _doseController, label: AppTexts.get(context, 'med_dose'), hint: AppTexts.get(context, 'med_dose_hint'), icon: Icons.monitor_weight_outlined),
                  ]),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  context: context, title: AppTexts.get(context, 'med_alarm_time'), icon: Icons.access_time_rounded,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      decoration: BoxDecoration(color: primary.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: primary.withOpacity(0.2))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.alarm_rounded, color: primary, size: 28), const SizedBox(width: 15),
                          Text(_selectedTime.format(context), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: primary, letterSpacing: 2)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  context: context, title: AppTexts.get(context, 'med_repeat_days'), icon: Icons.calendar_month_outlined,
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    children: allDays.map((day) {
                      bool isSelected = selectedDays.contains(day);
                      return ChoiceChip(
                        label: Text(day, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87))),
                        selected: isSelected,
                        selectedColor: primary,
                        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? primary : Colors.transparent)),
                        onSelected: (val) => setState(() => val ? selectedDays.add(day) : selectedDays.remove(day)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),
                BlocBuilder<MedicationCubit, MedicationState>(
                  builder: (context, state) {
                    if (state.isLoading) return Center(child: CircularProgressIndicator(color: primary));
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primary, minimumSize: const Size(double.infinity, 65),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 5, shadowColor: primary.withOpacity(0.5)
                      ),
                      onPressed: () => _saveMedication(context),
                      child: Text(AppTexts.get(context, 'med_save_btn'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required BuildContext context, required String title, required IconData icon, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.1 : 0.05))
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 24, color: primary), const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87))]),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Divider(height: 1, color: Colors.grey.withOpacity(0.2))),
        child,
      ]),
    );
  }

  Widget _buildTextField(BuildContext context, {required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    return TextFormField(
      controller: controller, keyboardType: TextInputType.text,
      style: TextStyle(fontFamily: 'Cairo', color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
          labelText: label, hintText: hint,
          labelStyle: TextStyle(fontFamily: 'Cairo', color: primary),
          hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
          prefixIcon: Icon(icon, color: primary),
          filled: true, fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primary, width: 1.5))
      ),
    );
  }
}