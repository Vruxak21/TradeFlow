import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:TradeFlow/services/api_service.dart';
import 'package:TradeFlow/pages/results_page.dart';

class AppTheme {
  static const primary = Color(0xFFE65100);
  static const accent = Color(0xFFFFA726);
  static final background = Colors.orange.shade50;
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

  /// Builds an animated card for MCQ inputs.
  Widget _buildMCQCard(
      String title, List<String> options, String? groupValue, ValueChanged<String?> onChanged) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Card(
        color: AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  )),
              Divider(color: AppTheme.accent),
              ...options.map((option) => RadioListTile<String>(
                    title: Text(option, style: const TextStyle(color: Colors.black87)),
                    value: option,
                    groupValue: groupValue,
                    activeColor: AppTheme.primary,
                    onChanged: onChanged,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an animated card for text field inputs.
  Widget _buildTextFieldCard(String label, TextEditingController controller) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Card(
        color: AppTheme.cardLight,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
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
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ));
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _horizonController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                // Text fields for numeric inputs
                _buildTextFieldCard("Enter your annual income (in INR)", _incomeController),
                _buildTextFieldCard("Enter your investment horizon (years)", _horizonController),
                _buildTextFieldCard("Enter the amount you want to invest (in INR)", _amountController),
                
                // MCQs for options
                _buildMCQCard("Enter your risk appetite:", _riskOptions, _riskAppetite, (value) {
                  setState(() {
                    _riskAppetite = value;
                  });
                }),
                _buildMCQCard("Enter your investment goal:", _goalOptions, _investmentGoal, (value) {
                  setState(() {
                    _investmentGoal = value;
                  });
                }),
                _buildMCQCard("Enter your preferred sector:", _sectorOptions, _preferredSector, (value) {
                  setState(() {
                    _preferredSector = value;
                  });
                }),
                _buildMCQCard("Enter your market cap preference:", _marketCapOptions, _marketCap, (value) {
                  setState(() {
                    _marketCap = value;
                  });
                }),
                _buildMCQCard("Do you prefer high-dividend stocks?", _dividendOptions, _highDividend, (value) {
                  setState(() {
                    _highDividend = value;
                  });
                }),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isProcessing ? null : _submitForm,
                  child: const Text("Get Recommendations", style: TextStyle(color: Colors.white)),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}