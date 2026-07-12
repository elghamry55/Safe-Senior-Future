import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../data/entertainment_repository.dart';

// --- State ---
class SongsState {
  final int? playingIndex;
  final Map<int, double> downloadProgress;
  final String? alertMessage;
  final String? actionRequired;

  SongsState({
    this.playingIndex,
    this.downloadProgress = const {},
    this.alertMessage,
    this.actionRequired,
  });

  SongsState copyWith({
    int? playingIndex,
    Map<int, double>? downloadProgress,
    String? alertMessage,
    String? actionRequired,
  }) {
    return SongsState(
      playingIndex: playingIndex ?? this.playingIndex,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      alertMessage: alertMessage,
      actionRequired: actionRequired,
    );
  }
}

// --- Cubit ---
class SongsCubit extends Cubit<SongsState> {
  final EntertainmentRepository repository;
  final AudioPlayer audioPlayer = AudioPlayer();

  // تم نقل القائمة هنا لأنها تمثل بيانات (Data/State) وليس واجهة مستخدم
  final List<Map<String, dynamic>> songs = [
    {
      "title": "يارب ان عظمت ذنوبي كثرة",
      "subtitle": "الشيخ سيد النقشبندي",
      "url": "assets/audio/yarab.mp3",
      "image": "assets/images/elshekh_sayed.jpg",
      "isAsset": true,
    },
    // يمكنك إضافة المزيد هنا مستقبلاً
  ];

  SongsCubit({required this.repository}) : super(SongsState()) {
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        emit(state.copyWith(playingIndex: null));
      }
    });
  }

  Future<void> handleTap(int index) async {
    if (state.playingIndex == index && audioPlayer.playing) {
      await audioPlayer.pause();
      return;
    }

    final song = songs[index];
    bool isAsset = song['isAsset'] ?? false;

    if (isAsset) {
      _startAudio(song['url'], index, sourceType: 'asset');
      return;
    }

    String localPath = await repository.getLocalFilePath("song_storage_$index.mp3");

    if (await repository.isLocalFileValid(localPath)) {
      _startAudio(localPath, index, sourceType: 'file');
    } else {
      emit(state.copyWith(actionRequired: "DOWNLOAD_$index"));
    }
  }

  Future<void> downloadAndPlay(int index) async {
    final song = songs[index];
    String localPath = await repository.getLocalFilePath("song_storage_$index.mp3");

    try {
      final progress = Map<int, double>.from(state.downloadProgress);
      progress[index] = 0.01;
      emit(state.copyWith(downloadProgress: progress));

      await repository.downloadFile(
        url: song['url'],
        savePath: localPath,
        onReceiveProgress: (rec, total) {
          if (total != -1) {
            final newProg = Map<int, double>.from(state.downloadProgress);
            newProg[index] = rec / total;
            emit(state.copyWith(downloadProgress: newProg));
          }
        },
      );

      final finalProg = Map<int, double>.from(state.downloadProgress)..remove(index);
      emit(state.copyWith(downloadProgress: finalProg));

      if (await repository.isLocalFileValid(localPath)) {
        _startAudio(localPath, index, sourceType: 'file');
      }
    } catch (e) {
      final errProg = Map<int, double>.from(state.downloadProgress)..remove(index);
      emit(state.copyWith(
          downloadProgress: errProg,
          alertMessage: "خطأ في التحميل، تأكد من الاتصال بالإنترنت"
      ));
    }
  }

  void _startAudio(String path, int index, {required String sourceType}) async {
    try {
      AudioSource source;
      final song = songs[index];

      if (sourceType == 'asset') {
        source = AudioSource.uri(
          Uri.parse('asset:///$path'),
          tag: MediaItem(id: 'song_$index', title: song['title'], artist: song['subtitle']),
        );
      } else if (sourceType == 'file') {
        source = AudioSource.uri(
          Uri.file(path),
          tag: MediaItem(id: 'song_$index', title: song['title'], artist: song['subtitle']),
        );
      } else {
        source = AudioSource.uri(
          Uri.parse(path),
          tag: MediaItem(id: 'song_$index', title: song['title'], artist: song['subtitle']),
        );
      }

      await audioPlayer.setAudioSource(source);
      audioPlayer.play();
      emit(state.copyWith(playingIndex: index));
    } catch (e) {
      emit(state.copyWith(alertMessage: "حدث خطأ في تشغيل الملف"));
    }
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}