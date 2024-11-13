abstract class VideoEvent {}

class InitializeVideoEvent extends VideoEvent {
  final String videoPath;

  InitializeVideoEvent(this.videoPath);
}

class PlayPauseVideoEvent extends VideoEvent {}
