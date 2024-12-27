import 'dart:async';
import 'dart:convert'; // To parse JSON
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dukan_baladna/customer/category/sub-category.dart'; 

import 'package:http/http.dart' as http;

class CategoryPage extends StatelessWidget {
  final List<Map<String, String>> popularPalestinianDishes = [
 
  ];

  final List<String> newPalestinianDishes = [
    'Chicken Mjabbas',
    'Grape Leaves',
    'Kunafa Nabulsieh',
  ];

  Future<List<Map<String, String>>> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse("https://dukan-baladna.onrender.com/category"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['category'];
        return data.map<Map<String, String>>((item) {
          return {
             '_id': item['_id'] ?? '',
            'name': item['name'] ?? '',
            'image': item['image']?['secure_url'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  elevation: 0,
  backgroundColor: Color.fromARGB(255, 52, 121, 40),
  title: Text(
    'Dukan Baldna',
    style: GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 23,
      color: Colors.white,
    ),
  ),
  centerTitle: true,
  leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white), // شكل السهم
    onPressed: () {
      Navigator.pop(context); // العودة إلى الصفحة السابقة
    },
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Favorite Dish',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.orange,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Popular'),
                      Tab(text: 'All Categories'),
                      Tab(text: 'New Dishes'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        // Popular Palestinian Dishes Tab
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: popularPalestinianDishes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.asset(
                                      popularPalestinianDishes[index]['image']!,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      popularPalestinianDishes[index]['name']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // All Categories Tab with FutureBuilder
                        FutureBuilder<List<Map<String, String>>>(
                          future: fetchCategories(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                              return Center(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationZ(3.14159),  // Rotate the text by 180 degrees
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No categories found.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 10), // Add some spacing between the two texts
                                      Text(
                                        'لا توجد فئات',
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center, // Center the Arabic text
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final category = snapshot.data![index];
                                  print(category);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                         builder: (context) => SubCategoryPage(
                                            categoryId: category['_id'] ?? '673a5c0529b5456d90cfe347',
                                            name: category['name'] ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(
                                              category['image']!,
                                              width: double.infinity,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              category['name']!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                        // New Dishes Tab
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: newPalestinianDishes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    newPalestinianDishes[index],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// صفحة التفاصيل
class CategoryDetailPage extends StatelessWidget {
  final String name;
  final String image;

  const CategoryDetailPage({Key? key, required this.name, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(image),
            const SizedBox(height: 20),
            Text(
              name,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}