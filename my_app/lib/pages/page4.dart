import 'package:flutter/material.dart';
import 'category_detail_page.dart';

class AppTheme {
  static const primary = Color(0xFFE65100);
  static const secondary = Color(0xFFEF6C00);
  static const accent = Color(0xFFFFA726); // Light orange color for icons and text
  static final background = Colors.grey.shade50;
  static const cardLight = Colors.white;
  static final cardDark = Colors.orange.shade800;
  static const borderColor = Color(0xFFE65100); // Constant border color
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // Styled heading
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: const Text(
                "Select your Category of Stocks Wisely",
                style: TextStyle(
                  fontSize: 28, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Gradient will override this
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            _buildCategoryCard(
              context,
              "Technology",
              Icons.computer,
            ),
            const SizedBox(height: 20),
            _buildCategoryCard(
              context,
              "Defence",
              Icons.security,
            ),
            const SizedBox(height: 20),
            _buildCategoryCard(
              context,
              "Environment",
              Icons.eco,
            ),
          ],
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
        // Navigate to the updated CategoryDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(category: title),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: AppTheme.borderColor, // Use the constant border color
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.secondary, // Use the light orange color for icons
              size: 30.0,
            ),
            const SizedBox(width: 15.0),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.secondary, // Use the light orange color for text
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.accent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}