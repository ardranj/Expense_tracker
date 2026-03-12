import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const ExpenseListScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  int selectedTab = 1;

  /// TOTAL EXPENSE
  double get totalExpense {
    double sum = 0;
    for (var t in widget.transactions) {
      if (t["isExpense"] == true) {
        sum += (t["amount"] ?? 0).toDouble();
      }
    }
    return sum;
  }

  /// CATEGORY WISE DATA FOR PIE CHART
  Map<String, double> get categoryTotals {
    Map<String, double> data = {};

    for (var t in widget.transactions) {
      if (t["isExpense"] == true) {
        String category = (t["category"] ?? "Other").toString();
        double amount = (t["amount"] ?? 0).toDouble();

        data[category] = (data[category] ?? 0) + amount;
      }
    }

    return data;
  }

  /// LINE CHART DATA
  List<FlSpot> get lineSpots {
    List<FlSpot> spots = [];
    int index = 0;

    for (var t in widget.transactions) {
      if (t["isExpense"] == true) {
        double amount = (t["amount"] ?? 0).toDouble();
        spots.add(FlSpot(index.toDouble(), amount));
        index++;
      }
    }

    return spots;
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

            /// TABS
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _tab("Weekly", 0),
                  _tab("Monthly", 1),
                  _tab("Yearly", 2),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SUMMARY CARD
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
                    "Total Expenses",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${totalExpense.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// PIE CHART
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: entry.key,
                      radius: 60,
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LINE CHART
            Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: lineSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.deepPurple,
                      dotData: const FlDotData(show: true),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String text, int index) {
    bool active = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.deepPurple : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}