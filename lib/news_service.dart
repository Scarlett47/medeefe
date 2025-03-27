// lib/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String baseUrl = "http://127.0.0.1:8000/api/news/";

  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // Ensure UTF-8 encoding when parsing the response
        var decodedData = utf8.decode(
          response.bodyBytes,
        ); // Decode response bytes to UTF-8
        List<dynamic> news = json.decode(decodedData); // Decode the JSON data
        return news;
      } else {
        throw Exception("Failed to load news");
      }
    } catch (e) {
      throw Exception("Failed to load news: $e");
    }
  }

  Future<Map<String, dynamic>> fetchNewsDetail(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl$id/"));

      if (response.statusCode == 200) {
        // Ensure UTF-8 encoding when parsing the response
        var decodedData = utf8.decode(
          response.bodyBytes,
        ); // Decode response bytes to UTF-8
        return json.decode(decodedData); // Decode the JSON data
      } else {
        throw Exception("Failed to load news detail");
      }
    } catch (e) {
      throw Exception("Failed to load news detail: $e");
    }
  }
}
