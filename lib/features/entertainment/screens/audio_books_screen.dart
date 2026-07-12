import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/entertainment_repository.dart';
import '../logic/audio_books_cubit.dart';

class AudioBooksScreen extends StatelessWidget {
  const AudioBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioBooksCubit(repository: EntertainmentRepository()),
      child: const _AudioBooksScreenView(),
    );
  }
}

class _AudioBooksScreenView extends StatelessWidget {
  const _AudioBooksScreenView();

  final Color primaryColor = const Color(0xFF003366);
  final Color bgColor = const Color(0xFFFDFDFD);
  final Color cardColor = Colors.white;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBooksCubit, AudioBooksState>(
      builder: (context, state) {
        final cubit = context.read<AudioBooksCubit>();

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(state.isBookOpened ? "قراءة واستماع" : "المكتبة الصوتية", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            backgroundColor: bgColor, elevation: 0, centerTitle: true,
            leading: state.isBookOpened ? IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryColor), onPressed: cubit.closeBook) : null,
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: state.isBookOpened ? _buildReaderWithControls(context, state, cubit) : _buildBookCoverView(cubit),
          ),
        );
      },
    );
  }

  Widget _buildBookCoverView(AudioBooksCubit cubit) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: cubit.openBook,
            child: Hero(
              tag: 'book_cover',
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/images/book_cover.jpg', width: 220, height: 320, fit: BoxFit.cover)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text("يا سلمى أنا الآن وحيد", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 12),
          Text("اضغطي على الكتاب للبدء", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildReaderWithControls(BuildContext context, AudioBooksState state, AudioBooksCubit cubit) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(state.bookContent, style: TextStyle(fontSize: 20, height: 1.8, color: Colors.grey[850], fontFamily: 'Roboto')),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 40),
          decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(trackHeight: 4, activeTrackColor: primaryColor, inactiveTrackColor: primaryColor.withOpacity(0.1), thumbColor: primaryColor, overlayColor: primaryColor.withOpacity(0.1), thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                child: Slider(
                  min: 0, max: state.duration.inSeconds.toDouble() > 0 ? state.duration.inSeconds.toDouble() : 1.0, value: state.position.inSeconds.toDouble(),
                  onChanged: (value) => cubit.seek(Duration(seconds: value.toInt())),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(_formatDuration(state.position), style: TextStyle(color: Colors.grey[500], fontSize: 12)), Text(_formatDuration(state.duration - state.position), style: TextStyle(color: Colors.grey[500], fontSize: 12))],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: Icon(Icons.replay_10, color: primaryColor.withOpacity(0.7), size: 30), onPressed: () => cubit.seek(state.position - const Duration(seconds: 10))),
                  GestureDetector(
                    onTap: cubit.togglePlay,
                    child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]), child: Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 35)),
                  ),
                  IconButton(icon: Icon(Icons.forward_10, color: primaryColor.withOpacity(0.7), size: 30), onPressed: () => cubit.seek(state.position + const Duration(seconds: 10))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}