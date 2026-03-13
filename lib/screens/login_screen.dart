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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;

  Future<void> loginUser() async {

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email and password")),
      );
      return;
    }

    try {

      var response = await http.post(
        Uri.parse("http://192.168.1.38:8000/login"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "email": email,
          "password": password
        }),
      );

      if(response.statusCode == 200){

        var data = jsonDecode(response.body);

        if(data["error"] != null){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["error"])),
          );
        }
        else{

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(userEmail: email),
            ),
          );

        }

      }

    } catch(e){

      /// DEMO LOGIN IF BACKEND OFF
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

      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height:20),

              Row(
                children: [

                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "← Back",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize:16,
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height:30),

              Container(
                width:70,
                height:70,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.deepPurple,
                  size:35,
                ),
              ),

              const SizedBox(height:20),

              const Text(
                "Welcome Back! 👋",
                style: TextStyle(
                  fontSize:26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height:6),

              const Text(
                "Sign in to continue tracking",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height:30),

              /// EMAIL
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "your.email@uni.edu",
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height:20),

              /// PASSWORD
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: (){
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height:30),

              /// LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height:50,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: loginUser,

                  child: const Text(
                    "Sign In ✨",
                    style: TextStyle(fontSize:16),
                  ),
                ),
              ),

              const SizedBox(height:20),

              const Text("OR CONTINUE WITH"),

              const SizedBox(height:10),

              Container(
                width: double.infinity,
                height:50,

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(Icons.g_mobiledata,size:30),
                    SizedBox(width:8),
                    Text("Continue with Google"),

                  ],
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("New here? "),

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
                      "Create an account ✨",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height:20),

            ],
          ),
        ),
      ),
    );
  }
}