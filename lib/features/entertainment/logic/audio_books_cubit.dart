import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/entertainment_repository.dart';

class AudioBooksState {
  final bool isPlaying;
  final bool isBookOpened;
  final String bookContent;
  final Duration duration;
  final Duration position;

  AudioBooksState({
    this.isPlaying = false,
    this.isBookOpened = false,
    this.bookContent = "",
    this.duration = Duration.zero,
    this.position = Duration.zero,
  });

  AudioBooksState copyWith({
    bool? isPlaying, bool? isBookOpened, String? bookContent,
    Duration? duration, Duration? position,
  }) {
    return AudioBooksState(
      isPlaying: isPlaying ?? this.isPlaying,
      isBookOpened: isBookOpened ?? this.isBookOpened,
      bookContent: bookContent ?? this.bookContent,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}

class AudioBooksCubit extends Cubit<AudioBooksState> {
  final EntertainmentRepository repository;
  final AudioPlayer audioPlayer = AudioPlayer();

  AudioBooksCubit({required this.repository}) : super(AudioBooksState()) {
    _initPlayer();
  }

  void _initPlayer() {
    audioPlayer.onPlayerStateChanged.listen((state) => emit(this.state.copyWith(isPlaying: state == PlayerState.playing)));
    audioPlayer.onDurationChanged.listen((newDuration) => emit(this.state.copyWith(duration: newDuration)));
    audioPlayer.onPositionChanged.listen((newPosition) => emit(this.state.copyWith(position: newPosition)));
  }

  Future<void> openBook() async {
    try {
      final content = await repository.loadBookContent();
      emit(state.copyWith(bookContent: content, isBookOpened: true));
    } catch (e) {
      // Error handling
    }
  }

  void closeBook() {
    audioPlayer.stop();
    emit(state.copyWith(isBookOpened: false));
  }

  Future<void> togglePlay() async {
    state.isPlaying ? await audioPlayer.pause() : await audioPlayer.play(AssetSource('audio/book_audio.mp3'));
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}