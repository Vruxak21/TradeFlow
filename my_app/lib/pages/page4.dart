import 'package:flutter/material.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text("Page 4"), backgroundColor: Colors.black87),
      body: const Center(
        child: Text("This is Page 4", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
