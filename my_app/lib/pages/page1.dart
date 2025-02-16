import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import
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

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _isLoading) return;
    String userMessage = _controller.text;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _messages.add({"sender": "bot", "text": "..."});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      String botResponse = await _fetchGeminiResponse(userMessage);
      setState(() {
        _messages.removeLast();
        _messages.add({
          "sender": "bot",
          "text": botResponse.isNotEmpty
              ? botResponse
              : "Sorry, I can only answer financial questions. Please ask about investments, stocks, or finance."
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
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

  Future<String> _fetchGeminiResponse(String query) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [{
            "parts": [{
              "text": "If the query is related to investment, stocks, or finance, answer properly. Otherwise, return exactly 'IGNORE'. Query: $query"
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates']?[0]['content']['parts']?[0]['text'] ?? '';
        return text.trim() == "IGNORE" ? "" : _formatResponse(text);
      }
      return "";
    } catch (e) {
      return "";
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppTheme.primary,  // Match header color
        statusBarIconBrightness: Brightness.light,  // White status bar icons
        systemNavigationBarColor: Colors.grey.shade100,  // Light nav background
        systemNavigationBarIconBrightness: Brightness.dark,  // Dark nav icons
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
                    // Back arrow icon
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      ),
                    ),
                    // Centered heading
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
                        child: Text(
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