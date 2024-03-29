import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum VideoPlayerEvent { changeVideo }

@immutable
abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerLoading extends VideoPlayerState {}

class VideoPlayerLoaded extends VideoPlayerState {
  final String videoId;

  const VideoPlayerLoaded(this.videoId);

  @override
  List<Object> get props => [videoId];

  @override
  String toString() => 'VideoPlayerLoaded { videoId: $videoId }';
}

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc(String initialVideoId) : super(VideoPlayerInitial()) {
    on<VideoPlayerEvent>((event, emit) {
      if (event == VideoPlayerEvent.changeVideo) {
        emit(
            VideoPlayerLoading()); // Emit loading state before fetching new ID (replace with actual logic)
        // Simulate fetching a new video ID (replace with actual logic)
        const newVideoId = 'new_video_id';
        emit(const VideoPlayerLoaded(newVideoId));
      }
    });
  }
}
