import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AppTheme {
  // Modern slate blue theme
  static const primary = Color(0xFF3B82F6);     // Vibrant blue
  static const accent = Color(0xFF6366F1);      // Indigo accent
  static final background = Color(0xFFF9FAFB);  // Light gray bg
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1F2937);    // Dark slate
  static const success = Color(0xFF10B981);     // Emerald green
  static const error = Color(0xFFEF4444);       // Red
  static const neutral = Color(0xFF64748B);     // Slate
  static const divider = Color(0xFFE5E7EB);     // Light gray for dividers
  
  // Typography system with improved readability
  static const TextStyle displayLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1F2937),  // Dark slate
    letterSpacing: -0.5,
    height: 1.3,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),  // Dark slate
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),  // Dark slate
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1F2937),  // Dark slate
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF64748B),  // Slate for secondary text
    height: 1.5,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),  // Slate for secondary text
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF94A3B8),  // Lighter slate for small labels
    height: 1.4,
    letterSpacing: 0.2,
  );
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: const Text(
          'Recommendations',
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 18,
            letterSpacing: -0.3
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
            tooltip: 'Filter results',
          ),
        ],
      ),
      body: recommendations.isEmpty 
        ? _buildNoResultsView(context) 
        : SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(context),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FadeIn(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Recommended Stocks',
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    recommendations.length,
                    (index) => FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      duration: const Duration(milliseconds: 400),
                      from: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 6
                        ),
                        child: _buildStockCard(recommendations[index], index, context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _buildOutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      label: "Adjust Preferences",
                      icon: Icons.arrow_back_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildNoResultsView(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 700),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Matching Stocks",
                style: AppTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Try adjusting your investment preferences to find recommendations that match your criteria.",
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              _buildPrimaryButton(
                onPressed: () => Navigator.pop(context),
                label: "Modify Preferences",
                icon: Icons.tune_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Investment Profile',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppTheme.neutral,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit profile',
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Risk profile indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _getRiskColor(userInput['riskAppetite']).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: _getRiskColor(userInput['riskAppetite']),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Risk Appetite: ${_capitalizeFirst(userInput['riskAppetite'])}',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getRiskColor(userInput['riskAppetite']),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Profile details in two columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileDetail(
                        Icons.calendar_today_rounded, 
                        '${userInput['investmentHorizon']} years',
                        'Time Horizon',
                      ),
                      const SizedBox(height: 16),
                      _buildProfileDetail(
                        Icons.flag_outlined, 
                        _capitalizeFirst(userInput['investmentGoal']),
                        'Goal',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileDetail(
                        Icons.account_balance_wallet_outlined, 
                        '₹${userInput['investmentAmount']}',
                        'Amount',
                      ),
                      const SizedBox(height: 16),
                      _buildProfileDetail(
                        Icons.category_outlined, 
                        userInput['preferredSector'] == 'all' 
                          ? 'All Sectors' 
                          : _capitalizeFirst(userInput['preferredSector']),
                        'Sector',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRiskColor(String riskLevel) {
    switch(riskLevel.toLowerCase()) {
      case 'high':
        return AppTheme.error;
      case 'moderate':
        return AppTheme.accent;
      case 'low':
        return AppTheme.success;
      default:
        return AppTheme.neutral;
    }
  }

  Widget _buildProfileDetail(IconData icon, String value, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            size: 16, 
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTheme.labelSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],  
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock, int index, BuildContext context) {
    // Parse strategy tags
    final List<String> strategies = stock['strategy'].toString().split(' | ');
    final bool isUp = stock['change_percent'] >= 0;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            splashColor: AppTheme.primary.withOpacity(0.1),
            highlightColor: AppTheme.primary.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stock['symbol'],
                                  style: AppTheme.titleLarge,
                                ),
                                const SizedBox(width: 12),
                                _buildChangeIndicator(stock['change_percent']),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stock['sector'] ?? 'Unknown Sector',
                              style: AppTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${stock['price'].toStringAsFixed(2)}',
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          // Add a buy indicator tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: stock['price'] <= stock['buy_target'] 
                                ? AppTheme.success.withOpacity(0.1)
                                : AppTheme.neutral.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stock['price'] <= stock['buy_target'] ? 'BUY NOW' : 'WATCH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: stock['price'] <= stock['buy_target'] 
                                  ? AppTheme.success
                                  : AppTheme.neutral,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1, thickness: 1, color: AppTheme.divider),
                
                // Stock metrics and targets
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern price slider
                      _buildPriceSlider(
                        stock['stop_loss'],
                        stock['price'],
                        stock['buy_target'],
                        stock['sell_target'],
                        isUp,
                        context,
                      ),
                      const SizedBox(height: 16),
                      
                      // Price targets in a simplified row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTargetItem(
                            'Stop Loss',
                            '₹${stock['stop_loss'].toStringAsFixed(2)}',
                            AppTheme.error,
                          ),
                          _buildTargetItem(
                            'Buy Below',
                            '₹${stock['buy_target'].toStringAsFixed(2)}',
                            AppTheme.success,
                          ),
                          _buildTargetItem(
                            'Sell at',
                            '₹${stock['sell_target'].toStringAsFixed(2)}',
                            AppTheme.accent,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      const Divider(height: 1, thickness: 1, color: AppTheme.divider),
                      const SizedBox(height: 20),
                      
                      // Key metrics in a cleaner layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem('Beta', stock['beta'].toStringAsFixed(2)),
                          _buildVerticalDivider(),
                          _buildMetricItem('Dividend', '${(stock['dividend_yield'] * 100).toStringAsFixed(2)}%'),
                          _buildVerticalDivider(),
                          _buildMetricItem('Market Cap', _formatMarketCap(stock['market_cap'])),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Strategy tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: strategies.map((strategy) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            strategy,
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        )).toList(),
                      ),
                    ],  
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppTheme.divider,
    );
  }

  Widget _buildChangeIndicator(double changePercent) {
    final isPositive = changePercent >= 0;
    final color = isPositive ? AppTheme.success : AppTheme.error;
    final text = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceSlider(
    double stopLoss, 
    double currentPrice, 
    double buyTarget, 
    double sellTarget,
    bool isUp,
    BuildContext context,
  ) {
    final min = (stopLoss * 0.95).floorToDouble();
    final max = (sellTarget * 1.05).ceilToDouble();
    final range = max - min;
    
    // Calculate positions as percentages
    final stopLossPos = ((stopLoss - min) / range * 100).clamp(0.0, 100.0);
    final currentPos = ((currentPrice - min) / range * 100).clamp(0.0, 100.0);
    final buyPos = ((buyTarget - min) / range * 100).clamp(0.0, 100.0);
    final sellPos = ((sellTarget - min) / range * 100).clamp(0.0, 100.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price info header
        Row(
          children: [
            const Text(
              'Current',
              style: AppTheme.labelSmall,
            ),
            const SizedBox(width: 4),
            Text(
              '₹${currentPrice.toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.cardDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Modern slider with gradient background
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                AppTheme.error.withOpacity(0.5),
                AppTheme.success.withOpacity(0.5),
                AppTheme.accent.withOpacity(0.5),
              ],
              stops: [
                stopLossPos / 100,
                buyPos / 100,
                sellPos / 100,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Current price dot
              Positioned(
                left: currentPos * 0.01 * MediaQuery.of(context).size.width * 0.85,
                top: -3,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isUp ? AppTheme.success : AppTheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.labelSmall,
        ),
      ],
    );
  }
  
  Widget _buildTargetItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
  
  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
  
  String _formatMarketCap(num marketCap) {
    if (marketCap >= 1000000000000) {
      return '${(marketCap / 1000000000000).toStringAsFixed(1)}T';
    } else if (marketCap >= 1000000000) {
      return '${(marketCap / 1000000000).toStringAsFixed(1)}B';
    } else if (marketCap >= 1000000) {
      return '${(marketCap / 1000000).toStringAsFixed(1)}M';
    } else if (marketCap >= 1000) {
      return '${(marketCap / 1000).toStringAsFixed(1)}K';
    } else {
      return marketCap.toString();
    }
  }
  
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}