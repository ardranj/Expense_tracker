import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {

    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String password = passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {

      var response = await http.post(
        Uri.parse("http://192.168.1.37:8000/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password
        }),
      );

      var data = jsonDecode(response.body);

      print(data);

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );

        Navigator.pop(context);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Registration failed")),
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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        centerTitle: true,

        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            const SizedBox(height: 20),

            _inputField(
              "Full Name",
              controller: nameController,
            ),

            const SizedBox(height: 15),

            _inputField(
              "Email Address",
              controller: emailController,
            ),

            const SizedBox(height: 15),

            _inputField(
              "Phone Number",
              controller: phoneController,
            ),

            const SizedBox(height: 15),

            _inputField(
              "Password",
              controller: passwordController,
              isPassword: true,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                onPressed: () {
                  registerUser(context);
                },

                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _inputField(
      String hint,
      {bool isPassword = false,
      required TextEditingController controller}) {

    return TextField(
      controller: controller,
      obscureText: isPassword,

      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}