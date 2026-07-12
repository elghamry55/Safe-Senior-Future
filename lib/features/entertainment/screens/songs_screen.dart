import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/entertainment_repository.dart';
import '../logic/songs_cubit.dart';

class SongsScreen extends StatelessWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SongsCubit(repository: EntertainmentRepository()),
      child: const _SongsScreenView(),
    );
  }
}

class _SongsScreenView extends StatelessWidget {
  const _SongsScreenView();

  void _showActionDialog(BuildContext context, int index, String songTitle) {
    final cubit = context.read<SongsCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(songTitle, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("هذا الملف غير محمل، هل تريد تحميله الآن؟", textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.downloadAndPlay(index);
            },
            child: const Text("تحميل", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("الأناشيد والابتهالات", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: BlocConsumer<SongsCubit, SongsState>(
        listener: (context, state) {
          if (state.alertMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.alertMessage!), backgroundColor: Colors.red));
          }
          if (state.actionRequired != null && state.actionRequired!.startsWith("DOWNLOAD_")) {
            int idx = int.parse(state.actionRequired!.split("_")[1]);
            _showActionDialog(context, idx, context.read<SongsCubit>().songs[idx]['title']);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SongsCubit>();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cubit.songs.length,
            itemBuilder: (context, index) {
              final song = cubit.songs[index];
              bool isPlaying = state.playingIndex == index;
              bool isAsset = song['isAsset'] ?? false;
              double progress = state.downloadProgress[index] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
                  border: Border.all(color: isPlaying ? Colors.purple : Colors.transparent, width: 2),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                      child: Image.asset(song['image']!, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: progress > 0
                          ? Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(value: progress, color: Colors.purple),
                          Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10)),
                        ],
                      )
                          : IconButton(
                        icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.purple, size: 50),
                        onPressed: () => cubit.handleTap(index),
                      ),
                      title: Text(song['title']!, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(song['subtitle']!, textAlign: TextAlign.right),
                      trailing: Icon(
                        isAsset ? Icons.sd_storage : Icons.cloud_queue,
                        color: isAsset ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}