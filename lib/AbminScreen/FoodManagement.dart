import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodManagement extends StatefulWidget {
  FoodManagement({Key? key}) : super(key: key);

  @override
  _FoodManagementState createState() => _FoodManagementState();
}

class _FoodManagementState extends State<FoodManagement> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> foods = [];
  String selectedCategory = 'كل الأطباق';
  String selectedCategoryId = ''; // This should hold the ID associated with the category

  static const String categoriesUrl = 'https://dukan-baladna.onrender.com/category';
  static const String productsUrl = 'https://dukan-baladna.onrender.com/product';

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the widget is initialized
  }

  // Function to fetch categories
  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(categoriesUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['category'] ?? []);
          if (categories.isNotEmpty) {
            selectedCategoryId = categories[0]['_id'];
            selectedCategory = categories[0]['name']; // Set the name to match
          }
          _fetchFoods(selectedCategoryId); // Fetch foods for the initial category
        });
      } else {
        _showError('فشل في تحميل التصنيفات');
      }
    } catch (error) {
      _showError('خطأ في الاتصال بالإنترنت');
    }
  }

  // Function to fetch foods based on category ID
  Future<void> _fetchFoods(String categoryId) async {
    final url = categoryId.isEmpty ? productsUrl : '$productsUrl/?categoryId=$categoryId';
     print(url);
    try {
      final response = await http.get(Uri.parse(url));
       print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          foods = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      } else {
        _showError('فشل في تحميل الأطعمة');
      }
    } catch (error) {
      _showError('خطأ في الاتصال بالإنترنت');
    }
  }

  // Show an error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأكلات'),
        backgroundColor: Color(0xFF94A96B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'قائمة الأكلات',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown to select category
            DropdownButtonFormField<String>(
              value: selectedCategoryId, // Use ID as the value
              decoration: const InputDecoration(
                labelText: 'اختر التصنيف',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['_id'], // Use category ID for value
                  child: Text(category['name']), // Show category name
                );
              }).toList(),
              onChanged: (newCategoryId) {
                setState(() {
                  selectedCategoryId = newCategoryId!;
                  selectedCategory = categories.firstWhere((category) => category['_id'] == newCategoryId)['name'];
                });
                _fetchFoods(selectedCategoryId); // Fetch foods when category is selected
              },
            ),

            const SizedBox(height: 20),

            // Display the list of foods
            Expanded(
              child: foods.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        var food = foods[index];
                        return Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                            child: food['mainImage']?['secure_url'] != null
                          ? Image.network(
                              food['mainImage']['secure_url'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/defaultuser.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),

                            ),
                            title: Text(food['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('السعر: ${food['price']}'),
                                Text('الطباخة: ${food['salerName']}'),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editFood(context, food['name']);
                                } else if (value == 'delete') {
                                  _deleteFood(context, food['name']);
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('تعديل الأكلة'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('حذف الأكلة'),
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
      ),
    );
  }

  void _editFood(BuildContext context, String foodName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل الأكلة: $foodName'),
          content: const Text('يمكنك تعديل تفاصيل الأكلة هنا.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تعديل الأكلة بنجاح')),
                );
              },
              child: const Text('تعديل'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFood(BuildContext context, String foodName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف الأكلة: $foodName'),
          content: const Text('هل أنت متأكد من أنك ترغب في حذف هذه الأكلة؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  
                  const SnackBar(content: Text('تم حذف الأكلة بنجاح')),
                );
              },
              child: const Text('نعم'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لا'),
            ),
          ],
        );
      },
    );
  }
}
