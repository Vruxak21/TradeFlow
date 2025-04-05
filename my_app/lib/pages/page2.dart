import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:TradeFlow/services/api_service.dart';
import 'package:TradeFlow/pages/results_page.dart';

class AppTheme {
  static const primary = Color(0xFFFF5722);       // Deep Orange
  static const primaryLight = Color(0xFFFF7043);  // Light Orange
  static const primaryDark = Color(0xFFE64A19);   // Dark Orange
  static const accent = Color(0xFFFF9800);        // Orange Accent
  static const background = Color(0xFFFFF3E0);    // Soft Orange Background
  static const surface = Color(0xFFFFE0B2);       // Light Surface Orange
  static const text = Color(0xFF5D4037);          // Dark Brown for text
  static const textLight = Color(0xFF8D6E63);     // Lighter Brown for secondary text
  static const cardLight = Colors.white;
}

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  // Controllers for text fields
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _horizonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Variables for MCQs
  String? _riskAppetite;
  String? _investmentGoal;
  String? _preferredSector;
  String? _marketCap;
  String? _highDividend;

  // Processing state
  bool _isProcessing = false;

  // Options for MCQs
  final List<String> _riskOptions = ['low', 'medium', 'high'];
  final List<String> _goalOptions = ['growth', 'dividends', 'both'];
  final List<String> _sectorOptions = ['IT', 'banking', 'healthcare', 'all'];
  final List<String> _marketCapOptions = ['large-cap', 'mid-cap', 'small-cap'];
  final List<String> _dividendOptions = ['yes', 'no'];
  
  // Current question index for the step-by-step UI
  int _currentStep = 0;
  
  // Total number of questions
  final int _totalSteps = 8;
  
  // Page controller for smooth transitions
  final PageController _pageController = PageController();

  // Function to move to the next question
  void _nextQuestion() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    } else {
      _submitForm();
    }
  }

  // Function to move to the previous question
  void _previousQuestion() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
      );
    }
  }

  // Check if current question is answered
  bool _isCurrentQuestionAnswered() {
    switch (_currentStep) {
      case 0:
        return _incomeController.text.isNotEmpty;
      case 1:
        return _horizonController.text.isNotEmpty;
      case 2:
        return _amountController.text.isNotEmpty;
      case 3:
        return _riskAppetite != null;
      case 4:
        return _investmentGoal != null;
      case 5:
        return _preferredSector != null;
      case 6:
        return _marketCap != null;
      case 7:
        return _highDividend != null;
      default:
        return false;
    }
  }

  // Get question title based on current step
  String _getQuestionTitle() {
    switch (_currentStep) {
      case 0:
        return "What is your annual income?";
      case 1:
        return "How long do you plan to invest?";
      case 2:
        return "How much would you like to invest?";
      case 3:
        return "What is your risk appetite?";
      case 4:
        return "What is your investment goal?";
      case 5:
        return "Which sector do you prefer?";
      case 6:
        return "What is your market cap preference?";
      case 7:
        return "Do you prefer high-dividend stocks?";
      default:
        return "";
    }
  }

  // Get question subtitle based on current step
  String _getQuestionSubtitle() {
    switch (_currentStep) {
      case 0:
        return "Enter your annual income in INR";
      case 1:
        return "Enter your investment horizon in years";
      case 2:
        return "Enter the amount you want to invest in INR";
      case 3:
        return "Select your comfort level with risk";
      case 4:
        return "Select what you hope to achieve";
      case 5:
        return "Select your preferred industry sector";
      case 6:
        return "Select your company size preference";
      case 7:
        return "Select if you prefer dividend-paying stocks";
      default:
        return "";
    }
  }

  // Get icon for each question
  IconData _getQuestionIcon() {
    switch (_currentStep) {
      case 0:
        return Icons.account_balance_wallet_outlined;
      case 1:
        return Icons.timeline_outlined;
      case 2:
        return Icons.savings_outlined;
      case 3:
        return Icons.speed_outlined;
      case 4:
        return Icons.trending_up_outlined;
      case 5:
        return Icons.category_outlined;
      case 6:
        return Icons.business_outlined;
      case 7:
        return Icons.paid_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // Builds a modern text field for inputs
  Widget _buildModernTextField(TextEditingController controller, String hint, {String? suffix}) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      from: 30,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textLight.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  // Builds modern option buttons for MCQs
  Widget _buildModernOptions(List<String> options, String? groupValue, ValueChanged<String?> onChanged) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      from: 30,
      child: Column(
        children: options.map((option) {
          final bool isSelected = option == groupValue;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? AppTheme.primary.withOpacity(0.3) 
                        : Colors.black.withOpacity(0.03),
                    blurRadius: isSelected ? 10 : 8,
                    spreadRadius: isSelected ? 0 : 1,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    option.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isSelected ? Colors.white : AppTheme.text,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.check_rounded : Icons.circle_outlined,
                      color: isSelected ? Colors.white : AppTheme.textLight,
                      size: isSelected ? 20 : 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Validates form data and submits it to the backend
  void _submitForm() async {
    if (_riskAppetite != null &&
        _investmentGoal != null &&
        _preferredSector != null &&
        _marketCap != null &&
        _highDividend != null &&
        _incomeController.text.isNotEmpty &&
        _horizonController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      
      // Prepare form data
      Map<String, dynamic> formData = {
        "riskAppetite": _riskAppetite,
        "annualIncome": _incomeController.text,
        "investmentHorizon": _horizonController.text,
        "investmentGoal": _investmentGoal,
        "preferredSector": _preferredSector,
        "marketCap": _marketCap,
        "highDividend": _highDividend,
        "investmentAmount": _amountController.text,
      };
      
      // Set processing state
      setState(() {
        _isProcessing = true;
      });
      
      try {
        // Call API
        final result = await ApiService.getRecommendations(formData);
        
        // Reset processing state
        setState(() {
          _isProcessing = false;
        });
        
        if (result['status'] == 'success') {
          // Navigate to results page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                recommendations: result['recommendations'],
                userInput: formData,
              ),
            ),
          );
        } else {
          // Show error
          _showErrorSnackBar(result['message'] ?? 'Failed to get recommendations');
        }
      } catch (e) {
        // Reset processing state and show error
        setState(() {
          _isProcessing = false;
        });
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } else {
      _showErrorSnackBar('Please fill in all fields');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      backgroundColor: Colors.redAccent.shade700,
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _horizonController.dispose();
    _amountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.primary),
                onPressed: _previousQuestion,
              )
            : null,
        title: _buildProgressBar(),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Income question
              _buildQuestionPage(
                _buildModernTextField(_incomeController, "Enter amount", suffix: "INR"),
              ),
              
              // Investment horizon question
              _buildQuestionPage(
                _buildModernTextField(_horizonController, "Enter years", suffix: "years"),
              ),
              
              // Investment amount question
              _buildQuestionPage(
                _buildModernTextField(_amountController, "Enter amount", suffix: "INR"),
              ),
              
              // Risk appetite question
              _buildQuestionPage(
                _buildModernOptions(_riskOptions, _riskAppetite, (value) {
                  setState(() {
                    _riskAppetite = value;
                  });
                }),
              ),
              
              // Investment goal question
              _buildQuestionPage(
                _buildModernOptions(_goalOptions, _investmentGoal, (value) {
                  setState(() {
                    _investmentGoal = value;
                  });
                }),
              ),
              
              // Preferred sector question
              _buildQuestionPage(
                _buildModernOptions(_sectorOptions, _preferredSector, (value) {
                  setState(() {
                    _preferredSector = value;
                  });
                }),
              ),
              
              // Market cap question
              _buildQuestionPage(
                _buildModernOptions(_marketCapOptions, _marketCap, (value) {
                  setState(() {
                    _marketCap = value;
                  });
                }),
              ),
              
              // High dividend question
              _buildQuestionPage(
                _buildModernOptions(_dividendOptions, _highDividend, (value) {
                  setState(() {
                    _highDividend = value;
                  });
                }),
              ),
            ],
          ),
          
          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Processing your request...",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor: AppTheme.textLight.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              shadowColor: AppTheme.primary.withOpacity(0.5),
            ),
            onPressed: _isCurrentQuestionAnswered() ? _nextQuestion : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep == _totalSteps - 1 ? "Get Recommendations" : "Continue",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentStep == _totalSteps - 1 ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the progress bar at the top
  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Question ${(_currentStep + 1)} of $_totalSteps",
              style: const TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${((_currentStep + 1) / _totalSteps * 100).toInt()}% Complete",
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey.shade200,
            color: AppTheme.primary,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // Build a question page with consistent layout
  Widget _buildQuestionPage(Widget inputWidget) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getQuestionIcon(),
                size: 30,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            from: 20,
            child: Text(
              _getQuestionTitle(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            from: 30,
            child: Text(
              _getQuestionSubtitle(),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          inputWidget,
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}