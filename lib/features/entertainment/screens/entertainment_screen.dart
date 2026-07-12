import 'package:flutter/material.dart';
import 'audio_books_screen.dart'; 
import 'quran_audio_screen.dart';

class EntertainmentScreen extends StatelessWidget {
  const EntertainmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // خلفية هادئة وفخمة
      appBar: AppBar(
        title: const Text(
          "الأنشطة والترفيه",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366),
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- الجزء الأول: التحكم في الروبوت ---
            _buildSectionHeader("التحكم في الروبوت", Icons.smart_toy_rounded),
            const SizedBox(height: 15),
            _buildRobotActionGrid(),

            const SizedBox(height: 35),

            // --- الجزء الثاني: ترفيه داخل التطبيق ---
            _buildSectionHeader("الترفيه الشخصي", Icons.interests_rounded),
            const SizedBox(height: 15),

            _buildCategoryCard(
              context,
              title: "القرآن الكريم",
              subtitle: "استمع إلى تلاوات عطرة ومباشرة",
              icon: Icons.menu_book_rounded,
              beginColor: const Color(0xFF004B8D),
              endColor: const Color(0xFF003366),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuranAudioScreen())),
            ),

            _buildCategoryCard(
              context,
              title: "الكتب الصوتية",
              subtitle: "روايات وقصص مسموعة مشوقة",
              icon: Icons.headset_rounded,
              beginColor: const Color(0xFF795548),
              endColor: const Color(0xFF5D4037),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioBooksScreen())),
            ),

            _buildCategoryCard(
              context,
              title: "تمارين الذاكرة",
              subtitle: "ألعاب لتنشيط وتحسين الذهن",
              icon: Icons.psychology_rounded,
              beginColor: const Color(0xFF9C27B0),
              endColor: const Color(0xFF7B1FA2),
              onTap: () {},
            ),

            _buildCategoryCard(
              context,
              title: "معرض الفيديو",
              subtitle: "شاهد محتوى تعليمي وترفيهي",
              icon: Icons.play_circle_filled_rounded,
              beginColor: const Color(0xFFE53935),
              endColor: const Color(0xFFC62828),
              onTap: () {},
            ),
            
            const SizedBox(height: 30),
            _buildModernMiniPlayer(),
          ],
        ),
      ),
    );
  }

  // عنوان القسم
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF003366).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF003366), size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }

  // شبكة أزرار الروبوت
  Widget _buildRobotActionGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _robotActionItem("عرض صور", Icons.collections_rounded, Colors.blue),
          _robotActionItem("تنبيه بصري", Icons.visibility_rounded, Colors.orange),
          _robotActionItem("فيديو", Icons.videocam_rounded, Colors.red),
        ],
      ),
    );
  }

  // العنصر الواحد في شبكة الروبوت (بعد إصلاح خطأ BoxType)
  Widget _robotActionItem(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle, // تم التصحيح هنا
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF444444))
            ),
          ],
        ),
      ),
    );
  }

  // كرت التصنيفات (Gradient Card)
  Widget _buildCategoryCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color beginColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [beginColor, endColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: beginColor.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle, 
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // المشغل المصغر
  Widget _buildModernMiniPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF003366),
            child: Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "نظام الاستماع", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                ),
                Text(
                  "جاهز للتشغيل...", 
                  style: TextStyle(color: Colors.white70, fontSize: 12)
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}