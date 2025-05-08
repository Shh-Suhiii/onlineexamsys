import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response = await http.get(Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/get_exams'));

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
      appBar: AppBar(title: Text('Available Exams')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? Center(child: Text('No exams available'))
              : ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(exam['title']),
                        subtitle: Text(
                          'Subject: ${exam['subject']}\nDuration: ${exam['duration']} mins | Marks: ${exam['total_marks']}',
                        ),
                        trailing: Text(
                          'Available',
                          style: TextStyle(color: Colors.green),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/exam', arguments: exam);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}