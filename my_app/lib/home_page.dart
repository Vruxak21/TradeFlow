import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:TradeFlow/pages/page1.dart';
import 'package:TradeFlow/pages/page2.dart';
import 'package:TradeFlow/pages/page3.dart';
import 'package:TradeFlow/pages/page4.dart';
import 'package:TradeFlow/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  // List of pages to display
  final List<Widget> _pages = [
    Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];
  
  // Titles for each page
  final List<String> _titles = [
    "Financial Chatbot",
    "AI Investment Picks",
    "Market Trends & Insights",
    "Coming Soon..."
  ];
  
  // Icons for each page
  final List<IconData> _icons = [
    Icons.smart_toy,
    Icons.auto_graph,
    Icons.trending_up,
    Icons.more_horiz,
  ];

  void signUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onTap: () {},
            ),
          ),
          (route) => false, // Removes all previous routes
        );
      }
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange.shade800,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: List.generate(
              _icons.length,
              (index) => BottomNavigationBarItem(
                icon: Icon(_icons[index]),
                label: '', // Empty label to show only icons
              ),
            ),
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange.shade900,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            showSelectedLabels: false, // Hide selected labels
            showUnselectedLabels: false, // Hide unselected labels
          ),
        ),
      ),
    );
  }
}