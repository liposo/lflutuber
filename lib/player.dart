import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart'; // Import video_player package

import 'video_player_bloc/video_player_bloc.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        centerTitle: true,
      ),
      body: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        builder: (context, state) {
          if (state is VideoPlayerInitial) {
            return const Center(child: Text('Loading...'));
          } else if (state is VideoPlayerLoaded) {
            final videoId = state.videoId;
            final videoUrl =
                'https://www.youtube.com/watch?v=$videoId'; // Assuming video URL format

            return _buildVideoPlayer(videoUrl);
          } else {
            return const Text('Something went wrong!');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<VideoPlayerBloc>().add(VideoPlayerEvent.changeVideo),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildVideoPlayer(String url) {
    // Create a VideoPlayerController instance
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    // Initialize the controller and display video when ready
    return FutureBuilder<void>(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Display the video player
          return AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          );
        } else {
          // Display a loading indicator while waiting
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
