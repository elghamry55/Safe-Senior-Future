import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/app_texts.dart';
import '../../../core/services/locale_cubit.dart';
import '../data/entertainment_repository.dart';
import '../logic/quran_cubit.dart';


class QuranAudioScreen extends StatelessWidget {
  const QuranAudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuranCubit(repository: EntertainmentRepository()),
      child: const _QuranAudioScreenView(),
    );
  }
}

class _QuranAudioScreenView extends StatelessWidget {
  const _QuranAudioScreenView();

  void _showDownloadDialog(BuildContext context, int index, String surahName) {
    final cubit = context.read<QuranCubit>();
    final primary = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: context.read<LocaleCubit>().state.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("${AppTexts.get(context, 'quran_download_title')} $surahName", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: primary)),
          content: Text(AppTexts.get(context, 'quran_download_msg'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppTexts.get(context, 'med_cancel'), style: const TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              onPressed: () { Navigator.pop(ctx); cubit.downloadAndPlay(index); },
              child: Text(AppTexts.get(context, 'quran_download_btn'), style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final isArabic = context.watch<LocaleCubit>().state.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Premium Header ---
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0F172A) : primary,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                title: Text(AppTexts.get(context, 'quran_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Cairo', fontSize: 24, letterSpacing: 0.5)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark ? [const Color(0xFF0F172A), const Color(0xFF1E293B)] : [primary, primary.withOpacity(0.6)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            )
                        )
                    ),
                    Positioned(
                        right: isArabic ? -40 : null,
                        left: isArabic ? null : -40,
                        top: -20,
                        child: Icon(Icons.menu_book_rounded, size: 220, color: Colors.white.withOpacity(0.05))
                    ),
                  ],
                ),
              ),
            ),

            // --- Premium List ---
            SliverToBoxAdapter(
              child: BlocConsumer<QuranCubit, QuranState>(
                listener: (context, state) {
                  if (state.alertMessage != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.alertMessage!), backgroundColor: Colors.redAccent));
                  if (state.actionRequired != null && state.actionRequired!.startsWith("DOWNLOAD_")) {
                    int idx = int.parse(state.actionRequired!.split("_")[1]);
                    _showDownloadDialog(context, idx, context.read<QuranCubit>().surahs[idx]);
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<QuranCubit>();

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 20, bottom: 40, left: 20, right: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cubit.surahs.length,
                    itemBuilder: (context, index) {
                      bool isPlaying = state.playingIndex == index;
                      double progress = state.downloadProgress[index] ?? 0;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? (isDark ? primary.withOpacity(0.15) : primary.withOpacity(0.08))
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isPlaying
                                  ? primary.withOpacity(0.3)
                                  : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: isPlaying ? 20 : 10,
                              offset: const Offset(0, 5),
                              spreadRadius: isPlaying ? 1 : 0,
                            )
                          ],
                          border: Border.all(
                            color: isPlaying
                                ? primary.withOpacity(0.5)
                                : (isDark ? Colors.white12 : Colors.grey.shade100),
                            width: isPlaying ? 1.5 : 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => cubit.handleTap(index),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // --- Number / Playing Badge ---
                                  Container(
                                    width: 55, height: 55,
                                    decoration: BoxDecoration(
                                      gradient: isPlaying
                                          ? LinearGradient(colors: [primary, primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                                          : LinearGradient(colors: [isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFB), isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: isPlaying ? [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
                                    ),
                                    child: Center(
                                      child: isPlaying
                                          ? const Icon(Icons.multitrack_audio_rounded, color: Colors.white, size: 26)
                                          : Text("${index + 1}", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                  ),

                                  const SizedBox(width: 18),

                                  // --- Surah Info ---
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            cubit.surahs[index],
                                            style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: isPlaying ? FontWeight.w900 : FontWeight.bold,
                                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                                fontFamily: 'Cairo'
                                            )
                                        ),
                                        const SizedBox(height: 6),
                                        progress > 0
                                            ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                  borderRadius: BorderRadius.circular(5),
                                                  child: LinearProgressIndicator(value: progress, color: primary, backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200], minHeight: 4)
                                              ),
                                              const SizedBox(height: 6),
                                              Text("${AppTexts.get(context, 'quran_downloading')} ${(progress * 100).toInt()}%", style: TextStyle(fontSize: 12, fontFamily: 'Cairo', color: primary, fontWeight: FontWeight.bold)),
                                            ]
                                        )
                                            : Text(AppTexts.get(context, 'quran_reader'), style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),

                                  // --- Play / Pause Action ---
                                  if (progress > 0)
                                    SizedBox(width: 35, height: 35, child: CircularProgressIndicator(strokeWidth: 3, color: primary))
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: isPlaying ? primary.withOpacity(0.1) : Colors.transparent, shape: BoxShape.circle),
                                      child: Icon(
                                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: isPlaying ? primary : Colors.grey.shade400,
                                          size: 32
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
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