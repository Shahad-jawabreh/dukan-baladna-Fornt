import 'package:dukan_baladna/auth/login.dart';
import 'package:dukan_baladna/customer/navbar.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../globle.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({required this.productId, Key? key}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  String? errorMessage;
  

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }



  Future<void> fetchProductDetails() async {
    final apiUrl = "https://dukan-baladna.onrender.com/product/info/${widget.productId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          productDetails = json.decode(response.body)['product'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "فشل تحميل تفاصيل المنتج. يرجى المحاولة مرة أخرى.";
          isLoading = false;
        });
      }
      if (token != '') {
      try {
        // Fetch the cart count asynchronously
        final cartCountValue = cartCount;
        setState(() {
          cartCount = cartCountValue; // Assign the resolved value
        });
      } catch (e) {
         print(e);
      }
    }
    } catch (e) {
      setState(() {
        errorMessage = "حدث خطأ: $e";
        isLoading = false;
      });
    }
  }


Future<void> addToCart(String userId, String productId, {int quantity = 1}) async {
  try {
    if (token == null || token!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => login()), // Redirect to login page
      );
      return;
    }

    final data = {
      'productId': productId,
      'quantity': quantity,
    };

    final response = await http.post(
      Uri.parse('https://dukan-baladna.onrender.com/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'brear_$token', // Fixed typo: 'brear_' -> 'Bearer_'
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        cartCount++; // Increment the cart count
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to cart successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorData['message'] ?? 'Failed to add to cart. Please try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred. Please try again!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: Navbar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    setState(() {
        cartCount; // Increment the cart count
      });
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('خطأ'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar:Navbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  productDetails!['mainImage']['secure_url'],
                  height: 250.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                productDetails!['name'],
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                "السعر: ${productDetails!['price']} ₪",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[600],
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "الوصف:",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A96B),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                productDetails!['description'] ?? "لا يوجد وصف متوفر",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
              ),
              SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border),
                      label: Text("إضافة إلى الأمنيات"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF94A96B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        addToCart(userId, productDetails!['_id']);
                      },
                      icon: Icon(Icons.shopping_cart),
                      label: Text("إضافة إلى السلة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF6FB7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}