import 'package:flutter/material.dart';

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  String? correctAnswer;

  List<String> getOptions() {
    return [
      optionAController.text,
      optionBController.text,
      optionCController.text,
      optionDController.text
    ].where((opt) => opt.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    optionAController.addListener(() => setState(() {}));
    optionBController.addListener(() => setState(() {}));
    optionCController.addListener(() => setState(() {}));
    optionDController.addListener(() => setState(() {}));
  }

  void saveQuestion() {
    if (questionController.text.isEmpty ||
        optionAController.text.isEmpty ||
        optionBController.text.isEmpty ||
        optionCController.text.isEmpty ||
        optionDController.text.isEmpty ||
        correctAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select the correct answer')),
      );
      return;
    }

    try {
      Navigator.pop(context, {
        'question': questionController.text,
        'options': [
          optionAController.text,
          optionBController.text,
          optionCController.text,
          optionDController.text
        ],
        'answer': correctAnswer
      });
    // ignore: unused_catch_stack
    } catch (e, stack) {
      // Optionally: print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving question: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: questionController, decoration: InputDecoration(labelText: 'Question')),
            TextField(controller: optionAController, decoration: InputDecoration(labelText: 'Option A')),
            TextField(controller: optionBController, decoration: InputDecoration(labelText: 'Option B')),
            TextField(controller: optionCController, decoration: InputDecoration(labelText: 'Option C')),
            TextField(controller: optionDController, decoration: InputDecoration(labelText: 'Option D')),
            SizedBox(height: 20),
            StatefulBuilder(
              builder: (context, setInnerState) {
                return DropdownButtonFormField<String>(
                  key: ValueKey(getOptions().join()),
                  value: correctAnswer,
                  hint: Text('Select Correct Answer'),
                  items: getOptions().map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
                  onChanged: (value) {
                    setInnerState(() {
                      correctAnswer = value;
                    });
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveQuestion,
              child: Text('Save Question'),
            )
          ],
        ),
      ),
    );
  }
}