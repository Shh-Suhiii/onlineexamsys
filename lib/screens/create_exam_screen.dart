import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateExamScreen extends StatefulWidget {
  @override
  _CreateExamScreenState createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final durationController = TextEditingController();
  final totalMarksController = TextEditingController();

  List<Map<String, dynamic>> questions = [];

  void addQuestion() async {
    final result = await Navigator.pushNamed(context, '/add_question');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        questions.add(result);
      });
    }
  }


void saveExam() async {
  if (titleController.text.isEmpty ||
      subjectController.text.isEmpty ||
      durationController.text.isEmpty ||
      totalMarksController.text.isEmpty ||
      questions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please complete all fields and add questions.")),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/create_exam'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'title': titleController.text,
        'subject': subjectController.text,
        'duration': int.parse(durationController.text),
        'total_marks': int.parse(totalMarksController.text),
        'questions': questions
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exam Created Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create exam")),
      );
    }
  } catch (e, stacktrace) {
    print('Error creating exam: $e');
    print(stacktrace);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Exam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Exam Title'),
            ),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Duration (in minutes)'),
            ),
            TextField(
              controller: totalMarksController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Marks'),
            ),
            SizedBox(height: 20),
            Text('Questions Added: ${questions.length}'),
            ElevatedButton(
              onPressed: addQuestion,
              child: Text('Add Question'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveExam,
              child: Text('Save Exam'),
            ),
          ],
        ),
      ),
    );
  }
}