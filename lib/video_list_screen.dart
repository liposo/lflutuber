import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iflutuber/player.dart';
import 'package:iflutuber/video_player_bloc/video_model.dart';
import 'package:iflutuber/video_player_bloc/video_player_bloc.dart';
import 'package:iflutuber/video_player_bloc/video_repository.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final _searchController = TextEditingController();
  Future<List<Video>>? _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = VideoRepository().fetchLatestVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Videos',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Video>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final videos = snapshot.data!; // Safe access after checking errors
            return GridView.count(
              padding: const EdgeInsets.all(8.0),
              crossAxisCount: 2, // Two videos per row
              childAspectRatio: 16 / 9, // Aspect ratio for video thumbnails
              children: List.generate(videos.length, (index) {
                final video = videos[index];
                return InkWell(
                  // Wrap with InkWell for tap handling
                  onTap: () {
                    // Update VideoBloc state and navigate to VideoPlayerScreen
                    BlocProvider.of<VideoPlayerBloc>(context)
                        .add(VideoPlayerEvent.changeVideo);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VideoPlayerScreen()),
                    );
                  },
                  child: GridTile(
                    child: FadeInImage.assetNetwork(
                      placeholder:
                          'assets/placeholder.jpg', // Placeholder image
                      image: video.thumbnailUrl,
                      fit: BoxFit.cover,
                    ), // Video title with ellipsis
                  ),
                );
              }),
            );
          }
        },
      ),
    );
  }
}
