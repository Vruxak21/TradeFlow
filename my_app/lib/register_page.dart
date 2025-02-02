import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/components/my_textfield.dart';
import 'package:my_app/components/my_button.dart';
import 'package:my_app/components/square_tile.dart';

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

  // Initialize GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void signUserUp(BuildContext context) async {
    try {
      if (passwordController.text != confirmpass.text) {
        _showErrorDialog(context, "Password Mismatch", "Passwords do not match.");
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("User registered successfully!");
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(context, e);
    }
  }

  // ✅ Handle Firebase errors
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

  // ✅ Show error dialog
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

  // ✅ Handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Get the authentication details
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Google credentials
      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Google Sign-In successful!");
    } catch (e) {
      print("Error during Google Sign-In: $e");
      _showErrorDialog(context, "Google Sign-In Error", "An error occurred during Google sign-in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.lock, size: 80),
              const SizedBox(height: 30),
              Text(
                'Create an account',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: usernameController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: confirmpass,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              const SizedBox(height: 20),
              MyButton(
                text: "Sign Up",
                onTap: () => signUserUp(context),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Or continue with', style: TextStyle(color: Colors.grey[700])),
                    ),
                    Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Google Sign-In button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _signInWithGoogle,
                    child: const SquareTile(imagePath: 'lib/images/google.png'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
