import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/img9.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Sign into your account",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
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
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
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
                        hintText: "Create Password",
                        prefixIcon: Icon(Icons.password_outlined, color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
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
                        hintText: "Confirm Password",
                        prefixIcon: Icon(Icons.password_outlined, color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Text(
                        "Sign into your account",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              width: w * 0.5,
              height: h * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage("assets/images/img9.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  "SignUP",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: w * 0.08),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      // recognizer: TapGestureRecognizer()..onTap=()=>Get.to(()=>LoginPage())
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
