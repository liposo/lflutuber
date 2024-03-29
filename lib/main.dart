import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey =
    'AIzaSyDmVNM4KOd3vZ439QoaA-zs6g9KSfUjVZM'; // Replace with your actual Youtube Data APIv3 Key

void main() => runApp(const YoutubeClient());

Future<List<dynamic>> searchVideos(String query) async {
  final url = Uri.https('www.googleapis.com', '/youtube/v3/search', {
    'part': 'snippet',
    'q': query,
    'order': 'date', // Sort by publish date (latest first)
    'maxResults': '20', // Increase results for grid
    'key': apiKey,
  });
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['items'];
  } else {
    throw Exception('Failed to load videos');
  }
}

Future<void> addToWatchHistory(String videoId) async {
  final prefs = await SharedPreferences.getInstance();
  final watchHistory = prefs.getStringList('watchHistory') ?? [];
  watchHistory.add(videoId);
  await prefs.setStringList('watchHistory', watchHistory);
}

Future<List<String>> getWatchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('watchHistory') ?? [];
}

void launchVideo(String videoId) async {
  final url = 'https://www.youtube.com/watch?v=$videoId';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

Widget buildGrid(BuildContext context, List<dynamic> searchResults) {
  if (searchResults.isEmpty) {
    return const Center(child: Text('Search for videos'));
  }
  return GridView.count(
    crossAxisCount: 2, // Two columns in the grid
    childAspectRatio: 16 / 9, // Aspect ratio for video thumbnails (16:9)
    children: searchResults.map((videoData) {
      final videoId = videoData['id']['videoId'];
      final thumbnailUrl = videoData['snippet']['thumbnails']['default']['url'];
      final title = videoData['snippet']['title'];
      return InkWell(
        onTap: () => launchVideo(videoId),
        child: Card(
          clipBehavior: Clip.antiAlias, // Use Clip.antiAlias for anti-aliasing
          child: Stack(
            children: [
              Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                bottom: 8.0,
                left: 8.0,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

class YoutubeClient extends StatefulWidget {
  const YoutubeClient({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _YoutubeClientState createState() => _YoutubeClientState();
}

class _YoutubeClientState extends State<YoutubeClient> {
  String searchQuery = '';
  List<dynamic> searchResults = []; // Fixed: searchResults defined here
  List<String> watchHistory = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    getWatchHistory().then((data) => setState(() => watchHistory = data));
  }

  Future<void> searchVideosLocal(String query) async {
    setState(() {
      isLoading = true; // Set loading indicator while fetching data
      errorMessage = ''; // Clear any previous error message
    });
    try {
      final results = await searchVideos(query);
      setState(() {
        searchQuery = query;
        searchResults = results;
        isLoading = false;
      });
    } on Exception catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching videos: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Youtube Client'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => searchQuery = value,
                onSubmitted: (value) => searchVideosLocal(value),
                decoration: InputDecoration(
                  hintText: 'Search Videos',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => searchVideosLocal(searchQuery),
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Center(
                  child:
                      CircularProgressIndicator()), // Show progress indicator while loading
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage, // Display error message if any
                style: const TextStyle(color: Colors.red),
              ),
            Expanded(
                child: buildGrid(
                    context, searchResults)), // Pass searchResults to buildGrid
          ],
        ),
      ),
    );
  }
}
