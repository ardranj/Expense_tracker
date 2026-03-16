import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {

  final String userEmail;

  const HomeScreen({super.key, required this.userEmail});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String userName = "User";
  String userEmail = "";

  double monthlyBudget = 0;
  double spending = 0;
  double balance = 0;
  double goalAmount = 0;

  int badgeCount = 0;

  List<Map<String,dynamic>> transactions = [];

  String apiUrl = "http://192.168.1.38:8000";

  @override
  void initState() {
    super.initState();

    userEmail = widget.userEmail;

    loadTransactions();
    loadGoal();
  }

  /// LOAD TRANSACTIONS FROM BACKEND
  Future<void> loadTransactions() async {

    try {

      var response = await http.get(
        Uri.parse("$apiUrl/transactions/$userEmail"),
      );

      if(response.statusCode == 200){

        List data = jsonDecode(response.body);

        transactions = List<Map<String,dynamic>>.from(data);

        calculateFinance();

        setState(() {});

      }

    } catch(e){
      print(e);
    }

  }

  /// LOAD GOAL FROM BACKEND
  Future<void> loadGoal() async {

    try {

      var response = await http.get(
        Uri.parse("$apiUrl/goals/$userEmail"),
      );

      if(response.statusCode == 200){

        List data = jsonDecode(response.body);

        if(data.isNotEmpty){
          goalAmount = data[0]["target"];
        }

        setState(() {});

      }

    } catch(e){
      print(e);
    }

  }

  /// CALCULATE SPENDING & BALANCE
  void calculateFinance(){

    spending = 0;
    balance = 0;

    for(var t in transactions){

      String type = t["type"];
      double amount = (t["amount"] ?? 0).toDouble();

      if(type == "expense"){
        spending += amount;
        balance -= amount;
      }else{
        balance += amount;
      }

    }

  }

  /// BADGE SYSTEM
  void updateBadges(){

    if(transactions.length >= 20){
      badgeCount = 3;
    }
    else if(transactions.length >= 10){
      badgeCount = 2;
    }
    else if(transactions.length >= 5){
      badgeCount = 1;
    }
    else{
      badgeCount = 0;
    }

  }

  /// NOTIFICATIONS
  void showNotifications(){

    String message = "";

    if(spending > monthlyBudget){
      message = "⚠️ You exceeded your monthly budget!";
    }
    else if(spending > monthlyBudget * 0.8){
      message = "⚠️ You are close to your budget limit.";
    }
    else{
      message = "✅ Your spending is under control.";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Notification"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );

  }

  /// SET BUDGET
  void setBudget(){

    TextEditingController controller =
        TextEditingController(text: monthlyBudget.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(

        title: const Text("Set Monthly Budget"),

        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
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

                monthlyBudget =
                    double.tryParse(controller.text) ?? monthlyBudget;

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

    double remaining = monthlyBudget - spending;

    double progress = monthlyBudget == 0
        ? 0
        : spending / monthlyBudget;

    return Scaffold(

      backgroundColor: const Color(0xFFF6F4FF),

      floatingActionButton: FloatingActionButton(

        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),

        onPressed: () async {

          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(
                  userEmail: userEmail,
              ),
            ),
          );

          if(result != null){

            /// attach user email to transaction
            result["user_email"] = userEmail;

            await http.post(
              Uri.parse("$apiUrl/add-expense"),
              headers: {"Content-Type":"application/json"},
              body: jsonEncode(result),
            );

            await loadTransactions();

          }

        },

      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(

        shape: const CircularNotchedRectangle(),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            const _BottomItem(
              icon: Icons.home,
              label: "Home",
              active: true,
            ),

            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExpenseListScreen(
                      transactions: transactions,
                      userEmail: userEmail,
                      monthlyBudget: monthlyBudget,
                      goalAmount: goalAmount,
                    ),
                  ),
                );
              },
              child: const _BottomItem(
                icon: Icons.bar_chart,
                label: "Reports",
              ),
            ),

            const SizedBox(width:40),

            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GoalsScreen(
                      remainingBudget: remaining,
                    ),
                  ),
                );
              },
              child: const _BottomItem(
                icon: Icons.flag,
                label: "Goals",
              ),
            ),

            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      userName: userName,
                      userEmail: userEmail,
                      userPhone: "",
                      monthlyBudget: monthlyBudget,
                    ),
                  ),
                );
              },
              child: const _BottomItem(
                icon: Icons.person,
                label: "Profile",
              ),
            ),

          ],
        ),
      ),

      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ListView(

            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Hey $userName 👋",
                    style: const TextStyle(
                      fontSize:22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Icon(Icons.notifications),

                ],
              ),

              const SizedBox(height:10),

              Row(
                children: [

                  const Icon(Icons.emoji_events,
                      color: Colors.amber),

                  const SizedBox(width:8),

                  Text(
                    "Badges: $badgeCount",
                    style: const TextStyle(fontSize:16),
                  ),

                ],
              ),

              const SizedBox(height:20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFF9F5BFF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "This Month’s Spending",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height:6),

                    Text(
                      "₹$spending",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize:26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height:14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        GestureDetector(
                          onTap: setBudget,
                          child: Text(
                            "Budget\n₹$monthlyBudget",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),

                        Text(
                          "Remaining\n₹$remaining",
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: Colors.white70),
                        ),

                      ],
                    ),

                    const SizedBox(height:10),

                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),

                  ],
                ),
              ),

              const SizedBox(height:20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    "Current Balance",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:16,
                    ),
                  ),

                  Text(
                    "₹$balance",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:18,
                    ),
                  ),

                ],
              ),

              const SizedBox(height:20),

              const Text(
                "Recent Transactions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:16,
                ),
              ),

              const SizedBox(height:10),

              ...transactions.map((t){

                String type = t["type"] ?? "income";

                double amount =
                    (t["amount"] ?? 0).toDouble();

                String category =
                    (t["category"] ?? "Transaction")
                        .toString();

                bool isExpense = type == "expense";

                return Card(
                  child: ListTile(
                    title: Text(category),
                    trailing: Text(
                      isExpense
                          ? "-₹$amount"
                          : "+₹$amount",
                      style: TextStyle(
                        color: isExpense
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );

              }).toList()

            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {

  final IconData icon;
  final String label;
  final bool active;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.active=false
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          color: active
              ? Colors.deepPurple
              : Colors.grey,
        ),

        Text(
          label,
          style: TextStyle(
            fontSize:12,
            color: active
                ? Colors.deepPurple
                : Colors.grey,
          ),
        ),

      ],
    );
  }
}

