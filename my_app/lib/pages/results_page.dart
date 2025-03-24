import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AppTheme {
  static const primary = Color(0xFFE65100);
  static const accent = Color(0xFFFFA726);
  static final background = Colors.orange.shade50;
  static const cardLight = Colors.white;
}

class ResultsPage extends StatelessWidget {
  final List<dynamic> recommendations;
  final Map<String, dynamic> userInput;

  const ResultsPage({
    Key? key, 
    required this.recommendations, 
    required this.userInput
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stock Recommendations'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 16),
            Text(
              'Recommended Stocks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.map((stock) => _buildStockCard(stock)).toList(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Form", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Card(
        color: AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Investment Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              Divider(color: AppTheme.accent),
              _buildProfileItem('Risk Appetite', userInput['riskAppetite']),
              _buildProfileItem('Investment Horizon', '${userInput['investmentHorizon']} years'),
              _buildProfileItem('Investment Goal', userInput['investmentGoal']),
              _buildProfileItem('Investment Amount', '₹${userInput['investmentAmount']}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(dynamic stock) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Card(
        color: AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stock['symbol'].toString().replaceAll('.NS', ''),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    '₹${stock['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sector: ${stock['sector']}'),
                  Text('Beta: ${stock['beta'].toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Market Cap: ₹${(stock['market_cap'] / 10000000).toStringAsFixed(2)} Cr',
                  ),
                  Text(
                    'Dividend: ${(stock['dividend_yield'] * 100).toStringAsFixed(2)}%',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}