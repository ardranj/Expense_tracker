import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // Avatar
            Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFF9F5BFF)],
                    ),
                  ),
                  child: const Icon(Icons.person,
                      size: 70, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 20, color: Colors.deepPurple),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Alex Student",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            const Text(
              "Student Member",
              style: TextStyle(
                  color: Colors.deepPurple),
            ),

            const SizedBox(height: 30),

            _profileTile(Icons.person, "Full Name", "Alex Student"),
            const SizedBox(height: 15),
            _profileTile(Icons.email, "Email Address",
                "alex.student@university.edu"),
            const SizedBox(height: 15),
            _profileTile(Icons.phone, "Phone Number",
                "+91 98765 43210"),
            const SizedBox(height: 15),
            _profileTile(Icons.account_balance_wallet,
                "Monthly Budget", "₹ 800"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7B2FF7),
                      Color(0xFF9F5BFF)
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _profileTile(
      IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                Colors.deepPurple.withOpacity(0.1),
            child:
                Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.grey)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontWeight:
                            FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.edit,
              size: 18, color: Colors.grey)
        ],
      ),
    );
  }
}