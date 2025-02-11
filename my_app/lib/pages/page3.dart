import 'package:flutter/material.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text("Page 3"), backgroundColor: Colors.black87),
      body: const Center(
        child: Text("This is Page 3", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
