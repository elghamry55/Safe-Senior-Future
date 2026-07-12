import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/emergency_repository.dart';
import '../logic/emergency_cubit.dart';

// --- Entry Point ---
class EmergencyScreen extends StatelessWidget {
  final String patientID;
  final String name;

  const EmergencyScreen({
    super.key,
    required this.patientID,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmergencyCubit(repository: EmergencyRepository()),
      child: _EmergencyScreenView(patientID: patientID, name: name),
    );
  }
}

// --- UI View ---
class _EmergencyScreenView extends StatelessWidget {
  final String patientID;
  final String name;

  const _EmergencyScreenView({required this.patientID, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF003366)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<EmergencyCubit, EmergencyState>(
        listener: (context, state) {
          if (state is EmergencySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text("تم إرسال نداء الاستغاثة بنجاح"),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is EmergencyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("فشل الإرسال: ${state.error}"), backgroundColor: Colors.black),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                "حالة طوارئ؟",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  "يا $name، عند الضغط على الزر، سيتم تنبيه الأهل والمستشفى فوراً بحالتك",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const SizedBox(height: 50),

              // تم ربط الزرار بالـ Cubit عشان لو جاري الإرسال يظهر Loading
              BlocBuilder<EmergencyCubit, EmergencyState>(
                builder: (context, state) {
                  bool isLoading = state is EmergencyLoading;

                  return GestureDetector(
                    onTap: () {
                      if (!isLoading) {
                        context.read<EmergencyCubit>().sendSOS(patientID: patientID, name: name);
                      }
                    },
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: isLoading ? Colors.grey : Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isLoading ? Colors.grey : Colors.red).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 5)
                            : const Text(
                          "SOS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}