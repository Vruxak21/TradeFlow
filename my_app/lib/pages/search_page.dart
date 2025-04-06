import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';



class StockData {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final bool isPositive;

  StockData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.isPositive,
  });

  factory StockData.fromJson(String symbol, Map<String, dynamic> json) {
    final quote = json['meta']['regularMarketPrice'];
    final previousClose = json['meta']['previousClose'];
    final changePercent = ((quote - previousClose) / previousClose) * 100;

    return StockData(
      symbol: symbol,
      name: symbol.split('.')[0],
      price: quote.toDouble(),
      changePercent: changePercent,
      isPositive: changePercent >= 0,
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<StockData> _stockResults = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _financialTerms = [
    {
      'term': 'Stock',
      'definition': 'A type of security that represents ownership in a corporation, giving shareholders a claim on part of the company\'s assets and earnings.',
      'icon': Icons.auto_graph
    },
    {
      'term': 'Bull Market',
      'definition': 'A financial market where prices are rising or expected to rise, typically characterized by widespread optimism and investor confidence.',
      'icon': Icons.trending_up
    },
    {
      'term': 'Bear Market',
      'definition': 'A market condition where prices are falling, typically indicating pessimism and declining investor confidence.',
      'icon': Icons.trending_down
    },
    {
      'term': 'Dividend',
      'definition': 'A distribution of a portion of a company\'s earnings paid to shareholders, usually in the form of cash or additional shares.',
      'icon': Icons.monetization_on
    },
    {
      'term': 'Market Capitalization',
      'definition': 'The total value of a company\'s outstanding shares, calculated by multiplying the current share price by the total number of outstanding shares.',
      'icon': Icons.account_balance
    },
    {
      'term': 'Equity',
      'definition': 'The value of ownership in a company, representing the amount of money that would be returned to shareholders if all assets were liquidated.',
      'icon': Icons.security
    },
    {
      'term': 'IPO',
      'definition': 'The process by which a private company first offers shares of stock to the public, allowing it to raise capital by selling shares.',
      'icon': Icons.launch
    },
    {
      'term': 'Portfolio',
      'definition': 'A collection of financial investments such as stocks, bonds, mutual funds, and other assets owned by an investor.',
      'icon': Icons.pie_chart
    },
    {
      'term': 'Volatility',
      'definition': 'A statistical measure of the dispersion of returns for a given security or market index, indicating the level of risk or price fluctuations.',
      'icon': Icons.waves
    },
    {
      'term': 'Blue Chip Stock',
      'definition': 'Stocks of large, well-established, and financially sound companies with a history of reliable performance and often paying dividends.',
      'icon': Icons.stars
    },
  ];

  int _currentGlossaryIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDefaultStocks();
  }

  Future<void> _fetchDefaultStocks() async {
    setState(() => _isLoading = true);

    final defaultStocks = [
      'RELIANCE.NS',
      'TCS.NS',
      'HDFCBANK.NS',
      'INFY.NS',
      'ICICIBANK.NS'
    ];

    try {
      List<StockData> results = [];
      for (String stock in defaultStocks) {
        final stockData = await _fetchStockData(stock);
        if (stockData != null) {
          results.add(stockData);
        }
      }

      if (mounted) {
        setState(() {
          _stockResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching stocks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<StockData?> _fetchStockData(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$symbol'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final result = data['chart']['result'][0];
        
        return StockData.fromJson(symbol, result);
      }
    } catch (e) {
      print('Error fetching stock $symbol: $e');
    }
    return null;
  }

  Future<void> _searchStocks(String query) async {
    if (query.isEmpty) {
      _fetchDefaultStocks();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final symbol = '${query.toUpperCase()}.NS';
      final stockData = await _fetchStockData(symbol);

      if (mounted) {
        setState(() {
          _stockResults = stockData != null ? [stockData] : [];
          _isLoading = false;
        });

        if (stockData == null && query.isNotEmpty) {
          _showErrorSnackBar('Stock not found');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error searching stocks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.deepOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced orange color palette
    final orangeTheme = {
      'primary': Color(0xFFFF5722),       // Deep Orange
      'primaryLight': Color(0xFFFF7043),  // Light Orange
      'primaryDark': Color(0xFFE64A19),   // Dark Orange
      'accent': Color(0xFFFF9800),        // Orange Accent
      'background': Color(0xFFFFF3E0),    // Soft Orange Background
      'surface': Color(0xFFFFE0B2),       // Light Surface Orange
      'text': Color(0xFF5D4037),          // Dark Brown for text
      'textLight': Color(0xFF8D6E63),     // Lighter Brown for secondary text
    };

    return Scaffold(
      backgroundColor: orangeTheme['background'],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: orangeTheme['background'],
              elevation: 0,
              title: Text(
                'Stock Insight',
                style: TextStyle(
                  color: orangeTheme['primaryDark'],
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.info_outline, color: orangeTheme['primary']),
                  onPressed: () {
                    // Add info action
                  },
                ),
              ],
            ),

            // Search Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: orangeTheme['primary']!.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: orangeTheme['text']),
                    decoration: InputDecoration(
                      hintText: 'Search NSE Stocks (e.g., RELIANCE)',
                      hintStyle: TextStyle(color: orangeTheme['textLight']),
                      prefixIcon: Icon(Icons.search, color: orangeTheme['primary']),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: orangeTheme['primary']),
                        onPressed: () {
                          _searchController.clear();
                          _fetchDefaultStocks();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: orangeTheme['primary']!, 
                          width: 2
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: _searchStocks,
                  ),
                ),
              ),
            ),

            // Stock Results Section
            SliverToBoxAdapter(
              child: _isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: orangeTheme['primary'],
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : _stockResults.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No stocks found. Try searching for companies like RELIANCE, TCS, or HDFCBANK',
                              style: TextStyle(
                                color: orangeTheme['textLight'],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: orangeTheme['primaryLight']!.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _stockResults.length,
                            separatorBuilder: (context, index) => Divider(
                              color: orangeTheme['surface'],
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final stock = _stockResults[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: orangeTheme['primary']!.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    stock.isPositive ? Icons.trending_up : Icons.trending_down,
                                    color: stock.isPositive ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  stock.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: orangeTheme['text'],
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  stock.symbol,
                                  style: TextStyle(
                                    color: orangeTheme['textLight'],
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${stock.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: stock.isPositive ? Colors.green.shade700 : Colors.red.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${stock.changePercent.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: stock.isPositive ? Colors.green.shade700 : Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Add navigation to stock details
                                },
                              );
                            },
                          ),
                        ),
            ),

            // Financial Glossary Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      'Financial Glossary',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: orangeTheme['primaryDark'],
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.lightbulb_outline,
                      color: orangeTheme['accent'],
                    ),
                  ],
                ),
              ),
            ),

            // Financial Glossary Carousel
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: _financialTerms.length,
                      options: CarouselOptions(
                        height: 280,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        viewportFraction: 0.85,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentGlossaryIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final term = _financialTerms[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: orangeTheme['surface'],
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: orangeTheme['primary']!.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      term['icon'] as IconData,
                                      size: 40,
                                      color: orangeTheme['primaryDark'],
                                    ),
                                  ),
                                  Text(
                                    term['term']!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: orangeTheme['primaryDark'],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    term['definition']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: orangeTheme['text'],
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _financialTerms.map((term) {
                        int index = _financialTerms.indexOf(term);
                        return Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentGlossaryIndex == index
                                ? orangeTheme['primaryDark']
                                : orangeTheme['primaryLight']!.withOpacity(0.4),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
