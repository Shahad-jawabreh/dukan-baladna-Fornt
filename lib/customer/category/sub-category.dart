import 'package:dukan_baladna/customer/navbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ProductDetailsPage.dart'; // تأكد من إضافة استيراد صفحة التفاصيل

class SubCategoryPage extends StatefulWidget {
  final String categoryId;
  final String name;

  SubCategoryPage({required this.categoryId, required this.name, Key? key}) : super(key: key);

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  late String apiUrl;
  List<dynamic> allSubCategories = [];
  List<dynamic> displayedSubCategories = [];
  String searchQuery = "";
  String sortOption = "none";

  @override
  void initState() {
    super.initState();
    apiUrl = "https://dukan-baladna.onrender.com/product/?categoryId=${widget.categoryId}";
    fetchSubCategories();
  }

  Future<void> fetchSubCategories() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          allSubCategories = data['data'];
          displayedSubCategories = allSubCategories;
        });
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void filterResults(String query) {
    setState(() {
      searchQuery = query;
      displayedSubCategories = allSubCategories.where((subCategory) {
        final name = subCategory['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  void sortResults(String option) {
    setState(() {
      sortOption = option;
      if (option == "price") {
        displayedSubCategories.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
      } else if (option == "newest") {
        displayedSubCategories.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
      }
    });
  }

  void openSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Price'),
                onTap: () {
                  sortResults("price");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Newest'),
                onTap: () {
                  sortResults("newest");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: filterResults,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: openSortDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: displayedSubCategories.isEmpty
                ? Center(child: Text('No subcategories found.'))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: displayedSubCategories.length,
                      itemBuilder: (context, index) {
                        final subCategory = displayedSubCategories[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                    productId: subCategory['_id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15.0),
                                  ),
                                  child: Image.network(
                                    subCategory['mainImage']['secure_url'],
                                    height: 100.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        subCategory['name'],
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        "\$${subCategory['price']}",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.green,
                                        ),
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
          ),
        ],
      ),
    );
  }
}