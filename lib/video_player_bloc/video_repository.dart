import 'dart:convert';

import 'package:http/http.dart' as http;

import 'video_model.dart';

class VideoRepository {
  static const String _apiKey =
      'AIzaSyDmVNM4KOd3vZ439QoaA-zs6g9KSfUjVZM'; // Replace with your YouTube API key
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  Future<List<Video>> fetchLatestVideos() async {
    final url = Uri.parse(
        '$_baseUrl?part=snippet&maxResults=10&order=date&type=video&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final videos =
          List<Video>.from(data['items'].map((item) => Video.fromJson(item)));
      return videos;
    } else {
      throw Exception('Failed to fetch videos');
    }
  }
}
