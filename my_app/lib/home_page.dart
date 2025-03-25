import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:TradeFlow/pages/search_page.dart';
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
  int _selectedIndex = 2; // SearchPage is now at index 2 (middle position)
  
  // List of pages to display
  late List<Widget> _pages;
  
  // Titles for each page
  final List<String> _titles = [
    "Financial Chatbot",
    "AI Investment Picks",
    "Stock Search", // Search page title
    "Market Trends & Insights",
    "SRI Model"
  ];
  
  // Icons for each page
  final List<IconData> _icons = [
    Icons.smart_toy,
    Icons.auto_graph,
    Icons.search, // Search icon in middle
    Icons.trending_up,
    Icons.more_horiz,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      Page1(),
      const Page2(),
      const SearchPage(), // SearchPage is now part of main navigation
      const Page3(),
      const Page4(),
    ];
  }

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
          (route) => false,
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
            items: [
              BottomNavigationBarItem(
                icon: Icon(_icons[0]),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[1]),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade700,
                        Colors.orange.shade900,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    _icons[2],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[3]),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(_icons[4]),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange.shade900,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              // Ensure we don't go out of bounds
              if (index >= 0 && index < _pages.length) {
                _onItemTapped(index);
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}