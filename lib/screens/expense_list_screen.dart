import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class ExpenseListScreen extends StatefulWidget {

  final List<Map<String,dynamic>> transactions;
  final String userEmail;
  final double monthlyBudget;
  final double goalAmount;

  const ExpenseListScreen({
    super.key,
    required this.transactions,
    required this.userEmail,
    required this.monthlyBudget,
    required this.goalAmount,
  });

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {

  double predictedSpending = 0;
  String topCategoryAI = "";
  String budgetPrediction = "";
  String savingSuggestion = "";
  int goalMonths = 0;

  String apiUrl = "http://192.168.1.38:8000";

  @override
  void initState() {
    super.initState();
    loadAIInsights();
  }

  Future<void> loadAIInsights() async {
    try {

      final response = await http.get(
  Uri.parse(
    "$apiUrl/ai-analysis/${widget.userEmail}?budget=${widget.monthlyBudget}&goal=${widget.goalAmount}"
  ),
);
      
      if(response.statusCode == 200){

        var data = jsonDecode(response.body);

        setState(() {

          predictedSpending =
              (data["predicted_monthly_spending"] ?? 0).toDouble();

          topCategoryAI =
              data["top_spending_category"] ?? "";

          budgetPrediction =
              data["budget_prediction"] ?? "";

          savingSuggestion =
              data["saving_suggestion"] ?? "";

          goalMonths =
              data["goal_prediction_months"] ?? 0;

        });

      }

    }catch(e){
      print(e);
    }

  }

  bool isExpense(Map t) {
    return t["type"] == "expense";
  }

  double get totalExpense {

    double sum = 0;

    for(var t in widget.transactions){

      if(isExpense(t)){
        sum += (t["amount"] ?? 0).toDouble();
      }

    }

    return sum;

  }

  double getMonthlySpending(){

    DateTime now = DateTime.now();
    double total = 0;

    for(var t in widget.transactions){

      if(t["type"] == "expense"){

        DateTime date = DateTime.parse(t["date"]);

        if(date.month == now.month && date.year == now.year){
          total += (t["amount"] ?? 0).toDouble();
        }

      }

    }

    return total;

  }

  Map<String,double> categoryTotals(){

    Map<String,double> data = {};

    for(var t in widget.transactions){

      if(isExpense(t)){

        String cat = t["category"] ?? "Other";
        double amount = (t["amount"] ?? 0).toDouble();

        data[cat] = (data[cat] ?? 0) + amount;

      }

    }

    return data;

  }

  List<PieChartSectionData> pieSections(){

    final data = categoryTotals();
    double total = totalExpense;

    Map<String,Color> colors = {
  "Shopping": Colors.grey,
  "Food": Colors.orange,
  "Transport": Colors.blue,
  "Education": Colors.purple,
  "Salary": Colors.green,
  "Other": Colors.red,
};
    return data.entries.map((e){

      double percent = (e.value / total) * 100;

      return PieChartSectionData(
        value: e.value,
        title: "${percent.toStringAsFixed(0)}%",
        radius: 70,
        color: colors[e.key] ?? Colors.grey,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );

    }).toList();

  }

  List<FlSpot> trendSpots(){

    Map<int,double> weekTotals = {1:0,2:0,3:0,4:0};

    for(var t in widget.transactions){

      if(isExpense(t)){

        DateTime date = DateTime.parse(t["date"]);

        int week = ((date.day - 1) ~/ 7) + 1;
        week = week > 4 ? 4 : week;

        weekTotals[week] =
            (weekTotals[week] ?? 0) +
                (t["amount"] ?? 0).toDouble();

      }

    }

    return [
      FlSpot(1, weekTotals[1]!),
      FlSpot(2, weekTotals[2]!),
      FlSpot(3, weekTotals[3]!),
      FlSpot(4, weekTotals[4]!),
    ];

  }

  String highestWeek(){

    Map<int,double> weekTotals = {1:0,2:0,3:0,4:0};

    for(var t in widget.transactions){

      if(isExpense(t)){

        DateTime date = DateTime.parse(t["date"]);

        int week = ((date.day - 1) ~/ 7) + 1;
        week = week > 4 ? 4 : week;

        weekTotals[week] =
            (weekTotals[week] ?? 0) +
                (t["amount"] ?? 0).toDouble();

      }

    }

    int w = 1;
    double max = 0;

    weekTotals.forEach((week,amount){

      if(amount > max){
        max = amount;
        w = week;
      }

    });

    return "Week $w";

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F4FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Reports",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            /// MONTH SPENDING CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FF7), Color(0xFF9D4EDD)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "This Month’s Spending",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height:10),

                  Text(
                    "₹${getMonthlySpending().toStringAsFixed(1)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height:20),

            Row(

              children: [

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "By Category",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height:10),
                        SizedBox(
                          height:150,
                          child: PieChart(
                            PieChartData(
                              sections: pieSections(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width:15),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Trend",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height:10),
                        SizedBox(
                          height:150,
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: trendSpots(),
                                  isCurved: true,
                                  color: Colors.deepPurple,
                                  barWidth: 4,
                                  dotData: FlDotData(show:true),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],

            ),

            const SizedBox(height:20),

            /// LEGEND
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(
  alignment: WrapAlignment.center,
  spacing: 15,
  runSpacing: 8,
  children: [

                  Row(
                    children: [
                      CircleAvatar(radius:6, backgroundColor: Colors.grey),
                      SizedBox(width:6),
                      Text("Shopping"),
                    ],
                  ),

                  Row(
                    children: [
                      CircleAvatar(radius:6, backgroundColor: Colors.orange),
                      SizedBox(width:6),
                      Text("Food"),
                    ],
                  ),

                  Row(
                    children: [
                      CircleAvatar(radius:6, backgroundColor: Colors.blue),
                      SizedBox(width:6),
                      Text("Transport"),
                    ],
                  ),

                  Row(
                    children: [
                      CircleAvatar(radius:6, backgroundColor: Colors.purple),
                      SizedBox(width:6),
                      Text("Education"),
                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height:20),

            /// WEEK INSIGHT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "${highestWeek()} had the highest expenses",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),

                  const SizedBox(height:6),

                  const Text(
                    "💡 Set your goals   📊 Keep tracking!",
                    style: TextStyle(color: Colors.black54),
                  ),

                ],
              ),
            ),

            const SizedBox(height:20),

            /// AI INSIGHTS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "AI Insights",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:16),
                  ),

                  const SizedBox(height:10),

                  Text("Predicted Monthly Spending: ₹$predictedSpending"),
                  Text("Top Spending Category: $topCategoryAI"),
                  Text("Budget Prediction: $budgetPrediction"),
                  Text("Saving Suggestion: $savingSuggestion"),
                  Text("Goal Achievement Time: $goalMonths months"),

                ],
              ),
            ),

          ],

        ),

      ),

    );

  }

}