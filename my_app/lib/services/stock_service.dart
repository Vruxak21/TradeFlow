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

  Future<List<Stock>> getStocksByCategory(String category, {String order = 'A'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stocks/$category?order=$order'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Stock.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stocks: $e');
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}