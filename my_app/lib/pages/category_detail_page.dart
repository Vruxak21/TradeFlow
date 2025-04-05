import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/stock_service.dart';

class AppTheme {
  static const primary = Color(0xFFFF5722); // Deep Orange
  static const primaryLight = Color(0xFFFF7043); // Light Orange
  static const primaryDark = Color(0xFFE64A19); // Dark Orange
  static const accent = Color(0xFFFF9800); // Orange Accent
  static const background = Color(0xFFFFF3E0); // Soft Orange Background
  static const surface = Color(0xFFFFE0B2); // Light Surface Orange
  static const text = Color(0xFF5D4037); // Dark Brown for text
  static const textLight =
      Color(0xFF8D6E63); // Lighter Brown for secondary text
}

class CategoryDetailPage extends StatefulWidget {
  final String category;

  const CategoryDetailPage({Key? key, required this.category})
      : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final StockService _stockService = StockService();
  bool _isLoading = true;
  bool _isServerReachable = true;
  List<Stock> _stocks = [];
  String _sortOrder = 'A'; // Default to ascending
  String? _errorMessage;

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
      _errorMessage = null;
    });

    try {
      // Try to directly fetch stocks without separate health check
      List<Stock> stocks = await _stockService.getStocksByCategory(
        widget.category,
        order: _sortOrder,
      );

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        _stocks = stocks;
        _isLoading = false;
        _isServerReachable = true;
      });
    } catch (e) {
      // If direct fetch fails, try health check to determine cause
      if (!mounted) return;

      bool isHealthy = false;
      try {
        isHealthy = await _stockService.checkServerHealth();
      } catch (_) {
        // If health check also fails, server is definitely unreachable
        isHealthy = false;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isServerReachable = isHealthy;
        _errorMessage = isHealthy
            ? 'Could not fetch stock data. Please try again.'
            : 'Server not reachable. Make sure the Python server is running.';
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
  title: Text(
    "${widget.category} Stocks",
    style: const TextStyle(
      color: Colors.white, // Changed to white
      fontWeight: FontWeight.w600,
    ),
  ),
  backgroundColor: AppTheme.primary, // Changed to primary color
  elevation: 0.5,
  iconTheme: const IconThemeData(color: Colors.white), // Changed icons to white
  actions: [
    IconButton(
      icon: Icon(
        _sortOrder == 'A' ? Icons.sort : Icons.sort,
        color: Colors.white, // Changed to white
      ),
      onPressed: _toggleSortOrder,
      tooltip: _sortOrder == 'A'
          ? 'Sort price ascending'
          : 'Sort price descending',
    ),
    IconButton(
      icon: const Icon(
        Icons.refresh,
        color: Colors.white, // Changed to white
      ),
      onPressed: _loadStocks,
      tooltip: 'Refresh data',
    ),
    const SizedBox(width: 8),
  ],
),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              "Loading stocks...",
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isServerReachable || _errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_wifi_off_rounded,
                size: 72,
                color: AppTheme.textLight.withOpacity(0.7),
              ),
              const SizedBox(height: 24),
              Text(
                !_isServerReachable ? "Connection Error" : "Error",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? "Make sure the Python server is running",
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadStocks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: AppTheme.textLight.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              "No ${widget.category} stocks found",
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try a different category or check back later",
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadStocks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                "Refresh",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStocks,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stocks.length,
        itemBuilder: (context, index) {
          final stock = _stocks[index];
          return _buildStockCard(stock);
        },
      ),
    );
  }

  Widget _buildStockCard(Stock stock) {
    // Determine if price is positive or negative (for coloring)
    final bool isPositive =
        true; // This should be dynamic based on stock performance
    final Color priceColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with stock info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock header with name and ticker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primaryLight.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  stock.ticker,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "₹${stock.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: priceColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stock details section
                Row(
                  children: [
                    _buildInfoChip(
                      label: "Sector",
                      value: stock.sector,
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      label: "Industry",
                      value: stock.industry,
                      icon: Icons.business_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chart section
          if (stock.chart != null && stock.chart!.isNotEmpty)
            Container(
              width: double.infinity,
              height: 220, // Increased height for better visualization
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    AppTheme.background.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.memory(
                  base64Decode(stock.chart!),
                  fit: BoxFit
                      .contain, // Changed to contain for better chart visibility
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      {required String label, required String value, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.accent,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
