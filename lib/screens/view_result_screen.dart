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
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'anonymous@student.com';

    final response = await http.get(
      Uri.parse('https://09f6-152-58-96-35.ngrok-free.app/get_results/$email'),
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          results = data.map((e) => Map<String, dynamic>.from(e)).toList();
          results.sort((a, b) => b['submitted_at'].compareTo(a['submitted_at'])); // Sort latest first
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
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Text('My Results', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? Center(
                  child: Text(
                    'No results found!',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search results...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: searchController.text.isNotEmpty
                                ? IconButton(
                                    key: ValueKey('clear'),
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        searchQuery = '';
                                      });
                                    },
                                  )
                                : SizedBox.shrink(key: ValueKey('empty')),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final r = results[index];
                          final title = r['title']?.toString().toLowerCase() ?? '';
                          final subject = r['subject']?.toString().toLowerCase() ?? '';
                          if (searchQuery.isNotEmpty &&
                              !title.contains(searchQuery) &&
                              !subject.contains(searchQuery)) {
                            return SizedBox.shrink();
                          }

                          final double score = (r['score'] as num).toDouble();
                          final double total = (r['total_marks'] as num).toDouble();
                          final bool isPassed = (score / total) >= 0.5;

                          return TweenAnimationBuilder<Offset>(
                            duration: Duration(milliseconds: 500),
                            tween: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero),
                            curve: Curves.easeOut,
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: Offset(0, offset.dy * 20),
                                child: child,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    isPassed ? Icons.check_circle : Icons.cancel,
                                    color: isPassed ? Colors.green : Colors.red,
                                    size: 30,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${r['title']} (${r['subject']})',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Score: ${r['score']} / ${r['total_marks']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Submitted At: ${r['submitted_at']}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}