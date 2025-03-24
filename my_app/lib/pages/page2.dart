import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AppTheme {
  static const primary = Color(0xFFE65100);
  static const accent = Color(0xFFFFA726);
  static final background = Colors.orange.shade50;
  static const cardLight = Colors.white;
}

void main() {
  runApp(MaterialApp(
    title: "Investment Form",
    theme: ThemeData(
      primaryColor: AppTheme.primary,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange)
          .copyWith(secondary: AppTheme.accent),
      scaffoldBackgroundColor: AppTheme.background,
    ),
    home: const Page2(),
  ));
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

  /// Collects all form data and prints it (or sends it to your backend).
  void _submitForm() {
    if (_riskAppetite != null &&
        _investmentGoal != null &&
        _preferredSector != null &&
        _marketCap != null &&
        _highDividend != null &&
        _incomeController.text.isNotEmpty &&
        _horizonController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
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
      print("Form Data: $formData");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Data submitted successfully!"),
        backgroundColor: AppTheme.primary,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Please fill in all fields."),
        backgroundColor: Colors.redAccent,
      ));
    }
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
      // No AppBar as per your request.
      body: SingleChildScrollView(
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
              onPressed: _submitForm,
              child: const Text("Submit",style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}