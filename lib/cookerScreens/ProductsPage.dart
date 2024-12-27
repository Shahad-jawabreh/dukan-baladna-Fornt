import 'package:dukan_baladna/cookerScreens/CategoryPage.dart';
import 'package:dukan_baladna/cookerScreens/ProductDetailsPage.dart';
import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<Product> filteredProducts = [];
  String? selectedFilter = 'عرض الكل';
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    final url = Uri.parse('$domain/product/cooker/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['data'];

      setState(() {
        products = jsonResponse.map((data) => Product.fromJson(data)).toList();
        filteredProducts = products;
      });
    } else {
      print('Failed to load products. Status Code: ${response.statusCode}');
      throw Exception('Failed to load products');
    }
  }

  void updateProductStatus(String productId, String newStatus) async {
    final url = Uri.parse('$domain/product/update/$productId');
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      setState(() {
        products.firstWhere((product) => product.id == productId).status =
            newStatus;
        filteredProducts = products;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم تحديث حالة المنتج بنجاح.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل تحديث حالة المنتج.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المنتجات'),
          backgroundColor: Colors.green.shade800,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                    filteredProducts = products.where((product) {
                      return product.name.contains(query);
                    }).toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن منتج...',
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.filter_list),
                        onSelected: (value) {
                          setState(() {
                            selectedFilter = value;
                            if (value == 'السعر') {
                              filteredProducts.sort((a, b) => a.price.compareTo(b.price));
                            } else if (value == 'التقييم') {
                              filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
                            } else if (value == 'عدد الطلبات') {
                              filteredProducts.sort((a, b) => b.ordersCount.compareTo(a.ordersCount));
                            } else if (value == 'الحالة') {
                              filteredProducts = products
                                  .where((product) => product.status == 'مفعل')
                                  .toList();
                            } else if (value == 'عرض الكل') {
                              filteredProducts = products;
                            }
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'عرض الكل', child: Text('عرض الكل')),
                          PopupMenuItem(value: 'السعر', child: Text('فرز حسب السعر')),
                          PopupMenuItem(value: 'التقييم', child: Text('فرز حسب التقييم')),
                          PopupMenuItem(value: 'عدد الطلبات', child: Text('فرز حسب عدد الطلبات')),
                          PopupMenuItem(value: 'الحالة', child: Text('عرض المنتجات المفعّلة')),
                        ],
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد منتجات متاحة.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Opacity(
                          opacity: product.status == "مفعل" ? 1.0 : 0.5,
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            color: product.status == "مفعل"
                                ? Colors.white
                                : Colors.grey.shade300,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              leading: Image.network(
                                product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image),
                              ),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: product.status == "مفعل"
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('السعر: ${product.price}\$'),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: product.status == "مفعل"
                                            ? Colors.amber
                                            : Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'التقييم: ${product.rating == null || product.rating == 0 ? 'لا يوجد تقييم' : product.rating}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: product.status == "مفعل"
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('عدد الطلبات: ${product.ordersCount}'),
                                  Text('الحالة: ${product.status}'),
                                ],
                              ),
                              trailing: product.status == "مفعل"
                                  ? Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey)
                                  : Icon(Icons.edit, size: 16, color: Colors.grey),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsPage(
                                      id: product.id,
                                      onUpdate: (updatedProduct) {},
                                    ),
                                  ),
                                );
                              },
                              onLongPress: product.status != "مفعل"
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('تفعيل المنتج'),
                                          content: Text(
                                              'هل تريد تغيير حالة المنتج إلى مفعّل؟'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                updateProductStatus(
                                                    product.id, "مفعل");
                                                Navigator.pop(context);
                                              },
                                              child: Text('نعم'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('لا'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductPage()),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green.shade800,
        ),
      ),
    );
  }
}

class Product {
  String name;
  String id;
  int price;
  double rating;
  int ordersCount;
  String imageUrl;
  String status;

  Product({
    required this.name,
    required this.id,
    required this.price,
    required this.rating,
    required this.ordersCount,
    required this.imageUrl,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    if (json['mainImage'] != null && json['mainImage']['secure_url'] != null) {
      imageUrl = json['mainImage']['secure_url'];
    }
    return Product(
      name: json['name'],
      id: json['_id'],
      price: json['price'],
      rating: json['rating'].toDouble(),
      ordersCount: json['orderCount'],
      imageUrl: imageUrl,
      status: json['status'],
    );
  }
}
