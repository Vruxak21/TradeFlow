import 'package:flutter/material.dart';
import 'package:my_app/login_page.dart';
import 'package:my_app/register_page.dart';
// change
class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showloginpage = true;
  void togglepages() {
    setState(() {
      showloginpage = !showloginpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showloginpage) {
      return LoginPage(
        onTap: togglepages,
      );
    } else {
      return RegisterPage(
        onTap: togglepages,
      );
    }
  }
}
