import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    name = widget.userName;
    email = widget.userEmail;
    phone = widget.userPhone;
    budget = widget.monthlyBudget;
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
            onPressed: (){

              setState(() {

                name = nameController.text;
                email = emailController.text;
                phone = phoneController.text;
                budget = double.tryParse(budgetController.text) ?? budget;

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