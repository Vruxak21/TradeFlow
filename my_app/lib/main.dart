import 'package:flutter/material.dart';
import 'package:my_app/auth_page.dart';
import '/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      // Add this line to define the /home_page route
      routes: {
        '/home_page': (context) => const HomePage(),
      },
    );
  }
}