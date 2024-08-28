import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internship1/signup_page.dart';

import 'dashboad.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Added SingleChildScrollView for scrolling
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/img10.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20), // Use symmetric margin for consistency
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20), // Added space for better positioning
                  Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Enter your credentials to login",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 30), // Adjusted spacing for better layout
                  _buildTextField("Email", Icons.email),
                  SizedBox(height: 20),
                  _buildTextField("Password", Icons.lock),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  SizedBox(height: 30), // Added space before the button
                  _buildLoginButton(context, w, h),
                  SizedBox(height: 20), // Space before the bottom text
                  _buildSignUpText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String hintText, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 7,
            offset: Offset(1, 1),
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.teal),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Helper method to build the login button
  Widget _buildLoginButton(BuildContext context, double w, double h) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      },
      child: Container(
        width: w * 0.5,
        height: h * 0.08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.teal, // Changed to a solid color for better visibility
        ),
        child: Center(
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Changed text color for contrast
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build sign-up text
  Widget _buildSignUpText() {
    return RichText(
      text: TextSpan(
        text: "Don't have an account? ",
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: "Create",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.to(() => SignUpPage()),
          ),
        ],
      ),
    );
  }
}
 