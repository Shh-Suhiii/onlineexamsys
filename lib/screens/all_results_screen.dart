import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllResultsScreen extends StatefulWidget {
  @override
  State<AllResultsScreen> createState() => _AllResultsScreenState();
}

class _AllResultsScreenState extends State<AllResultsScreen> {
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> filteredResults = [];

  bool isLoading = true;

  String selectedExam = 'All';
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllResults();
  }

  Future<void> fetchAllResults() async {
    try {
      final response = await http.get(
        Uri.parse('https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/get_all_results'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          results = data.map((e) => Map<String, dynamic>.from(e)).toList();
          filteredResults = List.from(results);
          isLoading = false;
        });
      } else {
        // Log status code and response body
        print('Failed to fetch results. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch results')));
      }
    } catch (e) {
      // Log the exception
      print('Exception in fetchAllResults: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred while fetching results')));
    }
  }

  void applyFilters() {
    String email = emailController.text.toLowerCase();

    setState(() {
      filteredResults =
          results.where((r) {
            final examMatch =
                selectedExam == 'All' || r['title'] == selectedExam;
            final emailMatch = r['email'].toLowerCase().contains(email);
            return examMatch && emailMatch;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> examTitles = [
      'All',
      ...{...results.map((r) => r['title'].toString())},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('All Student Results')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Filters
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedExam,
                            decoration: InputDecoration(
                              labelText: 'Filter by Exam',
                            ),
                            items:
                                examTitles.map((title) {
                                  return DropdownMenuItem<String>(
                                    value: title,
                                    child: Text(title),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              selectedExam = value!;
                              applyFilters();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Filter by Email',
                            ),
                            onChanged: (value) => applyFilters(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final url = 'https://aeab-2409-40d2-100c-306b-10c7-3851-9d3d-f5c.ngrok-free.app/download_results_pdf';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch PDF download')),
                          );
                        }
                      },
                      icon: Icon(Icons.download),
                      label: Text('Download Results as PDF'),
                    ),
                    SizedBox(height: 20),
                    // Result List
                    Expanded(
                      child:
                          filteredResults.isEmpty
                              ? Center(child: Text('No matching results'))
                              : ListView.builder(
                                itemCount: filteredResults.length,
                                itemBuilder: (context, index) {
                                  final r = filteredResults[index];
                                  return ListTile(
                                    title: Text(
                                      '${r['title']} (${r['subject']})',
                                    ),
                                    subtitle: Text(
                                      'Email: ${r['email']}\nScore: ${r['score']} / ${r['total_marks']}\nDate: ${r['submitted_at']}',
                                    ),
                                    isThreeLine: true,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
