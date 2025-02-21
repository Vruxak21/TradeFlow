import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/pages/page1.dart';
import 'package:my_app/pages/page2.dart';
import 'package:my_app/pages/page3.dart';
import 'package:my_app/pages/page4.dart';
import 'package:animate_do/animate_do.dart';
import 'package:my_app/login_page.dart'; // Import the LoginPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    // Check if the widget is still mounted before navigating
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            onTap: () {
              // Define the onTap logic for LoginPage
              // For example, you can navigate back to the HomePage or perform other actions
            },
          ),
        ),
      );
    }
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Services",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    FadeInRight(
                      duration: const Duration(milliseconds: 1000),
                      child: IconButton(
                        onPressed: () => signUserOut(), // Updated to use the class method without context
                        icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              FadeInUp(
                                duration: const Duration(milliseconds: 1200),
                                child: buildOptionContainer(
                                  context,
                                  "Financial Chatbot",
                                  Page1(),
                                  Icons.smart_toy,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1400),
                                child: buildOptionContainer(
                                  context,
                                  "AI Investment Picks",
                                  const Page2(),
                                  Icons.auto_graph,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1600),
                                child: buildOptionContainer(
                                  context,
                                  "Market Trends & Insights",
                                  const Page3(),
                                  Icons.trending_up,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInUp(
                                duration: const Duration(milliseconds: 1800),
                                child: buildOptionContainer(
                                  context,
                                  "Coming Soon...",
                                  const Page4(),
                                  Icons.more_horiz,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.orange.shade900,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.orange.shade900,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}