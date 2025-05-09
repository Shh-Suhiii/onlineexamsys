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
        SnackBar(
          content: Text('Please fill all fields and select the correct answer'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Question Saved!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
      );

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context); // Close the success dialog
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
      });
    // ignore: unused_catch_stack
    } catch (e, stack) {
      // Optionally: print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving question: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Text('Add Question', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600),
            tween: Tween(begin: 0.9, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Enter Question Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        SizedBox(height: 20),
                        buildTextField('Question', questionController),
                        SizedBox(height: 12),
                        buildTextField('Option A', optionAController),
                        SizedBox(height: 12),
                        buildTextField('Option B', optionBController),
                        SizedBox(height: 12),
                        buildTextField('Option C', optionCController),
                        SizedBox(height: 12),
                        buildTextField('Option D', optionDController),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          key: ValueKey(getOptions().join()),
                          value: correctAnswer,
                          hint: Text('Select Correct Answer'),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: getOptions().map((option) {
                            return DropdownMenuItem(value: option, child: Text(option));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              correctAnswer = value;
                            });
                          },
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: Text('Save Question', style: TextStyle(fontSize: 18)),
                            onPressed: saveQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}