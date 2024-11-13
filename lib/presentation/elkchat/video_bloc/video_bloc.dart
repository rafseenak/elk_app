import 'package:bloc/bloc.dart';
import 'package:video_player/video_player.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoPlayerBloc extends Bloc<VideoEvent, VideoState> {
  VideoPlayerController? _controller;

  VideoPlayerBloc() : super(VideoInitial()) {
    on<InitializeVideoEvent>(_onInitialize);
    on<PlayPauseVideoEvent>(_onPlayPause);
  }

  Future<void> _onInitialize(
    InitializeVideoEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoLoading());
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(event.videoPath));
      await _controller!.initialize();
      emit(VideoLoaded(_controller!, false));
    } catch (e) {
      emit(VideoError("Failed to load video:$e"));
    }
  }

  void _onPlayPause(
    PlayPauseVideoEvent event,
    Emitter<VideoState> emit,
  ) {
    if (_controller != null && _controller!.value.isInitialized) {
      final isPlaying = _controller!.value.isPlaying;
      if (isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      emit(VideoLoaded(_controller!, !isPlaying));
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
