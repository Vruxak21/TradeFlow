import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

class NewsArticle {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final String publishedAt;
  final String? source;

  NewsArticle({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    required this.publishedAt,
    this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'],
      urlToImage: json['image'], // GNews uses 'image' instead of 'urlToImage'
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']?['name'],
    );
  }

  // Special factory for Alpha Vantage format
  factory NewsArticle.fromAlphaVantage(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['summary'] ?? '', // Alpha Vantage uses 'summary'
      urlToImage:
          json['banner_image'] ?? null, // Alpha Vantage uses 'banner_image'
      url: json['url'] ?? '',
      publishedAt: json['time_published'] ?? DateTime.now().toIso8601String(),
      source: json['source'] ?? 'Alpha Vantage',
    );
  }
}

class NewsService {
  // GNews API
  final String gNewsApiKey = '5b143a3b70f04e36c09082be5274c022';
  final String gNewsBaseUrl = 'https://gnews.io/api/v4';

  // Alpha Vantage API
  final String alphaVantageApiKey = 'Q25GP4AZ2UK88N1L';
  final String alphaVantageBaseUrl = 'https://www.alphavantage.co';

  Future<List<NewsArticle>> getFinancialNews() async {
    try {
      // Fetch news from both APIs in parallel
      final List<NewsArticle> gNewsArticles = await _fetchGNewsArticles();
      final List<NewsArticle> alphaVantageArticles =
          await _fetchAlphaVantageArticles();

      // Combine results
      List<NewsArticle> combinedNews = [
        ...gNewsArticles,
        ...alphaVantageArticles
      ];

      // Filter for Indian content
      List<NewsArticle> indianNews = _filterForIndianContent(combinedNews);

      // Sort by date (newest first)
      indianNews.sort((a, b) => _parseDateTime(b.publishedAt)
          .compareTo(_parseDateTime(a.publishedAt)));

      print("Total news articles after combining APIs: ${combinedNews.length}");
      print("Indian financial news articles: ${indianNews.length}");

      return indianNews;
    } catch (e) {
      print("Error fetching combined news: $e");
      throw Exception('Error fetching financial news: $e');
    }
  }

  DateTime _parseDateTime(String dateStr) {
    try {
      // Handle Alpha Vantage format (20240220T0930)
      if (dateStr.contains('T') && dateStr.length == 13) {
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = int.parse(dateStr.substring(6, 8));
        final hour = int.parse(dateStr.substring(9, 11));
        final minute = int.parse(dateStr.substring(11, 13));
        return DateTime(year, month, day, hour, minute);
      }
      // Standard ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now(); // Fallback to current time if parsing fails
    }
  }

  Future<List<NewsArticle>> _fetchGNewsArticles() async {
    try {
      final String url =
          '$gNewsBaseUrl/search?q=(finance OR "stock market" OR trading OR investment OR nifty OR sensex OR BSE OR NSE) india&country=in&lang=en&max=20&apikey=$gNewsApiKey';

      print("Fetching GNews from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'];

        print("Number of GNews articles fetched: ${articles.length}");

        return articles
            .map((article) => NewsArticle.fromJson(article))
            .toList();
      } else {
        print("GNews API error: ${response.statusCode} - ${response.body}");
        return []; // Return empty list on error
      }
    } catch (e) {
      print("Error fetching GNews: $e");
      return []; // Return empty list on error
    }
  }

  Future<List<NewsArticle>> _fetchAlphaVantageArticles() async {
    try {
      // Alpha Vantage News Sentiment API
      final String url =
          '$alphaVantageBaseUrl/query?function=NEWS_SENTIMENT&topics=financial_markets,economy_fiscal,finance,stock_market&tickers=RELIANCE.BSE,TATASTEEL.BSE,HDFCBANK.BSE&sort=RELEVANCE&limit=20&apikey=$alphaVantageApiKey';

      print("Fetching Alpha Vantage news from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['feed'] ?? [];

        print("Number of Alpha Vantage articles fetched: ${articles.length}");

        return articles
            .map((article) => NewsArticle.fromAlphaVantage(article))
            .toList();
      } else {
        print(
            "Alpha Vantage API error: ${response.statusCode} - ${response.body}");
        return []; // Return empty list on error
      }
    } catch (e) {
      print("Error fetching Alpha Vantage news: $e");
      return []; // Return empty list on error
    }
  }

  List<NewsArticle> _filterForIndianContent(List<NewsArticle> articles) {
    return articles.where((article) {
      final String titleAndDesc =
          '${article.title.toLowerCase()} ${article.description?.toLowerCase() ?? ''}';

      // Indian financial context keywords
      final bool hasIndianContext = titleAndDesc.contains('india') ||
          titleAndDesc.contains('indian') ||
          titleAndDesc.contains('nifty') ||
          titleAndDesc.contains('sensex') ||
          titleAndDesc.contains('rbi') ||
          titleAndDesc.contains('sebi') ||
          titleAndDesc.contains('bse') ||
          titleAndDesc.contains('nse') ||
          titleAndDesc.contains('rupee') ||
          titleAndDesc.contains('mumbai') ||
          titleAndDesc.contains('delhi');

      // Finance, trading, and stock market content
      final bool hasFinancialContent = titleAndDesc.contains('finance') ||
          titleAndDesc.contains('financial') ||
          titleAndDesc.contains('bank') ||
          titleAndDesc.contains('economy') ||
          titleAndDesc.contains('stock') ||
          titleAndDesc.contains('share') ||
          titleAndDesc.contains('market') ||
          titleAndDesc.contains('trading') ||
          titleAndDesc.contains('investment') ||
          titleAndDesc.contains('mutual fund') ||
          titleAndDesc.contains('bond') ||
          titleAndDesc.contains('budget');

      return hasIndianContext && hasFinancialContent;
    }).toList();
  }
}

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _news = [];
  bool _isLoading = true;
  String? _error;
  bool _showFilters = false;
  Set<String> _selectedCategories = {'All'};

  // Category filter options
  final List<String> _categories = [
    'All',
    'Finance',
    'Stock Market',
    'Trading'
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final news = await _newsService.getFinancialNews();
      if (mounted) {
        setState(() {
          _news = news;
          _isLoading = false;
          _selectedCategories = {'All'}; // Reset filters on reload
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      // Handle Alpha Vantage format (20240220T0930)
      if (dateStr.contains('T') && dateStr.length == 13) {
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = int.parse(dateStr.substring(6, 8));
        final hour = int.parse(dateStr.substring(9, 11));
        final minute = int.parse(dateStr.substring(11, 13));
        return DateFormat('MMM d, y • h:mm a')
            .format(DateTime(year, month, day, hour, minute));
      }

      // Standard ISO format
      return DateFormat('MMM d, y • h:mm a').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _openArticle(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in the default browser
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the article.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Determine category based on article content
  List<String> _getArticleCategories(NewsArticle article) {
    final String content =
        '${article.title.toLowerCase()} ${article.description?.toLowerCase() ?? ''}';
    final List<String> categories = [];

    if (content.contains('finance') ||
        content.contains('financial') ||
        content.contains('bank') ||
        content.contains('economy') ||
        content.contains('budget')) {
      categories.add('Finance');
    }

    if (content.contains('stock') ||
        content.contains('share') ||
        content.contains('market') ||
        content.contains('sensex') ||
        content.contains('nifty') ||
        content.contains('bse') ||
        content.contains('nse')) {
      categories.add('Stock Market');
    }

    if (content.contains('trading') ||
        content.contains('trader') ||
        content.contains('investment') ||
        content.contains('investor') ||
        content.contains('portfolio')) {
      categories.add('Trading');
    }

    if (categories.isEmpty) {
      // Default category based on source if we can't determine from content
      if (article.source?.toLowerCase().contains('market') == true) {
        categories.add('Stock Market');
      } else if (article.source?.toLowerCase().contains('trade') == true) {
        categories.add('Trading');
      } else {
        categories.add('Finance'); // Default fallback
      }
    }

    return categories;
  }

  // Filter articles based on selected categories
  List<NewsArticle> _getFilteredNews() {
    if (_selectedCategories.contains('All')) {
      return _news;
    }

    return _news.where((article) {
      final articleCategories = _getArticleCategories(article);
      return articleCategories
          .any((category) => _selectedCategories.contains(category));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            SafeArea(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                    Expanded(
                      child: Text(
                        "Indian Financial News",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showFilters = !_showFilters;
                              });
                            },
                            icon: Icon(
                              _showFilters
                                  ? Icons.filter_list_off
                                  : Icons.filter_list,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          IconButton(
                            onPressed: _loadNews,
                            icon: const Icon(Icons.refresh,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips section
            if (_showFilters)
              Container(
                color: Colors.grey.shade100,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: AppTheme.accent,
                      backgroundColor: Colors.grey.shade200,
                      checkmarkColor: Colors.black87,
                      onSelected: (selected) {
                        setState(() {
                          if (category == 'All') {
                            _selectedCategories = {'All'};
                          } else {
                            _selectedCategories.remove('All');
                            if (selected) {
                              _selectedCategories.add(category);
                              if (_selectedCategories.length ==
                                  _categories.length - 1) {
                                _selectedCategories = {'All'};
                              }
                            } else {
                              _selectedCategories.remove(category);
                              if (_selectedCategories.isEmpty) {
                                _selectedCategories = {'All'};
                              }
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Error Loading News',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadNews,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredNews = _getFilteredNews();

    if (filteredNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Financial News Found',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredNews.length,
        itemBuilder: (context, index) {
          final article = filteredNews[index];
          final categories = _getArticleCategories(article);

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openArticle(article.url),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.urlToImage != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            article.urlToImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade500,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    article.source ?? 'News',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _formatDate(article.publishedAt),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Category tags
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: categories.map((category) {
                                Color tagColor;
                                if (category == 'Finance') {
                                  tagColor = Colors.blue.shade100;
                                } else if (category == 'Stock Market') {
                                  tagColor = Colors.green.shade100;
                                } else {
                                  tagColor = Colors.orange.shade100;
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              article.title,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            if (article.description != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                article.description!,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _openArticle(article.url),
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppTheme.primary,
                                  ),
                                  label: Text(
                                    'Read More',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppTheme {
  static const primary = Color(0xFFE65100);
  static const secondary = Color(0xFFEF6C00);
  static const accent = Color(0xFFFFA726);
  static final background = Colors.grey.shade50;
  static const cardLight = Colors.white;
  static final cardDark = Colors.orange.shade800;
}
