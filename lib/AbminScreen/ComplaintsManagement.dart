import 'package:flutter/material.dart';
import '../globle.dart';
import 'ComplaintDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComplaintsManagement extends StatefulWidget {
  const ComplaintsManagement({Key? key}) : super(key: key);

  @override
  _ComplaintsManagementState createState() => _ComplaintsManagementState();
}

class _ComplaintsManagementState extends State<ComplaintsManagement> {
  List<Map<String, dynamic>> complaints = []; // Dynamic complaints list
  bool isLoading = true; // For loading indicator

  @override
  void initState() {
    super.initState();
    fetchComplaints(); // Fetch complaints when the page loads
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('https://dukan-baladna.onrender.com/complaint'), // Backend API endpoint
      headers: {
          'Authorization': 'brear_$token',
        }, 
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['complaints'];
        print(data);
        setState(() {
          complaints = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch complaints");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الشكاوى والاستفسارات'),
        backgroundColor: const Color(0xFF94A96B),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "قائمة الشكاوى",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : complaints.isEmpty
                    ? const Center(child: Text("لا توجد شكاوى حالياً"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: complaints.length,
                          itemBuilder: (context, index) {
                            final complaint = complaints[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  complaint['subject']?.toString() ?? 'لا يوجد عنوان',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "من: ${complaint['userName']?.toString() ?? 'غير معروف'}\n${complaint['date']?.toString() ?? ''}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ComplaintDetails(
                                          complaintId: complaint['_id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
