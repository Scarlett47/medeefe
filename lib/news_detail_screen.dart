import 'package:flutter/material.dart';
import 'news_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final int id;

  NewsDetailScreen({required this.id, required void Function(int newsId) onSave, required bool isSaved});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late Future<Map<String, dynamic>> _newsDetail;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _newsDetail = _newsService.fetchNewsDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _newsDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Мэдээ авчрахад алдаа гарлаа'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Мэдээ олдсонгүй'));
          } else {
            var article = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        article['image'] != null
                            ? Image.network(
                              'http://127.0.0.1:8000${article['image']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image);
                              },
                            )
                            : Container(color: Colors.grey[300]),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        article['title'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Эх сурвалж: ${article['source']}',
                            style: TextStyle(color: Colors.blue),
                          ),
                          Text(
                            _formatDate(article['created_at']),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        article['description'],
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Нийтлэсэн: ${article['author']}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (article['category'] != null)
                        Chip(
                          label: Text(article['category']['name']),
                          backgroundColor: Colors.blue[100],
                        ),
                    ]),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
