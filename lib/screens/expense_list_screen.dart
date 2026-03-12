import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const ExpenseListScreen({super.key, required this.transactions});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {

  int selectedTab = 1;

  Map<String, Color> categoryColors = {
    "Food": Colors.orange,
    "Shopping": Colors.grey,
    "Transport": Colors.blue,
    "Entertainment": Colors.purple,
    "Clothes": Colors.pink,
    "Tuition": Colors.indigo,
    "Fitness": Colors.green,
    "Travel": Colors.teal,
    "Loan": Colors.red,
    "Other": Colors.grey,
  };

  /// FILTER TRANSACTIONS
  List<Map<String, dynamic>> getFilteredTransactions() {

    DateTime now = DateTime.now();

    return widget.transactions.where((t) {

      DateTime date = DateTime.parse(t["date"]);

      if (selectedTab == 0) {
        return now.difference(date).inDays <= 7;
      }

      if (selectedTab == 1) {
        return date.month == now.month && date.year == now.year;
      }

      if (selectedTab == 2) {
        return date.year == now.year;
      }

      return true;

    }).toList();
  }

  /// TOTAL EXPENSE
  double get totalExpense {

    double sum = 0;

    for (var t in getFilteredTransactions()) {
      if (t["isExpense"] == true) {
        sum += (t["amount"] ?? 0).toDouble();
      }
    }

    return sum;
  }

  /// CATEGORY TOTALS
  Map<String, double> getCategoryTotals() {

    Map<String, double> data = {};

    for (var t in getFilteredTransactions()) {

      if (t["isExpense"] == true) {

        String category = (t["category"] ?? "Other").toString();
        double amount = (t["amount"] ?? 0).toDouble();

        data[category] = (data[category] ?? 0) + amount;
      }

    }

    return data;
  }

  /// PIE CHART DATA
  List<PieChartSectionData> getPieSections() {

    final data = getCategoryTotals();
    double total = totalExpense;

    if(total == 0) return [];

    return data.entries.map((entry) {

      double percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: "${percentage.toStringAsFixed(0)}%",
        color: categoryColors[entry.key] ?? Colors.grey,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

    }).toList();
  }

  /// TREND GRAPH (WEEKLY SPENDING)
  List<FlSpot> getTrendSpots() {

    List<Map<String,dynamic>> filtered = getFilteredTransactions();

    Map<int,double> weeklyTotals = {
      1:0,2:0,3:0,4:0
    };

    for (var t in filtered) {

      if (t["isExpense"] == true) {

        DateTime date = DateTime.parse(t["date"]);

        int week = ((date.day - 1) ~/ 7) + 1;
        week = week > 4 ? 4 : week;

        double amount = (t["amount"] ?? 0).toDouble();

        weeklyTotals[week] = (weeklyTotals[week] ?? 0) + amount;
      }
    }

    return [
      FlSpot(1, weeklyTotals[1]!),
      FlSpot(2, weeklyTotals[2]!),
      FlSpot(3, weeklyTotals[3]!),
      FlSpot(4, weeklyTotals[4]!),
    ];
  }

  /// WEEK WITH HIGHEST SPENDING
  String getHighestWeek(){

    Map<int,double> weeklyTotals = {
      1:0,2:0,3:0,4:0
    };

    for(var t in getFilteredTransactions()){

      if(t["isExpense"] == true){

        DateTime date = DateTime.parse(t["date"]);

        int week = ((date.day - 1) ~/ 7) + 1;
        week = week > 4 ? 4 : week;

        weeklyTotals[week] =
            (weeklyTotals[week] ?? 0) +
                (t["amount"] ?? 0).toDouble();
      }
    }

    int highestWeek = 1;
    double max = 0;

    weeklyTotals.forEach((week,amount){

      if(amount > max){
        max = amount;
        highestWeek = week;
      }

    });

    return "Week $highestWeek";
  }

  /// MOST SPENT CATEGORY
  String getTopCategory(){

    final data = getCategoryTotals();

    if(data.isEmpty) return "None";

    var maxEntry =
        data.entries.reduce((a,b)=> a.value > b.value ? a : b);

    return maxEntry.key;
  }

  /// CATEGORY LEGEND
  Widget buildLegend(){

    final data = getCategoryTotals();

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Wrap(
        spacing: 30,
        runSpacing: 10,

        children: data.keys.map((category){

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              CircleAvatar(
                radius: 6,
                backgroundColor:
                    categoryColors[category] ?? Colors.grey,
              ),

              const SizedBox(width:6),

              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          );

        }).toList(),
      ),
    );
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

                  _tab("Weekly",0),
                  _tab("Monthly",1),
                  _tab("Yearly",2),

                ],
              ),
            ),

            const SizedBox(height:20),

            /// SUMMARY CARD
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
                    "This Month",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height:8),

                  Text(
                    "₹${totalExpense.toInt()}",
                    style: const TextStyle(
                      fontSize:28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height:6),

                  Text(
                    "You spent most on ${getTopCategory()} this month",
                    style: const TextStyle(color: Colors.white70),
                  ),

                ],
              ),
            ),

            const SizedBox(height:20),

            /// CHARTS
            Row(
              children: [

                /// PIE CHART
                Expanded(
                  child: Container(
                    height:240,
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      children: [

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "By Category",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height:10),

                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: getPieSections(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width:12),

                /// TREND GRAPH
                Expanded(
                  child: Container(
                    height:240,
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Column(
                      children: [

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Trend",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height:10),

                        Expanded(
                          child: LineChart(
                            LineChartData(
                              borderData: FlBorderData(show:false),
                              gridData: const FlGridData(show:true),

                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta){

                                      return Text(
                                        "Week ${value.toInt()}",
                                        style: const TextStyle(fontSize:10),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              lineBarsData: [

                                LineChartBarData(
                                  spots: getTrendSpots(),
                                  isCurved: true,
                                  color: Colors.deepPurple,
                                  barWidth:4,
                                  dotData: const FlDotData(show:true),
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

            buildLegend(),

            const SizedBox(height:20),

            /// INSIGHT CARD
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
                    "${getHighestWeek()} had the highest expenses",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height:8),

                  const Text(
                    "💡 Set daily limits   🍽 Meal prep   📊 Keep tracking!",
                    style: TextStyle(color: Colors.black54),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _tab(String text,int index){

    bool active = selectedTab == index;

    return GestureDetector(

      onTap: (){
        setState(() {
          selectedTab = index;
        });
      },

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.deepPurple
                : Colors.grey,
            fontWeight: active
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}