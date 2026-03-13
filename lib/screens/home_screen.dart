import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String userPhone = "";

  double monthlyBudget = 0;
  double spending = 0;
  double balance = 0;

  DateTime budgetMonth = DateTime.now();

  int notificationCount = 0;
  int badgeCount = 0;

  List<String> notifications = [];
  List<Map<String,dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    loadSavedData();
  }

  /// RECALCULATE FINANCE
  void recalculateFinance(){

    spending = 0;
    balance = 0;

    for(var t in transactions){

      String type = t["type"] ?? "income";
      double amount = (t["amount"] ?? 0).toDouble();

      if(type == "expense"){
        spending += amount;
        balance -= amount;
      }else{
        balance += amount;
      }

    }

  }

  /// LOAD SAVED DATA
  Future<void> loadSavedData() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {

      monthlyBudget = prefs.getDouble("budget") ?? 0;

      badgeCount = prefs.getInt("badges") ?? 0;

      notifications =
          prefs.getStringList("notifications") ?? [];

      String? tx = prefs.getString("transactions");

      if(tx != null){

        List list = jsonDecode(tx);

        transactions =
            List<Map<String,dynamic>>.from(list);

      }

      recalculateFinance();

    });

  }

  /// SAVE DATA
  Future<void> saveData() async {

    final prefs = await SharedPreferences.getInstance();

    prefs.setDouble("budget", monthlyBudget);

    prefs.setInt("badges", badgeCount);

    prefs.setStringList("notifications", notifications);

    prefs.setString(
      "transactions",
      jsonEncode(transactions),
    );

  }

  /// ADD NOTIFICATION
  void addNotification(String message){

    setState(() {

      notifications.add(message);
      notificationCount++;

    });

    saveData();

  }

  /// EARN BADGE
  void earnBadge(String reason){

    setState(() {

      badgeCount++;

      notifications.add("🏆 Badge earned: $reason");
      notificationCount++;

    });

    saveData();

  }

  /// RESET MONTH
  void checkMonthlyReset(){

    DateTime now = DateTime.now();

    if(now.month != budgetMonth.month ||
        now.year != budgetMonth.year){

      setState(() {

        monthlyBudget = 0;
        spending = 0;
        budgetMonth = now;

      });

      addNotification(
          "New month started. Please set your monthly budget.");

    }

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
          decoration: const InputDecoration(
            hintText: "Enter budget",
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

                monthlyBudget =
                    double.tryParse(controller.text)
                    ?? monthlyBudget;

                budgetMonth = DateTime.now();

              });

              addNotification(
                  "Budget updated to ₹$monthlyBudget");

              saveData();

              Navigator.pop(context);

            },
            child: const Text("Save"),
          )

        ],

      ),
    );

  }

  /// SHOW NOTIFICATIONS
  void showNotifications(){

    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const Text(
            "Notifications",
            style: TextStyle(
              fontSize:18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height:10),

          if(notifications.isEmpty)
            const Text("No notifications yet"),

          ...notifications.map((n)=>ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(n),
          ))

        ],
      ),
    );

    setState(() {
      notificationCount = 0;
    });

  }

  @override
  Widget build(BuildContext context) {

    checkMonthlyReset();

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
              builder: (_) => const AddExpenseScreen(),
            ),
          );

          if(result != null){

            setState(() {

              transactions.add(result);

              recalculateFinance();

              if(spending <= monthlyBudget){
                earnBadge("Stayed within budget");
              }

            });

            saveData();

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
                active: true,
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExpenseListScreen(
                              transactions: transactions),
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
                        remainingBudget:
                        monthlyBudget - spending,
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
                        userPhone: userPhone,
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

      ),

      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ListView(

            children: [

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    "Hey $userName 👋",
                    style: const TextStyle(
                      fontSize:22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Stack(
                    children: [

                      IconButton(
                        icon: const Icon(
                            Icons.notifications),
                        onPressed: showNotifications,
                      ),

                      if(notificationCount > 0)
                        Positioned(
                          right:6,
                          top:6,
                          child: Container(
                            padding:
                            const EdgeInsets.all(4),
                            decoration:
                            const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notificationCount
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize:10,
                              ),
                            ),
                          ),
                        )

                    ],
                  )

                ],
              ),

              const SizedBox(height:20),

              Row(
                children: [

                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                  ),

                  const SizedBox(width:8),

                  Text(
                    "Badges: $badgeCount",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )

                ],
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
                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "This Month’s Spending",
                      style: TextStyle(
                          color: Colors.white70),
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
                            "Budget\n₹$monthlyBudget",
                            style: const TextStyle(
                                color: Colors.white70),
                          ),
                        ),

                        Text(
                          "Remaining\n₹$remaining",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white70),
                        ),

                      ],
                    ),

                    const SizedBox(height:10),

                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor:
                      Colors.white30,
                      valueColor:
                      const AlwaysStoppedAnimation(
                          Colors.white),
                    )

                  ],

                ),

              ),

              const SizedBox(height:20),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
                        fontWeight:
                        FontWeight.bold,
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