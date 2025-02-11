import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = "AIzaSyCT0EJjWwCmUiikcNuFLzC-IKqyvtFObzg";
const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    String userMessage = _controller.text;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _messages.add({"sender": "bot", "text": "..."}); // Show only dots while loading
    });

    _controller.clear();

    String botResponse = await _fetchGeminiResponse(userMessage);

    setState(() {
      _messages.removeLast(); // Remove loading message
      if (botResponse.isNotEmpty) {
        _messages.add({"sender": "bot", "text": botResponse});
      }
    });
  }

  Future<String> _fetchGeminiResponse(String query) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "If the query is related to investment, stocks, or finance, answer properly. Otherwise, return exactly 'IGNORE'. Query: $query"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['candidates'] != null &&
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          String rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];

          if (rawText.trim() == "IGNORE") {
            return ""; // Ignore non-financial queries
          }

          return _formatResponse(rawText);
        } else {
          return "";
        }
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  String _formatResponse(String text) {
    text = text.replaceAll("**", ""); // Remove bold markers
    text = text.replaceAll("* ", "• "); // Convert lists to bullet points
    text = text.replaceAll("*", "• "); // Handle cases where * is not followed by a space

    return text
        .split("\n")
        .map((line) => line.trim().isNotEmpty ? line.trim() : "\n")
        .join("\n"); // Ensure proper spacing and formatting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Chatbot"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about stocks, investments...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
