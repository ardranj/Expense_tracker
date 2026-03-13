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
  }

  /// Add notification
  void addNotification(String message){
    setState(() {
      notifications.add(message);
      notificationCount++;
    });
  }

  /// Earn badge
  void earnBadge(String reason){
    setState(() {
      badgeCount++;
      notifications.add("🏆 Badge earned: $reason");
      notificationCount++;
    });
  }

  /// Reset monthly budget
  void checkMonthlyReset(){

    DateTime now = DateTime.now();

    if(now.month != budgetMonth.month || now.year != budgetMonth.year){

      setState(() {
        monthlyBudget = 0;
        spending = 0;
        budgetMonth = now;
      });

      addNotification("New month started. Please set your monthly budget.");
    }

  }

  /// Set monthly budget
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
                    double.tryParse(controller.text) ?? monthlyBudget;

                budgetMonth = DateTime.now();

              });

              addNotification("Budget updated to ₹$monthlyBudget");

              Navigator.pop(context);

            },
            child: const Text("Save"),
          )

        ],

      ),
    );

  }

  /// Show notifications
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

              bool isExpense = result["isExpense"] ?? false;
              double amount = (result["amount"] ?? 0).toDouble();

              if(isExpense){
                spending += amount;
                balance -= amount;
              }else{
                balance += amount;
              }

              if(spending <= monthlyBudget){
                earnBadge("Stayed within budget");
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
                active: true,
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

              /// GOALS
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GoalsScreen(
                        remainingBudget: monthlyBudget - spending,
                      ),
                    ),
                  );
                },
                child: const _BottomItem(
                  icon: Icons.flag,
                  label: "Goals",
                ),
              ),

              /// PROFILE
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

              /// Header
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

                  Stack(
                    children: [

                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: showNotifications,
                      ),

                      if(notificationCount > 0)
                        Positioned(
                          right:6,
                          top:6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notificationCount.toString(),
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

              /// Badge counter
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

              /// Spending card
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
                    )

                  ],

                ),

              ),

              const SizedBox(height:20),

              /// Current Balance
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
                String category =
                    (t["category"] ?? "Transaction").toString();

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