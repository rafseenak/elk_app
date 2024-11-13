import 'package:elk/presentation/elkchat/video_bloc/video_bloc.dart';
import 'package:elk/presentation/elkchat/video_bloc/video_event.dart';
import 'package:elk/presentation/elkchat/video_bloc/video_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoMessageWidget extends StatelessWidget {
  final String videoPath;

  const VideoMessageWidget({
    super.key,
    required this.videoPath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VideoPlayerBloc()..add(InitializeVideoEvent(videoPath)),
      child: BlocBuilder<VideoPlayerBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VideoError) {
            return Center(child: Text(state.error));
          } else if (state is VideoLoaded) {
            return GestureDetector(
              onTap: () {
                context.read<VideoPlayerBloc>().add(PlayPauseVideoEvent());
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: state.controller.value.aspectRatio,
                    child: VideoPlayer(state.controller),
                  ),
                  if (!state.isPlaying)
                    const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
