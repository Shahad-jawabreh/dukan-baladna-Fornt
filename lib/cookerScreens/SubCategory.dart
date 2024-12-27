import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubCategoryPage extends StatefulWidget {
  final String categoryId;

  SubCategoryPage(this.categoryId, {Key? key}) : super(key: key);

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  late String apiUrl;

  @override
  void initState() {
    super.initState();
    apiUrl = "https://dukan-baladna.onrender.com/category/${widget.categoryId}/subCategory";
  }

  Future<List<dynamic>> fetchSubCategories() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['subCategories']; // تأكد من صحة المفتاح هنا
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Sub Categories'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchSubCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No subcategories found.'));
          } else {
            final subCategories = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عدد العناصر في كل صف
                  crossAxisSpacing: 10.0, // المسافة بين الأعمدة
                  mainAxisSpacing: 10.0, // المسافة بين الصفوف
                  childAspectRatio: 0.8, // نسبة العرض إلى الارتفاع
                ),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  final subCategory = subCategories[index];
                  return Card(
                    elevation: 5.0, // تأثير الظل
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // زوايا دائرية
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15.0),
                          ),
                          child: Image.network(
                            subCategory['image']['secure_url'],
                            height: 100.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            subCategory['name'],
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
