import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewResultsScreen extends StatefulWidget {
  @override
  State<ViewResultsScreen> createState() => _ViewResultsScreenState();
}

class _ViewResultsScreenState extends State<ViewResultsScreen> {
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'anonymous@student.com';

    final response = await http.get(
      Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/get_results/$email'),
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          results = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } catch (e) {
        print('Error parsing results: $e');
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse results')),
        );
      }
    } else {
      print('Failed to fetch results. Status code: ${response.statusCode}, Body: ${response.body}');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch results')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Results')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? Center(child: Text('No results found'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return ListTile(
                      title: Text('${r['title']} (${r['subject']})'),
                      subtitle: Text(
                          'Score: ${r['score']} / ${r['total_marks']}\nDate: ${r['submitted_at']}'),
                    );
                  },
                ),
    );
  }
}