import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../globle.dart';

class ComplaintDetails extends StatefulWidget {
  final String complaintId;

  const ComplaintDetails({required this.complaintId, Key? key}) : super(key: key);

  @override
  _ComplaintDetailsState createState() => _ComplaintDetailsState();
}

class _ComplaintDetailsState extends State<ComplaintDetails> {
  Map<String, dynamic>? complaint;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaintDetails();
  }

  Future<void> fetchComplaintDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://dukan-baladna.onrender.com/complaint/${widget.complaintId}'),
         headers: {
          'Authorization': 'brear_$token',
        },
      );
      print(response);
      if (response.statusCode == 200) {
        setState(() {
          complaint = json.decode(response.body)['complaints'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load complaint details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الشكوى'),
        backgroundColor: const Color(0xFF94A96B),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaint == null
              ? const Center(child: Text('Failed to load complaint details.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "عنوان الشكوى: ${complaint!['subject']}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "تفاصيل الشكوى:\n${complaint!['details'] ?? 'لا يوجد تفاصيل'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "الحالة: ${complaint!['status']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: complaint!['status'] == 'Pending'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("تم الرد على الشكوى.")),
                          );
                        },
                        child: const Text("رد على الشكوى"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("تم حذف الشكوى.")),
                          );
                        },
                        child: const Text("حذف الشكوى"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
