import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // Factory constructor to parse JSON data
  factory StockData.fromJson(String symbol, Map<String, dynamic> json) {
    final quote = json['meta']['regularMarketPrice'];
    final previousClose = json['meta']['previousClose'];
    final changePercent = ((quote - previousClose) / previousClose) * 100;

    return StockData(
      symbol: symbol,
      name: symbol.split('.')[0], // Extract name from symbol
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

  @override
  void initState() {
    super.initState();
    _fetchDefaultStocks();
  }

  Future<void> _fetchDefaultStocks() async {
    setState(() => _isLoading = true);

    // Popular Indian stocks
    final defaultStocks = [
      'RELIANCE.NS',   // Reliance Industries
      'TCS.NS',        // Tata Consultancy Services
      'HDFCBANK.NS',   // HDFC Bank
      'INFY.NS',       // Infosys
      'ICICIBANK.NS'   // ICICI Bank
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
      // Append .NS for NSE stocks
      final symbol = '${query.toUpperCase()}.NS';
      final stockData = await _fetchStockData(symbol);

      if (mounted) {
        setState(() {
          _stockResults = stockData != null ? [stockData] : [];
          _isLoading = false;
        });

        // Only show "Stock not found" if the search was not empty and no stock was found
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
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search NSE Stocks (e.g., TCS, RELIANCE)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchDefaultStocks();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: _searchStocks,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stockResults.isEmpty
                    ? const Center(child: Text('No stocks found'))
                    : ListView.builder(
                        itemCount: _stockResults.length,
                        itemBuilder: (context, index) {
                          final stock = _stockResults[index];
                          return ListTile(
                            title: Text(
                              stock.symbol,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(stock.name),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${stock.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: stock.isPositive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${stock.changePercent.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: stock.isPositive ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}