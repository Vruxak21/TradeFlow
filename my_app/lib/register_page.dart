import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:animate_do/animate_do.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpass = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool isLoading = false;
  bool isGoogleLoading = false;

  void signUserUp(BuildContext context) async {
    if (isLoading) return; // Prevent multiple clicks
    
    setState(() {
      isLoading = true;
    });
    
    try {
      if (passwordController.text != confirmpass.text) {
        _showErrorDialog(
            context, "Password Mismatch", "Passwords do not match.");
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("User registered successfully!");
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleFirebaseError(BuildContext context, FirebaseAuthException e) {
    String errorMessage = "An unknown error occurred.";
    if (e.code == 'email-already-in-use') {
      errorMessage = "This email is already registered.";
    } else if (e.code == 'weak-password') {
      errorMessage = "Your password is too weak. Use a stronger password.";
    } else if (e.code == 'invalid-email') {
      errorMessage = "Invalid email format.";
    }
    _showErrorDialog(context, "Registration Error", errorMessage);
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (isGoogleLoading) return; // Prevent multiple clicks

    setState(() {
      isGoogleLoading = true;
    });
    
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          isGoogleLoading = false;
        });
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      print("Google Sign-In successful!");
    } catch (e) {
      print("Error during Google Sign-In: $e");
      _showErrorDialog(context, "Google Sign-In Error",
          "An error occurred during Google sign-in.");
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
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
              Colors.orange.shade400
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    child: const Text(
                      "Create an account",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 60),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(225, 95, 27, .3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: usernameController,
                                    decoration: const InputDecoration(
                                      hintText: "Email",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: TextField(
                                    controller: confirmpass,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: "Confirm Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: MaterialButton(
                            onPressed: isLoading ? null : () => signUserUp(context),
                            height: 50,
                            color: Colors.orange[900],
                            disabledColor: Colors.orange[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1700),
                          child: const Text(
                            "Continue with Google",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FadeInUp(
                                duration: const Duration(milliseconds: 1800),
                                child: MaterialButton(
                                  onPressed: isGoogleLoading ? null : _signInWithGoogle,
                                  height: 50,
                                  color: Colors.blue,
                                  disabledColor: Colors.blue[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: isGoogleLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "Google",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1900),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: Text(
                                  'Login now',
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}