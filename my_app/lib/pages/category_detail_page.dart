import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/stock_service.dart';

class CategoryDetailPage extends StatefulWidget {
  final String category;
  
  const CategoryDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final StockService _stockService = StockService();
  bool _isLoading = true;
  bool _isServerReachable = true;
  List<Stock> _stocks = [];
  String _sortOrder = 'A'; // Default to ascending

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    // Check if widget is still mounted before updating state
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if server is reachable
      bool isHealthy = await _stockService.checkServerHealth();
      
      // Check if widget is still mounted before updating state
      if (!mounted) return;
      
      if (!isHealthy) {
        setState(() {
          _isServerReachable = false;
          _isLoading = false;
        });
        return;
      }
      
      // Fetch stocks for the selected category
      List<Stock> stocks = await _stockService.getStocksByCategory(
        widget.category,
        order: _sortOrder,
      );
      
      // Check if widget is still mounted before updating state
      if (!mounted) return;
      
      setState(() {
        _stocks = stocks;
        _isLoading = false;
      });
    } catch (e) {
      // Check if widget is still mounted before updating state
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isServerReachable = false;
      });
      print('Error: $e');
    }
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == 'A' ? 'D' : 'A';
    });
    _loadStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("${widget.category} Stocks"),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: Icon(_sortOrder == 'A' 
                ? Icons.arrow_upward 
                : Icons.arrow_downward),
            onPressed: _toggleSortOrder,
            tooltip: _sortOrder == 'A' 
                ? 'Sort price ascending' 
                : 'Sort price descending',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_isServerReachable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "Server not reachable",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Make sure the Python server is running",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadStocks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_stocks.isEmpty) {
      return Center(
        child: Text(
          "No ${widget.category} stocks found",
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stocks.length,
      itemBuilder: (context, index) {
        final stock = _stocks[index];
        return _buildStockCard(stock);
      },
    );
  }

  Widget _buildStockCard(Stock stock) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stock.ticker,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current Price",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "₹${stock.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Sector: ${stock.sector}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "Industry: ${stock.industry}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (stock.chart != null && stock.chart!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Image.memory(
                  base64Decode(stock.chart!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// AppTheme class copied from your original code
class AppTheme {
  static const primary = Color(0xFFE65100);
  static const secondary = Color(0xFFEF6C00);
  static const accent = Color(0xFFFFA726);
  static final background = Colors.grey.shade50;
  static const cardLight = Colors.white;
  static final cardDark = Colors.orange.shade800;
  static const borderColor = Color(0xFFE65100);
}