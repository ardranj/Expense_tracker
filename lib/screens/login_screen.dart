import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;

  Future<void> loginUser() async {

    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );

      return;
    }

    try {

      var response = await http.post(
        Uri.parse("http://192.168.1.37:8000/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password
        }),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["message"] == "Login successful") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userEmail: email),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Login failed")),
        );

      }

    } catch (e) {

      /// DEMO MODE if backend not running

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server not running — Demo mode enabled"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userEmail: email),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Text(
              "Welcome Back",
              style: TextStyle(
                fontSize:28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:30),

            /// Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height:15),

            /// Password
            TextField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              decoration: InputDecoration(
                hintText: "Password",

                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: (){
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),

                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height:25),

            /// Login Button
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical:14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                onPressed: () {
                  loginUser();
                },

                child: const Text(
                  "Login",
                  style: TextStyle(fontSize:16),
                ),
              ),
            ),

            const SizedBox(height:20),

            /// Register navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text("Don't have an account? "),

                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )

              ],
            )

          ],
        ),
      ),
    );
  }
}