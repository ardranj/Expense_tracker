import 'package:flutter/material.dart';
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

  double budget = 0;
  double spending = 0;
  double balance = 0;

  List<Map<String,dynamic>> transactions = [];

  void setBudget(){

    TextEditingController controller =
        TextEditingController(text: budget.toString());

    showDialog(
      context: context,
      builder: (context){

        return AlertDialog(

          title: const Text("Set Monthly Budget"),

          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter budget"
            ),
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
                  budget = double.tryParse(controller.text) ?? budget;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    double remaining = budget - spending;
    double progress = budget == 0 ? 0 : spending / budget;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),

        onPressed: () async {

          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );

          if(result != null){

            setState(() {

              transactions.add(result);

              bool isExpense = result["isExpense"] ?? false;
              double amount = (result["amount"] ?? 0).toDouble();

              if(isExpense){
                spending += amount;
                balance -= amount;
              } else {
                balance += amount;
              }

            });
          }
        },
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:20),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              const _BottomItem(
                icon: Icons.home,
                label: "Home",
                active: true
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExpenseListScreen(transactions: transactions),
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
                      builder: (_) => const GoalsScreen(),
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
                      builder: (_) => const ProfileScreen(),
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
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ListView(
            children: [

              Text(
                "Hey ${widget.userEmail} 👋",
                style: const TextStyle(
                  fontSize:22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height:20),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors:[
                      Color(0xFF7B2FF7),
                      Color(0xFF9F5BFF)
                    ],
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
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        GestureDetector(
                          onTap: setBudget,
                          child: Text(
                            "Budget\n₹$budget",
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
                      fontSize:16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "₹$balance",
                    style: const TextStyle(
                      fontSize:18,
                      fontWeight: FontWeight.bold,
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

                bool isExpense = t["isExpense"] ?? false;
                double amount = (t["amount"] ?? 0).toDouble();
                String category = (t["category"] ?? "Transaction").toString();

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

              }).toList(),
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