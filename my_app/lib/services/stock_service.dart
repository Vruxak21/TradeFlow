import 'dart:convert';
import 'package:http/http.dart' as http;

class Stock {
  final String ticker;
  final String name;
  final double price;
  final String sector;
  final String industry;
  final String? chart;

  Stock({
    required this.ticker,
    required this.name,
    required this.price,
    required this.sector,
    required this.industry,
    this.chart,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      ticker: json['ticker'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      sector: json['sector'] ?? 'Unknown',
      industry: json['industry'] ?? 'Unknown',
      chart: json['chart'],
    );
  }
}

class StockService {
  // Use port 5000 for stock data
  static const String baseUrl = 'http://10.0.2.2:5000';
  
  // Configure timeouts and retries
  static const int _connectionTimeout = 10; // seconds
  static const int _maxRetries = 3;

  Future<bool> checkServerHealth() async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/health'),
        ).timeout(
          Duration(seconds: _connectionTimeout),
          onTimeout: () => http.Response('{"error":"Timeout"}', 408),
        );
        
        if (response.statusCode == 200) {
          return true;
        }
        
        // Short delay before retry
        if (attempt < _maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      } catch (e) {
        // Only return false after all retries fail
        if (attempt >= _maxRetries - 1) {
          return false;
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    
    return false;
  }

  Future<List<Stock>> getStocksByCategory(String category, {String order = 'A'}) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/stocks/$category?order=$order'),
        ).timeout(
          Duration(seconds: _connectionTimeout),
          onTimeout: () => http.Response('{"error":"Timeout"}', 408),
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonList = jsonDecode(response.body);
          return jsonList.map((json) => Stock.fromJson(json)).toList();
        } else {
          // Short delay before retry
          if (attempt < _maxRetries - 1) {
            await Future.delayed(Duration(milliseconds: 500));
            continue;
          }
          throw Exception('Failed to load stocks: ${response.statusCode}');
        }
      } catch (e) {
        // Only throw after all retries fail
        if (attempt >= _maxRetries - 1) {
          throw Exception('Error fetching stocks: $e');
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    
    // This should never be reached due to the exception in the last iteration
    throw Exception('Failed to load stocks after retries');
  }
}