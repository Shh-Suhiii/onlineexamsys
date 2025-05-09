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
  int previousQuestionIndex = 0;
  Timer? _timer;
  int remainingTime = 60 * 5; // 5 minutes in seconds

  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  Map<int, String> selectedAnswers = {};

  bool _isInit = true;
  bool _submitted = false;
  bool isAutoSubmitted = false;
  int currentQuestionIndex = 0;
  bool showCelebration = false;

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

      final response = await http.get(Uri.parse('https://09f6-152-58-96-35.ngrok-free.app/get_questions/$examId'));

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
      Uri.parse('https://09f6-152-58-96-35.ngrok-free.app/submit_result'),
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


    int minutes = remainingTime ~/ 60;
    int seconds = remainingTime % 60;

    return Scaffold(
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Text('Exam In Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('$minutes:${seconds.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 18))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: (currentQuestionIndex + 1) / questions.length,
              ),
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                minHeight: 8,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Center(
              child: Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            SizedBox(height: 12),
            if (showCelebration)
              Center(
                child: Icon(Icons.celebration, size: 40, color: Colors.amber),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(currentQuestionIndex > previousQuestionIndex ? 1.0 : -1.0, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: Container(
                  key: ValueKey(currentQuestionIndex),
                  margin: EdgeInsets.symmetric(vertical: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Q${currentQuestionIndex + 1}: ${questions[currentQuestionIndex]['question_text']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12),
                      ...[
                        questions[currentQuestionIndex]['option_a'],
                        questions[currentQuestionIndex]['option_b'],
                        questions[currentQuestionIndex]['option_c'],
                        questions[currentQuestionIndex]['option_d'],
                      ].map((option) => Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: RadioListTile<String>(
                              value: option,
                              groupValue: selectedAnswers[currentQuestionIndex],
                              title: Text(option),
                              activeColor: Colors.lightBlueAccent,
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[currentQuestionIndex] = value!;
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        previousQuestionIndex = currentQuestionIndex;
                        currentQuestionIndex--;
                      });
                    },
                    child: Text('Previous', style: TextStyle(color: Colors.white),),
                  ),
                if (currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        previousQuestionIndex = currentQuestionIndex;
                        currentQuestionIndex++;
                        if (currentQuestionIndex == questions.length - 1) {
                          showCelebration = true;
                          Future.delayed(Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                showCelebration = false;
                              });
                            }
                          });
                        }
                      });
                    },
                    child: Text('Next', style: TextStyle(color: Colors.white),),
                  ),
                if (currentQuestionIndex == questions.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: submitExam,
                    child: Text('Submit Exam', style: TextStyle(color: Colors.white),),
                  ),
              ],
            ),
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
    double percentage = (correct / total) * 100;
    IconData resultIcon;
    String resultMessage;

    if (percentage >= 80) {
      resultIcon = Icons.emoji_events; // Trophy
      resultMessage = "Outstanding performance!";
    } else if (percentage >= 50) {
      resultIcon = Icons.celebration; // Celebration
      resultMessage = "Good job, keep going!";
    } else {
      resultIcon = Icons.fitness_center; // Motivation
      resultMessage = "Don't give up, try again!";
    }

    return Scaffold(
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Text('Exam Result', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(resultIcon, color: Colors.orange, size: 50),
            SizedBox(height: 10),
            Text(
              resultMessage,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'You scored $correct out of $total',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percentage),
              duration: Duration(seconds: 2),
              builder: (context, value, child) => Column(
                children: [
                  LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 50 ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${value.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  bool isCorrect = selectedAnswers[index] == q['correct_answer'];
                  // Use question_text if available, else fallback to question or empty string
                  final questionText = q['question_text'] ?? q['question'] ?? '';
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${index + 1}: ${questionText}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text("Your Answer: ${selectedAnswers[index] ?? 'Not Answered'}"),
                        Text("Correct Answer: ${q['correct_answer']}"),
                        SizedBox(height: 6),
                        Text(
                          isCorrect ? "✅ Correct" : "❌ Incorrect",
                          style: TextStyle(
                            color: isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Retake Exam
                  },
                  child: Text('Retake Exam'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst); // Go Home
                  },
                  child: Text('Go Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}