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
        Uri.parse('http://127.0.0.1:5000/get_all_results'),
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
      backgroundColor: Color(0xFFF2F6FF),
      appBar: AppBar(
        title: Text(
          'All Student Results',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 4,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filters
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: selectedExam,
                                  decoration: InputDecoration(
                                    labelText: 'Filter by Exam',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: examTitles.map((title) {
                                    return DropdownMenuItem<String>(
                                      value: title,
                                      child: Text(title, overflow: TextOverflow.ellipsis),
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
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onChanged: (value) => applyFilters(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url = 'http://127.0.0.1:5000/download_results_pdf';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Could not launch PDF download')),
                                  );
                                }
                              },
                              icon: Icon(Icons.download),
                              label: Text('Download Results as PDF', style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 1.5),
                  SizedBox(height: 10),
                  // Result List
                  Expanded(
                    child: filteredResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 80, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  'No matching results found!',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchAllResults,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.8, end: 1.0),
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeOutBack,
                              builder: (context, scale, child) {
                                return Transform.scale(scale: scale, child: child);
                              },
                              child: ListView.builder(
                                itemCount: filteredResults.length,
                                itemBuilder: (context, index) {
                                  final r = filteredResults[index];
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 4,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      title: Text(
                                        '${r['title']} (${r['subject']})',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Email: ${r['email']}\nScore: ${r['score']} / ${r['total_marks']}\nDate: ${r['submitted_at']}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      isThreeLine: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
