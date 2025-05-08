import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class AdminStatsScreen extends StatefulWidget {
  @override
  _AdminStatsScreenState createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  int totalStudents = 0;
  int totalExams = 0;
  double averageScore = 0.0;
  bool isLoading = true;

  int range0to40 = 0;
  int range41to60 = 0;
  int range61to80 = 0;
  int range81to100 = 0;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final url = Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/admin_stats');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalStudents = data['total_students'];
          totalExams = data['total_exams'];
          averageScore = double.parse(data['average_score'].toString());
          range0to40 = data['distribution']['0-40'];
          range41to60 = data['distribution']['41-60'];
          range61to80 = data['distribution']['61-80'];
          range81to100 = data['distribution']['81-100'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stats: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Stats')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Students: $totalStudents', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Total Exams: $totalExams', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Average Score: $averageScore%', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 30),
                  Text('Score Distribution', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(sections: [
                        PieChartSectionData(value: range0to40.toDouble(), title: '0-40', color: Colors.red),
                        PieChartSectionData(value: range41to60.toDouble(), title: '41-60', color: Colors.orange),
                        PieChartSectionData(value: range61to80.toDouble(), title: '61-80', color: Colors.green),
                        PieChartSectionData(value: range81to100.toDouble(), title: '81-100', color: Colors.blue),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}