import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';

class DailyQuizScreen extends StatefulWidget {
  @override
  _DailyQuizScreenState createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  final PageStorageKey quizKey = PageStorageKey("quiz_screen");

  String selectedAnswer = '';
  int currentQuestionIndex = 0;
  int score = 0;

  Timer? _timer;
  int timeLeft = 15;
  bool showResult = false;
  List<Map<String, String>> userAnswers = [];

  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> quizQuestions = [
    {
      'question': 'What is the capital of France?',
      'options': ['Berlin', 'Madrid', 'Paris', 'Rome'],
      'answer': 'Paris',
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Earth', 'Venus', 'Mars', 'Jupiter'],
      'answer': 'Mars',
    },
    {
      'question': 'Who wrote "Romeo and Juliet"?',
      'options': ['Shakespeare', 'Homer', 'Dickens', 'Austen'],
      'answer': 'Shakespeare',
    },
  ];

  @override
  void initState() {
    super.initState();
    quizQuestions.shuffle();
    startTimer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void startTimer() {
    timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft == 0) {
          _timer?.cancel();
          submitAnswer();
        }
      });
    });
  }

  void submitAnswer() {
    final currentQuestion = quizQuestions[currentQuestionIndex];
    userAnswers.add({
      'question': currentQuestion['question'],
      'selected': selectedAnswer,
      'correct': currentQuestion['answer'],
    });

    if (selectedAnswer == currentQuestion['answer']) {
      score++;
    }

    if (currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = '';
        showResult = false;
        startTimer();
      });
    } else {
      _timer?.cancel();
      showReviewDialog();
    }
  }

  void showReviewDialog() {
    if (score == quizQuestions.length) {
      _confettiController.play();
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Review',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 12),
                Card(
                  elevation: 3,
                  color: Colors.indigo[50],
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Icon(Icons.emoji_events, color: Colors.indigo),
                    title: Text(
                      'Your Score',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$score out of ${quizQuestions.length}'),
                        SizedBox(height: 4),
                        Text(
                          score == quizQuestions.length
                              ? 'Excellent! 🎉'
                              : (score >= quizQuestions.length / 2 ? 'Good job!' : 'Keep practicing!'),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Your Answers:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userAnswers.length,
                    itemBuilder: (context, index) {
                      final answer = userAnswers[index];
                      final isCorrect = answer['selected'] == answer['correct'];
                      return Card(
                        color: isCorrect ? Colors.green[50] : Colors.red[50],
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            'Q${index + 1}: ${answer['question']}',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text('Your answer: ${answer['selected'] ?? "No answer"}'),
                              Text('Correct answer: ${answer['correct']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          currentQuestionIndex = 0;
                          score = 0;
                          selectedAnswer = '';
                          userAnswers.clear();
                          showResult = false;
                          quizQuestions.shuffle();
                          startTimer();
                        });
                      },
                      child: Text('Retry', style: TextStyle(color: Colors.indigo)),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Close', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = quizQuestions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Today's Quiz")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Quiz',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: timeLeft <= 5 ? 24 : 18,
                      ),
                      child: Text('Time Left: $timeLeft sec'),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / quizQuestions.length,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: buildQuestionCard(currentQuestion),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestionCard(Map<String, dynamic> currentQuestion) {
    return Column(
      key: ValueKey(currentQuestionIndex),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q${currentQuestionIndex + 1}. ${currentQuestion['question']}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Column(
          children: (currentQuestion['options'] as List<String>).map((option) {
            return RadioListTile<String>(
              title: Text(
                option,
                style: showResult
                    ? TextStyle(
                        color: option == currentQuestion['answer']
                            ? Colors.green
                            : (option == selectedAnswer ? Colors.red : null),
                      )
                    : null,
              ),
              value: option,
              groupValue: selectedAnswer,
              onChanged: showResult
                  ? null
                  : (value) {
                      setState(() {
                        selectedAnswer = value!;
                      });
                    },
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: selectedAnswer.isEmpty
              ? null
              : () {
                  _timer?.cancel();
                  setState(() {
                    showResult = true;
                  });
                  Future.delayed(Duration(seconds: 1), submitAnswer);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(currentQuestionIndex == quizQuestions.length - 1 ? 'Finish Quiz' : 'Next'),
        ),
      ],
    );
  }
}