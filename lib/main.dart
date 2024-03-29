import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iflutuber/video_list_screen.dart';
import 'package:iflutuber/video_player_bloc/video_player_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Player Bloc',
      home: BlocProvider(
        create: (context) =>
            VideoPlayerBloc(''), // Initial video ID not required here
        child: const VideoListScreen(), // VideoListScreen as the initial screen
      ),
    );
  }
}
