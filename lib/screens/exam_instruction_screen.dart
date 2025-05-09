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
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Text(
          '${exam['title']} Instructions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subject: ${exam['subject']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text("Duration: ${exam['duration']}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text("Total Marks: ${exam['totalMarks']}", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Please read the instructions carefully:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  instructionItem("Do not refresh or exit the app during the exam."),
                  instructionItem("Each question is mandatory."),
                  instructionItem("Your answers will be auto-submitted if time runs out."),
                  instructionItem("Do not switch apps during the exam session."),
                ],
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  try {
                    Navigator.of(context).push(PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) => StartExamScreen(),
                      settings: RouteSettings(arguments: exam),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ));
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

Widget instructionItem(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, color: Colors.lightBlueAccent, size: 22),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    ),
  );
}