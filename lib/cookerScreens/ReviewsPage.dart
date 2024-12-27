import 'package:dukan_baladna/notification/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dukan_baladna/globle.dart';

class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  // استرجاع البيانات من API
  Future<void> fetchReviews() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:4000/product/cooker/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // إرسال الرد إلى API
  Future<void> sendResponse(String reviewId, String response,receiver) async {
    try {
      final apiUrl = Uri.parse('$domain/review/$reviewId');
      final result = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json','Authorization': 'brear_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NzQzODA0ODY3ZGZjZjk0NzkzMzgxMDIiLCJyb2xlIjoic2FsZXIiLCJlbWFpbCI6ImFobWFkamF3YWJyZWgzM0BnbWFpbC5jb20iLCJpYXQiOjE3MzQ2Mzk3ODN9.dTw91WVnkYJEpBOcKzV4rcKkPg1dUonldje-zNUgsb0'},
        body: json.encode({'reply': response}),
      );
    
      if (result.statusCode == 200) {
        saveNotificationDetails(userId,receiver,"individual", "رد على تعليقك",response) ;
      } else {
        print('Failed to add reply');
      }
    } catch (error) {
      print('Error sending response: $error');
    }
  }

  // إضافة رد على التقييم
  void _addResponse(int productIndex, int reviewIndex, String reviewId, String response) {
    setState(() {
      products[productIndex]['reviews'][reviewIndex]['reply'] = response;
    });
    sendResponse(reviewId, response,products[productIndex]['reviews'][reviewIndex]['userId']['_id']); // استدعاء API لإرسال الرد
    Navigator.pop(context); // إغلاق نافذة الرد
  }

  // نافذة إدخال الرد
  void _showResponseDialog(int productIndex, int reviewIndex, String reviewId) {
    final TextEditingController responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('الرد على المراجعة'),
          content: TextField(
            controller: responseController,
            decoration: InputDecoration(
              hintText: 'اكتب ردك هنا...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (responseController.text.isNotEmpty) {
                  _addResponse(productIndex, reviewIndex, reviewId, responseController.text);
                }
              },
              child: Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقييمات والمراجعات'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(child: Text('لا توجد تقييمات حالياً.'))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: products.length,
                  itemBuilder: (context, productIndex) {
                    final product = products[productIndex]; // المنتج الحالي
                    final reviews = product['reviews'];
                   if (reviews.isEmpty) return SizedBox();
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اسم المنتج
                            Text(
                              product['name'] ?? 'منتج غير معروف',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 10),
                            // قائمة المراجعات
                            reviews.isEmpty
                                ? Text(
                                    'لا توجد مراجعات لهذا المنتج.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Column(
                                    children: reviews.asMap().entries.map<Widget>((entry) {
                                      final reviewIndex = entry.key;
                                      final review = entry.value;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  review['userName'] ?? 'مجهول',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (starIndex) => Icon(
                                                      Icons.star,
                                                      color: starIndex < review['rating']
                                                          ? Colors.orange
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              review['comment'] ?? '',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              DateTime.parse(review['createdAt'])
                                                  .toLocal()
                                                  .toString()
                                                  .split(' ')[0],
                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            SizedBox(height: 16),
                                            // الرد
                                            if (review['reply'] == null)
                                              ElevatedButton(
                                                onPressed: () => _showResponseDialog(
                                                    productIndex, reviewIndex, review['_id']),
                                                child: Text('الرد على المراجعة'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                              )
                                            else
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ردك:',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    review['reply'],
                                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'التقييمات والمراجعات',
    home: ReviewsPage(),
    theme: ThemeData(primarySwatch: Colors.green),
  ));
}
