import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use port 5001 for recommendations
  static const String baseUrl = 'http://10.0.2.2:5001';
  
  /// Sends investment form data to the API to get stock recommendations
  static Future<Map<String, dynamic>> getRecommendations(Map<String, dynamic> formData) async {
    try {
      // Convert form data to the format expected by API
      Map<String, dynamic> apiData = {
        "risk_appetite": formData["riskAppetite"],
        "investment_horizon": int.parse(formData["investmentHorizon"]),
        "investment_goal": formData["investmentGoal"],
        "sector_preference": formData["preferredSector"],
        "market_cap_preference": formData["marketCap"],
        "dividend_preference": formData["highDividend"],
        "investment_amount": double.parse(formData["investmentAmount"])
      };
      
      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(apiData),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get recommendations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}