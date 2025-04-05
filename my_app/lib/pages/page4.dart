import 'package:flutter/material.dart';
import 'category_detail_page.dart';

class AppTheme {
  static const primary = Color(0xFFFF5722);       // Deep Orange
  static const primaryLight = Color(0xFFFF7043);  // Light Orange
  static const primaryDark = Color(0xFFE64A19);   // Dark Orange
  static const accent = Color(0xFFFF9800);        // Orange Accent
  static const background = Color(0xFFFFF3E0);    // Soft Orange Background
  static const surface = Color(0xFFFFE0B2);       // Light Surface Orange
  static const text = Color(0xFF5D4037);          // Dark Brown for text
  static const textLight = Color(0xFF8D6E63);     // Lighter Brown for secondary text
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Choose Category",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select the stock category you're interested in",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCategoryCard(
                      context,
                      "Technology",
                      Icons.computer_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context,
                      "Defence",
                      Icons.security_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context,
                      "Environment",
                      Icons.eco_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context,
                      "Healthcare",
                      Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context,
                      "Finance",
                      Icons.account_balance_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(category: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.accent,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}