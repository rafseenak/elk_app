import 'package:video_player/video_player.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final VideoPlayerController controller;
  final bool isPlaying;

  VideoLoaded(this.controller, this.isPlaying);
}

class VideoError extends VideoState {
  final String error;

  VideoError(this.error);
}
