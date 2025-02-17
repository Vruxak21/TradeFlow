import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'dart:convert';

const String apiKey = "AIzaSyCT0EJjWwCmUiikcNuFLzC-IKqyvtFObzg";
const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

class AppTheme {
  static const primary = Color(0xFFE65100);
  static const secondary = Color(0xFFEF6C00);
  static const accent = Color(0xFFFFA726);
  static final background = Colors.grey.shade50;
  static const cardLight = Colors.white;
  static final cardDark = Colors.orange.shade800;
}

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String _lastFinancialTopic = "";

  final Map<String, String> _greetings = {
    'hi': 'Hey! How can I help you with your financial questions today?',
    'hello': 'Hello! I\'m here to assist you with financial and investment related queries.',
    'hey': 'Hi there! Need help with stocks or investments?',
    'good morning': 'Good morning! Ready to discuss your financial queries?',
    'good afternoon': 'Good afternoon! How can I assist you with financial matters?',
    'good evening': 'Good evening! Let me help you with your financial questions.',
  };

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _isLoading) return;
    String userMessage = _controller.text.toLowerCase().trim();

    setState(() {
      _messages.add({"sender": "user", "text": _controller.text});
      _messages.add({"sender": "bot", "text": "typing..."}); // Changed to "typing..."
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      String botResponse = await _handleMessage(userMessage);
      setState(() {
        _messages.removeLast();
        _messages.add({
          "sender": "bot",
          "text": botResponse,
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _handleMessage(String message) async {
    // Check for greetings
    for (var greeting in _greetings.keys) {
      if (message.contains(greeting)) {
        return _greetings[greeting]!;
      }
    }

    // Check for farewells
    if (message.contains('bye') || 
        message.contains('goodbye') || 
        message.contains('thank you')) {
      return "Goodbye! Feel free to return if you have more financial questions!";
    }

    // Check for "explain in detail" type requests
    bool isDetailRequest = message.contains('explain in detail') || 
                         message.contains('tell me more') || 
                         message.contains('elaborate') ||
                         message.contains('can you explain') ||
                         message.contains('what does this mean');

    if (isDetailRequest && _lastFinancialTopic.isNotEmpty) {
      return await _fetchGeminiResponse(
        "Explain in detail about $_lastFinancialTopic. Provide comprehensive information including examples and key points.",
        detailed: true
      );
    }

    // Regular message handling
    String response = await _fetchGeminiResponse(message);
    if (response.isNotEmpty) {
      _lastFinancialTopic = message; // Store the topic for potential follow-up
    }
    return response;
  }

  Future<String> _fetchGeminiResponse(String query, {bool detailed = false}) async {
    try {
      String prompt = detailed
          ? """
          Provide a detailed explanation with examples about this financial topic: $query
          Include:
          - Clear explanations
          - Practical examples
          - Key points to remember
          - Relevant financial terms
          Make it educational but easy to understand.
          """
          : """
          If the query is related to investment, stocks, or finance, provide a clear and concise answer.
          If it's a request for more details about a previous topic, provide comprehensive information.
          Otherwise, return exactly 'IGNORE'.
          Make the response conversational but informative.
          Query: $query
          """;

      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [{
            "parts": [{
              "text": prompt
            }]
          }],
          "generationConfig": {
            "temperature": detailed ? 0.7 : 0.3,
            "maxOutputTokens": detailed ? 800 : 400,
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates']?[0]['content']['parts']?[0]['text'] ?? '';
        
        if (text.trim() == "IGNORE") {
          return "I can only help with financial topics. Please ask about investments, stocks, or other finance-related questions.";
        }
        
        return _formatResponse(text);
      }
      return "I'm having trouble connecting right now. Please try again.";
    } catch (e) {
      return "Sorry, I encountered an error. Please try again.";
    }
  }

  String _formatResponse(String text) {
    return text
        .replaceAll("**", "")
        .replaceAll(RegExp(r'\*+'), '• ')
        .split("\n")
        .map((line) => line.trim())
        .join("\n");
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey.shade100,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    const Text(
                      "Financial Chatbot",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message["sender"] == "user";
                  final isTyping = message["text"] == "typing...";

                  return FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? AppTheme.secondary : AppTheme.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: isTyping
                            ? const SizedBox(
                                width: 60,
                                child: TypingIndicator(),
                              )
                            : Text(
                                message["text"]!,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask about stocks, investments...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        filled: true,
                        fillColor: AppTheme.background,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Bounce(
          from: 2,
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: index * 200),
          infinite: true,
          child: Container(
            width: 8,
            height: 25,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}