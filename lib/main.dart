import 'package:flutter/material.dart';
import 'package:onlineexamsys/screens/add_question_screen.dart';
import 'package:onlineexamsys/screens/all_results_screen.dart';
import 'package:onlineexamsys/screens/available_exams_screen.dart';
import 'package:onlineexamsys/screens/create_exam_screen.dart';
import 'package:onlineexamsys/screens/daily_quiz_screen.dart';
import 'package:onlineexamsys/screens/dashboard_screen.dart';
import 'package:onlineexamsys/screens/signup_screen.dart';
import 'package:onlineexamsys/screens/view_result_screen.dart';
import 'package:onlineexamsys/screens/forgot_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart'; // Will create soon
import 'package:onlineexamsys/screens/exam_instruction_screen.dart'
    as instruction;
import 'package:onlineexamsys/screens/start_exam_screen.dart' as start;
import 'package:onlineexamsys/screens/admin_stats_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Exam App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/dashboard': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userRole = args?['role'] ?? 'student';
          return DashboardScreen(userRole: userRole);
        },
        '/available_exams': (context) => AvailableExamsScreen(),
        '/exam': (context) => instruction.ExamInstructionsScreen(),
        '/start_exam': (context) => start.StartExamScreen(),
        '/create_exam': (context) => CreateExamScreen(),
        '/add_question': (context) => AddQuestionScreen(),
        '/view_results': (context) => ViewResultsScreen(),
        '/all_results': (context) => AllResultsScreen(),
        '/admin_stats': (context) => AdminStatsScreen(),
        '/daily_quiz': (context) => DailyQuizScreen(), // 👈 Add this line
      },
    );
  }
}
