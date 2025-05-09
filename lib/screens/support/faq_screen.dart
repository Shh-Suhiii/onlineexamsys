import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Center(child: Text('Frequently Asked Questions')),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildFAQ('How to register for an exam?', 'Go to Available Exams and select the exam you want.'),
          buildFAQ('What happens if I close the app during an exam?', 'It will automatically submit your progress.'),
          buildFAQ('Can I retake the daily quiz?', 'You can only attempt once per day.'),
        ],
      ),
    );
  }

  Widget buildFAQ(String question, String answer) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 8),
            Text(
              answer,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}