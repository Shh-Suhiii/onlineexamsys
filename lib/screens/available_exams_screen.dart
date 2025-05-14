import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart'; // Add this at the top if not already imported.

class AvailableExamsScreen extends StatefulWidget {
  @override
  State<AvailableExamsScreen> createState() => _AvailableExamsScreenState();
}

class _AvailableExamsScreenState extends State<AvailableExamsScreen> {
  List<Map<String, dynamic>> exams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/get_exams'));

      if (response.statusCode == 200) {
        print('Raw response body: ${response.body}');
        try {
          final body = response.body;
          if (body.isNotEmpty && !body.trim().startsWith('<')) {
            final List<dynamic> data = jsonDecode(body);
            setState(() {
              exams = data.map((e) => Map<String, dynamic>.from(e)).toList();
              isLoading = false;
            });
          } else {
            throw FormatException('Invalid response format');
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse exam data')),
          );
        }
      } else {
        debugPrint('Failed to load exams. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exams')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching exams: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        elevation: 4,
        title: Text(
          'Available Exams',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.lightBlue,
                    strokeWidth: 4,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Fetching exams...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : exams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // You can replace this with a real asset if available
                      Icon(Icons.menu_book, size: 100, color: Colors.lightBlueAccent),
                      SizedBox(height: 20),
                      Text(
                        'No exams available yet!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please check back later.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return TweenAnimationBuilder(
                      tween: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero),
                      duration: Duration(milliseconds: 500 + (index * 100)),
                      curve: Curves.easeOut,
                      builder: (context, offset, child) {
                        return Transform.translate(
                          offset: Offset(0, offset.dy * 20),
                          child: Opacity(
                            opacity: 1 - offset.dy,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Text(
                                      exam['title'][0].toUpperCase(),
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    exam['title'],
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Subject: ${exam['subject']}\nDuration: ${exam['duration']} mins | Marks: ${exam['total_marks']}',
                                      style: TextStyle(height: 1.5, color: Colors.grey[700]),
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Available',
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/exam', arguments: exam);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}