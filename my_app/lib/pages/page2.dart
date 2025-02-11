import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text("Page 2"), backgroundColor: Colors.black87),
      body: const Center(
        child: Text("This is Page 2", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
