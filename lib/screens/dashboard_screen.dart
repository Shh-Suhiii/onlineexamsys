import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'student_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  final String userRole;

  DashboardScreen({required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(userRole == "admin" ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text('Dashboard - $userRole', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
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
            padding: const EdgeInsets.all(8.0),
            child: userRole == "admin" ? AdminDashboard() : StudentDashboard(),
          ),
        ),
      ),
    );
  }
}