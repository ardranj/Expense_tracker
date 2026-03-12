import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {

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

      if (data["message"] == "Login successful") {

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server connection error")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Back Button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.deepPurple,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),

              /// App Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Title
              const Center(
                child: Text(
                  "Welcome Back! 👋",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Sign in to continue tracking",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              /// Email
              const Text("Email"),
              const SizedBox(height: 6),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "your.email@uni.edu",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Password"),
                  Text(
                    "Forgot?",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.visibility_off),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// SIGN IN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: () {
                    loginUser(context);
                  },

                  child: const Text(
                    "Sign In 🚀",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("OR CONTINUE WITH"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              /// Google Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text("Continue with Google"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),

              const Spacer(),

              /// Register Section
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text("New here? "),

                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  RegisterScreen(),
                          ),
                        );

                      },

                      child: const Text(
                        "Create an account ✨",
                        style: TextStyle(
                          color: Colors.deepPurple,
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
    );
  }
}