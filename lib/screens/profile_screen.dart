import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {

  final String userName;
  final String userEmail;
  final String userPhone;
  final double monthlyBudget;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.monthlyBudget,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late String name;
  late String email;
  late String phone;
  late double budget;

  String apiUrl = "http://192.168.1.38:8000";

  @override
  void initState() {
    super.initState();

    name = widget.userName;
    email = widget.userEmail;
    phone = widget.userPhone;
    budget = widget.monthlyBudget;

    loadProfile();
  }

  /// LOAD PROFILE FROM BACKEND
  Future<void> loadProfile() async {

    try {

      var response = await http.get(
        Uri.parse("$apiUrl/profile/$email"),
      );

      if(response.statusCode == 200){

        var data = jsonDecode(response.body);

        setState(() {
          name = data["name"];
          email = data["email"];
          phone = data["phone"];
        });

      }

    } catch(e){
      print(e);
    }

  }

  /// UPDATE PROFILE IN BACKEND
  Future<void> updateProfile(
      String newName,
      String newEmail,
      String newPhone
      ) async {

    try {

      await http.put(
        Uri.parse("$apiUrl/update-profile"),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode({
          "name": newName,
          "email": newEmail,
          "phone": newPhone,
          "password": "123456"
        }),
      );

    } catch(e){
      print(e);
    }

  }

  void editProfile(){

    TextEditingController nameController =
        TextEditingController(text: name);

    TextEditingController emailController =
        TextEditingController(text: email);

    TextEditingController phoneController =
        TextEditingController(text: phone);

    TextEditingController budgetController =
        TextEditingController(text: budget.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(

        title: const Text("Edit Profile"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
              ),
            ),

            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monthly Budget",
              ),
            ),

          ],
        ),

        actions: [

          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              String newName = nameController.text;
              String newEmail = emailController.text;
              String newPhone = phoneController.text;
              double newBudget =
                  double.tryParse(budgetController.text) ?? budget;

              await updateProfile(newName,newEmail,newPhone);

              setState(() {

                name = newName;
                email = newEmail;
                phone = newPhone;
                budget = newBudget;

              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          )

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,

        actions: [

          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: editProfile,
          )

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height:20),

            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height:20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Name"),
                subtitle: Text(name),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(email),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Phone"),
                subtitle: Text(phone),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Monthly Budget"),
                subtitle: Text("₹$budget"),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical:14),
                ),

                onPressed: (){
                  Navigator.pop(context);
                },

                child: const Text("Logout"),
              ),
            )

          ],
        ),
      ),
    );
  }
}

