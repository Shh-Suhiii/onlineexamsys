import 'package:flutter/material.dart';
import 'package:onlineexamsys/screens/start_exam_screen.dart';

class ExamInstructionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routeData = ModalRoute.of(context)?.settings.arguments;
    final exam = routeData != null && routeData is Map<String, dynamic>
        ? routeData
        : {
            'title': 'Unknown Exam',
            'subject': 'Unknown',
            'duration': '0 mins',
            'totalMarks': 0,
            'status': 'Unknown'
          };

    return Scaffold(
      appBar: AppBar(
        title: Text('${exam['title']} Instructions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subject: ${exam['subject']}", style: TextStyle(fontSize: 18)),
            Text("Duration: ${exam['duration']}", style: TextStyle(fontSize: 18)),
            Text("Total Marks: ${exam['totalMarks']}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Please read the instructions carefully:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("• Do not refresh or exit the app during the exam."),
            Text("• Each question is mandatory."),
            Text("• Your answers will be auto-submitted if time runs out."),
            Text("• Do not switch apps during the exam session."),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  try {
                    // ignore: unused_local_variable
                    final routes = Navigator.of(context).widget.observers
                        .whereType<NavigatorObserver>()
                        .toList();
                    final hasStartExamRoute = Navigator.of(context).widget is MaterialApp &&
                        (Navigator.of(context).widget as MaterialApp).routes?.containsKey('/start_exam') == true;

                    if (hasStartExamRoute) {
                      Navigator.pushNamed(context, '/start_exam', arguments: exam);
                    } else {
                      // Fallback: push a direct widget if route not registered
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartExamScreen(),
                          settings: RouteSettings(arguments: exam),
                        ),
                      );
                    }
                  } catch (e) {
                    print('Navigation error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to start the exam. Please try again.')),
                    );
                  }
                },
                child: Text('Start Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}