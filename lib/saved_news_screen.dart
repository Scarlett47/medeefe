import 'package:flutter/material.dart';
import 'news_detail_screen.dart';
import 'news_service.dart';

class SavedNewsScreen extends StatefulWidget {
  @override
  _SavedNewsScreenState createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {
  // In a real app, you would fetch this from your database or storage
  List<dynamic> savedNews = [];
  final NewsService _newsService = NewsService();
  Set<int> savedNewsIds = {};

  @override
  void initState() {
    super.initState();
    _loadSavedNews();
  }

  Future<void> _loadSavedNews() async {
    // Replace this with your actual saved news fetching logic
    final allNews = await _newsService.fetchNews();
    setState(() {
      savedNews =
          allNews.where((news) => savedNewsIds.contains(news['id'])).toList();
    });
  }

  void _toggleSave(int newsId) {
    setState(() {
      if (savedNewsIds.contains(newsId)) {
        savedNewsIds.remove(newsId);
        savedNews.removeWhere((news) => news['id'] == newsId);
      } else {
        savedNewsIds.add(newsId);
        // In a real app, you would add the news item to savedNews list
      }
    });
  }

  Widget _buildArticleImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'http://127.0.0.1:8000$imagePath',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, size: 50);
          },
        ),
      );
    }
    return Icon(Icons.image, size: 50);
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Хадгалсан мэдээ')),
      body:
          savedNews.isEmpty
              ? Center(child: Text('Хадгалсан мэдээ байхгүй байна'))
              : ListView.builder(
                itemCount: savedNews.length,
                itemBuilder: (context, index) {
                  var article = savedNews[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      leading: _buildArticleImage(article['image']),
                      title: Text(
                        article['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['source'],
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                          Text(
                            'Нийтлэгдсэн: ${_formatDate(article['created_at'])}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.bookmark,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => _toggleSave(article['id']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => NewsDetailScreen(
                                  id: article['id'],
                                  onSave: _toggleSave,
                                  isSaved: true,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
