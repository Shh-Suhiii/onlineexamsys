import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StartExamScreen extends StatefulWidget {
  @override
  _StartExamScreenState createState() => _StartExamScreenState();
}

class _StartExamScreenState extends State<StartExamScreen> {
  int currentQuestionIndex = 0;
  Timer? _timer;
  int remainingTime = 60 * 5; // 5 minutes in seconds

  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  Map<int, String> selectedAnswers = {};

  bool _isInit = true;
  bool _submitted = false;
  bool isAutoSubmitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      fetchQuestions();
      _isInit = false;
    }
  }

  Future<void> fetchQuestions() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == null || args is! Map<String, dynamic>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid exam data')),
        );
        return;
      }
      final exam = args;
      if (!exam.containsKey('exam_id')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam ID missing')),
        );
        return;
      }
      final examId = exam['exam_id'];

      final response = await http.get(Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/get_questions/$examId'));

      final body = response.body;
      print('Question fetch response: $body');
      if (body.isEmpty || body.trim().startsWith('<')) {
        throw FormatException('Invalid or empty response');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(body);
        setState(() {
          questions = data.map((q) => Map<String, dynamic>.from(q)).toList();
          isLoading = false;
          startTimer();
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions')),
        );
      }
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions')),
      );
    }
  }

  void startTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime == 0 && !_submitted) {
        isAutoSubmitted = true;
        _timer?.cancel();
        submitExam();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

void submitExam() async {
  if (_submitted) return;
  _submitted = true;
  if (_timer?.isActive ?? false) {
    _timer?.cancel();
  }
  int correct = 0;
  for (int i = 0; i < questions.length; i++) {
    if (selectedAnswers[i] == questions[i]['correct_answer']) {
      correct++;
    }
  }

  final exam = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  final examId = exam['exam_id'];

  // Get student email from SharedPreferences (set after login)
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email') ?? 'anonymous@student.com';

  try {
    final response = await http.post(
      Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/submit_result'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'exam_id': examId,
        'email': email,
        'score': correct,
        'total': questions.length,
      }),
    );

    if (response.statusCode == 200) {
      if (isAutoSubmitted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Time’s Up'),
            content: Text('The exam was auto-submitted due to timeout.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExamResultScreen(
            total: questions.length,
            correct: correct,
            questions: questions,
            selectedAnswers: selectedAnswers,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit result')),
      );
    }
  } catch (e) {
    print('Error submitting result: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit result')),
    );
  }
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Exam In Progress')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Exam In Progress')),
        body: Center(child: Text('No questions available')),
      );
    }

    var question = questions[currentQuestionIndex];
    List<String> options = [
      question['option_a'],
      question['option_b'],
      question['option_c'],
      question['option_d'],
    ];

    int minutes = remainingTime ~/ 60;
    int seconds = remainingTime % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text('Exam In Progress'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('$minutes:${seconds.toString().padLeft(2, '0')}')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Q${currentQuestionIndex + 1}: ${question['question']}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ...List.generate(options.length, (i) {
              String option = options[i];
              return RadioListTile<String>(
                value: option,
                groupValue: selectedAnswers[currentQuestionIndex],
                title: Text(option),
                onChanged: (value) {
                  setState(() {
                    selectedAnswers[currentQuestionIndex] = value!;
                  });
                },
              );
            }),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentQuestionIndex > 0
                      ? () => setState(() => currentQuestionIndex--)
                      : null,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? () => setState(() => currentQuestionIndex++)
                      : null,
                  child: Text('Next'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitExam,
                child: Text('Submit Exam'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ExamResultScreen extends StatelessWidget {
  final int total;
  final int correct;
  final List<Map<String, dynamic>> questions;
  final Map<int, String> selectedAnswers;

  ExamResultScreen({
    required this.total,
    required this.correct,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exam Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You scored $correct out of $total', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Correct Answers: $correct'),
            Text('Incorrect Answers: ${total - correct}'),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return ListTile(
                    title: Text("Q${index + 1}: ${q['question']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your Answer: ${selectedAnswers[index] ?? 'Not Answered'}"),
                        Text("Correct Answer: ${q['correct_answer']}"),
                        Text(
                          selectedAnswers[index] == q['correct_answer']
                              ? "✅ Correct"
                              : "❌ Incorrect",
                          style: TextStyle(
                            color: selectedAnswers[index] == q['correct_answer']
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}