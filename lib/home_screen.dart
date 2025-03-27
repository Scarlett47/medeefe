import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:medeefe/news_detail_screen.dart';
import 'package:medeefe/saved_news_screen.dart';
import 'news_service.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мэдээ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [HomeScreen(), SavedNewsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Нүүр'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Хадгалсан',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _newsList;
  final NewsService _newsService = NewsService();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;
  List<dynamic> allNews = [];
  Set<int> savedNewsIds = {}; // Track saved news IDs

  @override
  void initState() {
    super.initState();
    _newsList = _newsService.fetchNews();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _refreshNews() {
    setState(() {
      _newsList = _newsService.fetchNews();
    });
  }

  void _toggleSave(int newsId) {
    setState(() {
      if (savedNewsIds.contains(newsId)) {
        savedNewsIds.remove(newsId);
      } else {
        savedNewsIds.add(newsId);
      }
    });
    // Here you would typically also save to your database or storage
  }

  void _startAutoSlide(List<dynamic> sliderNews) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && sliderNews.isNotEmpty) {
        final nextPage =
            _currentPage < sliderNews.length - 1 ? _currentPage + 1 : 0;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
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
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      );
    }
    return Icon(Icons.image, size: 50);
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  Widget _buildSliderItem(Map<String, dynamic> article, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => NewsDetailScreen(
                  id: article['id'],
                  onSave: _toggleSave,
                  isSaved: savedNewsIds.contains(article['id']),
                ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image:
              article['image'] != null && article['image'].isNotEmpty
                  ? DecorationImage(
                    image: NetworkImage(
                      'http://127.0.0.1:8000${article['image']}',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  )
                  : null,
          color:
              article['image'] == null || article['image'].isEmpty
                  ? Colors.grey[300]
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                article['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                article['source'],
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мэдээ'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshNews),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshNews();
        },
        child: FutureBuilder<List<dynamic>>(
          future: _newsList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Мэдээ авчрахад алдаа гарлаа'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshNews,
                      child: Text('Дахин оролдох'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Мэдээ байхгүй байна'));
            }

            allNews = snapshot.data!;
            final sliderNews = allNews.take(5).toList();

            // Start auto-slide after data is loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoSlide(sliderNews);
            });

            return CustomScrollView(
              slivers: [
                // Featured News Slider
                if (sliderNews.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: sliderNews.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return _buildSliderItem(
                                sliderNews[index],
                                context,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: sliderNews.length,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),

                // Recent News Section
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Сүүлийн мэдээ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // All News List
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var article = allNews[index];
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'Нийтлэгдсэн: ${_formatDate(article['created_at'])}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            savedNewsIds.contains(article['id'])
                                ? Icons.bookmark
                                : Icons.bookmark_border,
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
                                    isSaved: savedNewsIds.contains(
                                      article['id'],
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  }, childCount: allNews.length),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
