import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../data/entertainment_repository.dart';

class QuranState {
  final int? playingIndex;
  final Map<int, double> downloadProgress;
  final String? alertMessage;
  final String? actionRequired;

  QuranState({this.playingIndex, this.downloadProgress = const {}, this.alertMessage, this.actionRequired});

  QuranState copyWith({int? playingIndex, Map<int, double>? downloadProgress, String? alertMessage, String? actionRequired}) {
    return QuranState(
      playingIndex: playingIndex ?? this.playingIndex,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      alertMessage: alertMessage,
      actionRequired: actionRequired,
    );
  }
}

class QuranCubit extends Cubit<QuranState> {
  final EntertainmentRepository repository;
  final AudioPlayer audioPlayer = AudioPlayer();

  // لستة القرآن الـ 114 سورة كاملة
  final List<String> surahs = [
    "الفاتحة", "البقرة", "آل عمران", "النساء", "المائدة", "الأنعام", "الأعراف", "الأنفال", "التوبة", "يونس",
    "هود", "يوسف", "الرعد", "إبراهيم", "الحجر", "النحل", "الإسراء", "الكهف", "مريم", "طه", "الأنبياء", "الحج",
    "المؤمنون", "النور", "الفرقان", "الشعراء", "النمل", "القصص", "العنكبوت", "الروم", "لقمان", "السجدة", "الأحزاب",
    "سبأ", "فاطر", "يس", "الصافات", "ص", "الزمر", "غافر", "فصلت", "الشورى", "الزخرف", "الدخان", "الجاثية",
    "الأحقاف", "محمد", "الفتح", "الحجرات", "ق", "الذاريات", "الطور", "النجم", "القمر", "الرحمن", "الواقعة", "الحديد",
    "المجادلة", "الحشر", "الممتحنة", "الصف", "الجمعة", "المنافقون", "التغابن", "الطلاق", "التحريم", "الملك", "القلم",
    "الحاقة", "المعارج", "نوح", "الجن", "المزمل", "المدثر", "القيامة", "الإنسان", "المرسلات", "النبأ", "النازعات",
    "عبس", "التكوير", "الانفطار", "المطففين", "الانشقاق", "البروج", "الطارق", "الأعلى", "الغاشية", "الفجر", "البلد",
    "الشمس", "الليل", "الضحى", "الشرح", "التين", "العلق", "القدر", "البينة", "الزلزلة", "العاديات", "القارعة",
    "التكاثر", "العصر", "الهمزة", "الفيل", "قريش", "الماعون", "الكوثر", "الكافرون", "النصر", "المسد", "الإخلاص",
    "الفلق", "الناس"
  ];

  QuranCubit({required this.repository}) : super(QuranState()) {
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

    String surahNumber = (index + 1).toString().padLeft(3, '0');
    String localPath = await repository.getLocalFilePath("surah_$surahNumber.mp3");

    if (await repository.isLocalFileValid(localPath)) {
      _startAudio(localPath, index, isLocal: true);
    } else {
      emit(state.copyWith(actionRequired: "DOWNLOAD_$index"));
    }
  }

  Future<void> downloadAndPlay(int index) async {
    String surahNumber = (index + 1).toString().padLeft(3, '0');
    String url = "https://server11.mp3quran.net/yasser/$surahNumber.mp3";
    String localPath = await repository.getLocalFilePath("surah_$surahNumber.mp3");

    try {
      final progress = Map<int, double>.from(state.downloadProgress);
      progress[index] = 0.01;
      emit(state.copyWith(downloadProgress: progress));

      await repository.downloadFile(
        url: url, savePath: localPath,
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
        _startAudio(localPath, index, isLocal: true);
      }
    } catch (e) {
      final errProg = Map<int, double>.from(state.downloadProgress)..remove(index);
      emit(state.copyWith(downloadProgress: errProg, alertMessage: "خطأ في التحميل، تأكد من الاتصال"));
    }
  }

  void _startAudio(String path, int index, {required bool isLocal}) async {
    try {
      final source = AudioSource.uri(
        isLocal ? Uri.file(path) : Uri.parse(path),
        tag: MediaItem(
            id: '${index + 1}',
            album: "المصحف الصوتي",
            title: "سورة ${surahs[index]}",
            artist: "ياسر الدوسري",
            artUri: Uri.parse("https://quran.com/images/quran-share.png")
        ),
      );
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