import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  bool isExpense = true;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

  List<String> categories = [
    "Food",
    "Transport",
    "Education",
    "Shopping",
    "Salary",
    "Other",
  ];

  void saveTransaction() {

    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter amount")),
      );
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0;

    Map<String, dynamic> transaction = {
      "title": selectedCategory,
      "category": selectedCategory,
      "amount": amount,
      "type": isExpense ? "expense" : "income",
      "date": selectedDate.toIso8601String(),
    };

    Navigator.pop(context, transaction);
  }

  void pickCategory() async {

    String? category = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView(
          children: categories.map((c) {
            return ListTile(
              title: Text(c),
              onTap: () => Navigator.pop(context, c),
            );
          }).toList(),
        );
      },
    );

    if (category != null) {
      setState(() {
        selectedCategory = category;
      });
    }
  }

  void pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEFF),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Add Transaction",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        isExpense = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical:12),
                      decoration: BoxDecoration(
                        color: isExpense ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          "Expense",
                          style: TextStyle(
                            color: isExpense ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width:10),

                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        isExpense = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical:12),
                      decoration: BoxDecoration(
                        color: !isExpense ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          "Income",
                          style: TextStyle(
                            color: !isExpense ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height:30),

            const Text(
              "How much?",
              style: TextStyle(color: Colors.grey),
            ),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize:40,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "₹ 0",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height:20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.category,color:Colors.deepPurple),
                title: const Text("Category"),
                subtitle: Text(selectedCategory),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: pickCategory,
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today,color:Colors.deepPurple),
                title: const Text("Date"),
                subtitle: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: pickDate,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical:16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Save Transaction",
                  style: TextStyle(fontSize:16),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}