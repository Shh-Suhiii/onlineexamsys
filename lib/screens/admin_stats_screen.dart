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
    final url = Uri.parse('https://09f6-152-58-96-35.ngrok-free.app/admin_stats');
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
      appBar: AppBar(
        title: Text('Admin Stats', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Icon(Icons.refresh),
            tooltip: 'Refresh Stats',
            onPressed: isLoading
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });
                    await fetchStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stats refreshed successfully!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.all(16),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
          ),
        ],
      ),
      backgroundColor: Color(0xFFF2F6FF),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Overall Progress',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                        SizedBox(height: 20),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: averageScore / 100),
                          duration: Duration(milliseconds: 800),
                          builder: (context, value, child) => Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              ),
                              Text('${averageScore.toStringAsFixed(1)}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  buildStatCard('Total Students', totalStudents.toString(), Icons.person, Colors.indigo),
                  SizedBox(height: 16),
                  buildStatCard('Total Exams', totalExams.toString(), Icons.edit_note, Colors.orange),
                  SizedBox(height: 16),
                  buildStatCard('Average Score', '$averageScore%', Icons.star_rate, Colors.green),
                  SizedBox(height: 30),
                  Text(
                    'Score Distribution',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 800),
                    tween: Tween(begin: 0.8, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: SizedBox(
                      height: 250,
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                    value: range0to40.toDouble(), title: '0-40', color: Colors.redAccent),
                                PieChartSectionData(
                                    value: range41to60.toDouble(), title: '41-60', color: Colors.orangeAccent),
                                PieChartSectionData(
                                    value: range61to80.toDouble(), title: '61-80', color: Colors.lightGreen),
                                PieChartSectionData(
                                    value: range81to100.toDouble(), title: '81-100', color: Colors.blueAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Top Performer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Student Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text('Score: 95%', style: TextStyle(fontSize: 16, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}