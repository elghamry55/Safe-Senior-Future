import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/medication_repository.dart';
import '../logic/medication_cubit.dart';

class AddPatientMedicationScreen extends StatelessWidget {
  final String patientId;
  const AddPatientMedicationScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationCubit(repository: MedicationRepository()),
      child: _AddPatientMedicationScreenView(patientId: patientId),
    );
  }
}

class _AddPatientMedicationScreenView extends StatefulWidget {
  final String patientId;
  const _AddPatientMedicationScreenView({required this.patientId});

  @override
  State<_AddPatientMedicationScreenView> createState() => _AddPatientMedicationScreenViewState();
}

class _AddPatientMedicationScreenViewState extends State<_AddPatientMedicationScreenView> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _frequency = "مرة يومياً";

  void _saveMedication(BuildContext context) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("برجاء إدخال اسم الدواء")));
      return;
    }

    context.read<MedicationCubit>().addFamilyMedication(
      context: context,
      patientID: widget.patientId,
      name: _nameController.text,
      dose: _dosageController.text,
      time: _selectedTime,
      frequency: _frequency,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationCubit, MedicationState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("تمت إضافة الدواء بنجاح")));
          Navigator.pop(context);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: ${state.error}")));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("إضافة جرعة جديدة"), backgroundColor: const Color(0xFF003366), foregroundColor: Colors.white),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.add_task_rounded, size: 60, color: Color(0xFF003366))),
              const SizedBox(height: 20),
              const Text("أدخل تفاصيل الدواء المطلوب من المريض تناوله:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              _buildTextField(_nameController, "اسم الدواء", Icons.medication),
              const SizedBox(height: 20),
              _buildTextField(_dosageController, "الجرعة المقررة", Icons.shutter_speed),
              const SizedBox(height: 30),
              const Text("متى يجب تناول هذا الدواء؟", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Card(
                elevation: 0, color: Colors.grey.shade100, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.access_time_filled, color: Colors.orange),
                  title: Text("التوقيت المختار: ${_selectedTime.format(context)}"),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                    if (picked != null) setState(() => _selectedTime = picked);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text("عدد المرات (التكرار):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                items: ["مرة يومياً", "مرتين يومياً", "3 مرات يومياً", "عند اللزوم"].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (val) => setState(() => _frequency = val!),
              ),
              const SizedBox(height: 50),
              BlocBuilder<MedicationCubit, MedicationState>(
                builder: (context, state) {
                  if (state.isLoading) return const Center(child: CircularProgressIndicator());
                  return ElevatedButton(
                    onPressed: () => _saveMedication(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003366), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text("حفظ الجرعة وإرسالها لجدول المريض", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF003366)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), filled: true, fillColor: Colors.white),
    );
  }
}