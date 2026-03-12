import 'package:flutter/material.dart';

class Goal {
  String title;
  double saved;
  double target;

  Goal({
    required this.title,
    required this.saved,
    required this.target,
  });
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {

  List<Goal> goals = [];

  double get totalSaved =>
      goals.fold(0, (sum, g) => sum + g.saved);

  double get totalTarget =>
      goals.fold(0, (sum, g) => sum + g.target);

  void addGoal() {

    TextEditingController nameController = TextEditingController();
    TextEditingController targetController = TextEditingController();
    TextEditingController savedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Add Goal"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Goal Name",
                ),
              ),

              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Amount",
                ),
              ),

              TextField(
                controller: savedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Saved Amount",
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
              onPressed: () {

                setState(() {

                  goals.add(
                    Goal(
                      title: nameController.text,
                      target: double.parse(targetController.text),
                      saved: savedController.text.isEmpty
                          ? 0
                          : double.parse(savedController.text),
                    ),
                  );

                });

                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        );
      },
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
          "My Goals",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: addGoal,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            /// OVERALL PROGRESS CARD
            if(goals.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7B2FF7),
                    Color(0xFF9F5BFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Overall Progress",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height:10),

                  Text(
                    "₹${totalSaved.toInt()} / ₹${totalTarget.toInt()}",
                    style: const TextStyle(
                      fontSize:24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height:10),

                  LinearProgressIndicator(
                    value: totalTarget == 0
                        ? 0
                        : totalSaved / totalTarget,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height:20),

            /// GOAL CARDS
            ...goals.map((goal){

              double progress = goal.saved / goal.target;
              double remaining = goal.target - goal.saved;

              return Container(
                margin: const EdgeInsets.only(bottom:20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          goal.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:16,
                          ),
                        ),

                        Text(
                          "${(progress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height:6),

                    Text(
                      "₹${goal.saved.toInt()} / ₹${goal.target.toInt()}",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height:10),

                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation(
                              Colors.deepPurple),
                    ),

                    const SizedBox(height:10),

                    Text(
                      "You're just ₹${remaining.toInt()} away!",
                      style: const TextStyle(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              );

            }),

            /// EMPTY STATE
            if(goals.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: const Column(
                children: [

                  Icon(
                    Icons.track_changes,
                    size: 50,
                    color: Colors.deepPurple,
                  ),

                  SizedBox(height:10),

                  Text(
                    "Set New Goals!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height:5),

                  Text(
                    "Tap the + button to add more goals",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}