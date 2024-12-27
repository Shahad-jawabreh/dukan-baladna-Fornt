import 'dart:convert';
import 'package:dukan_baladna/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../globle.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final String baseUrl = "https://dukan-baladna.onrender.com";
  List<dynamic> cartProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>  login()),
        );
      });
    } else {
      fetchCart();
    }
  }
Future<void> fetchCart() async {
  setState(() => isLoading = true);

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/cart/$userId'),
      headers: {
        'Authorization': 'brear_$token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("Fetched cart data: ${jsonEncode(data)}");

      // Extract products from the cart
      if (data['cart'] != null && data['cart'] is List) {
        final cartList = data['cart'] as List;
        setState(() {
          // Combine all products from the cart
          cartProducts = cartList.isNotEmpty
              ? cartList[0]['products'] ?? [] // Get products from the first cart object
              : [];
              setState(() {
                cartCount = cartProducts.length;
              });
        });
      } else {
        debugPrint("Unexpected cart format: ${jsonEncode(data)}");
        setState(() {
          cartProducts = [];
        });
      }
    } else {
      debugPrint("Failed to fetch cart: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load cart: ${response.reasonPhrase}")),
      );
    }
  } catch (e) {
    debugPrint("Error fetching cart: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("An error occurred while fetching the cart.")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  Future<void> updateQuantity(String productId, String operator) async {
    try {
      print(productId);
      print(operator);
      final response = await http.put(
        Uri.parse('$baseUrl/cart/updateQuantity/$productId'),
        headers: {
          'Authorization': 'brear_$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'operator': operator}),
      );

      if (response.statusCode == 200) {
        fetchCart();
      } else {
        debugPrint("Failed to update quantity: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error updating quantity: $e");
    }
  }

  Future<void> deleteItem(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$productId'),
        headers: {
          'Authorization': 'brear_$token',
        },
      );

      if (response.statusCode == 200) {
        fetchCart();
      } else {
        debugPrint("Failed to delete item: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error deleting item: $e");
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('My Cart'),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context); // This will pop the current page from the navigation stack
    },
  ),
),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProducts.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : ListView.builder(
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    final productName = product['productName'] ?? 'Product Name';
                    final productImage = product['image'] ?? 'https://via.placeholder.com/150';
                    final productQuantity = product['quantity'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            productImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          productName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text('Quantity: $productQuantity'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => updateQuantity(product['productId'], "-"),
                            ),
                            Text('$productQuantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => updateQuantity(product['productId'], "+"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteItem(product['productId']),
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