import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/pages/page1.dart';
import 'package:my_app/pages/page2.dart';
import 'package:my_app/pages/page3.dart';
import 'package:my_app/pages/page4.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Professional light theme
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 3,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout, color: Colors.black87),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildOptionContainer(context, "Financial Chatbot",
                 Page1(), Icons.smart_toy),
            const SizedBox(height: 20),
            buildOptionContainer(context, "AI Investment Picks", const Page2(),
                Icons.auto_graph),
            const SizedBox(height: 20),
            buildOptionContainer(context, "Market Trends & Insights",
                const Page3(), Icons.trending_up),
            const SizedBox(height: 20),
            buildOptionContainer(
                context, "Coming Soon...", const Page4(), Icons.more_horiz),
          ],
        ),
      ),
    );
  }

  Widget buildOptionContainer(
      BuildContext context, String title, Widget page, IconData icon) {
    return GestureDetector(
      onTap: () => navigateToPage(context, page),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[800], size: 30),
            const SizedBox(width: 15),
            Expanded(
              // Added Expanded here
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis, // Prevents overflow
                maxLines: 1, // Ensures text remains in a single line
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
