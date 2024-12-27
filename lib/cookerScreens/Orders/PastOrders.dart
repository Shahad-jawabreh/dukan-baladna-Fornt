import 'package:dukan_baladna/AbminScreen/AdminDashboard.dart';
import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For API requests
import 'package:intl/intl.dart';

import 'PastOrderDetails.dart'; // Details page
import 'OngoingOrder.dart'; // Ongoing orders page
import 'OrdersPage.dart'; // New orders page

class PastOrders extends StatefulWidget {
  const PastOrders({Key? key}) : super(key: key);

  @override
  _PastOrdersState createState() => _PastOrdersState();
}

class _PastOrdersState extends State<PastOrders> {
  List<dynamic> pastOrders = [];  // Change to List<dynamic>
  bool isLoading = true;
  String errorMessage = '';

  int _selectedTabIndex = 2;

  @override
  void initState() {
    super.initState();
    fetchPastOrders();
  }

  Future<void> fetchPastOrders() async {
    const apiUrl = 'http://10.0.2.2:4000/order/';
    print('Fetching ongoing orders...');
    try {
      // إعداد Headers مع المصادقة
      final headers = {
        'Authorization': 'brear_$token', // Fixed: correct the authorization key and handle null token
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers, // Adding headers here
      );

print(response.body);
if (response.statusCode == 200) {
  final data = json.decode(response.body); // Decode JSON response
  final orders = data['orders']; // Access 'orders' field from the response
  List<dynamic> filteredOrders = []; // List to store filtered orders

  for (var order in orders) {
      // Create a new order object with only the filtered products
        var filteredOrder = {
        'orderNum': order['orderNum'],
        'userName': order['userName'],
        'address': order['address'],
        '_id': order['_id'],
        'phoneNumber': order['phoneNumber'],
        'createdAt': order['createdAt'],
        'products': order['products'],
        'status': order['status'],
        'finalPrice' : order['finalPrice'],
      };
      if (order['status'] == "ملغي" || order['status'] == "تم التوصيل")
      filteredOrders.add(filteredOrder); // Add the filtered order to the list
    
  }

  setState(() {
    pastOrders = filteredOrders; // Update state with filtered orders
    isLoading = false; // Set loading state to false
  });
} else {
  setState(() {
    errorMessage = 'Failed to load past orders. Please try again later.';
    isLoading = false;
  });
}

    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("طلبات قديمة"),
        backgroundColor: const Color(0xFF94A96B),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF94A96B),
            child: Row(
              children: [
                buildTab("طلبات جديدة", 0, context),
                buildTab("الطلبات الجارية", 1, context),
                buildTab("طلبات قديمة", 2, context),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: pastOrders.length,
                        itemBuilder: (context, index) {
                          final order = pastOrders[index];
                          return buildOrderCard(order, context);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget buildTab(String title, int index, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => OngoingOrders()));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: _selectedTabIndex == index ? Colors.white : const Color(0xFF94A96B),
            border: _selectedTabIndex == index
                ? const Border(
                    bottom: BorderSide(
                      color: Color(0xFF94A96B),
                      width: 2.0,
                    ),
                  )
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _selectedTabIndex == index ? const Color(0xFF94A96B) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
String formatOrderDate(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) {
    return 'Unknown time';
  }

  try {
    // Parse the API-provided date string
    DateTime dateTime = DateTime.parse(createdAt);

    // Format it to show date and hour
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    return formattedDate;
  } catch (e) {
    // Handle any parsing errors
    return 'Invalid date';
  }
}
 Widget buildOrderCard(dynamic order, BuildContext context) {
    return Card(
    margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order['userName'] ?? 'غير معروف',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Cairo',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "رقم الطلب: ${order['orderNum'] ?? 'غير متوفر'}",
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Order Date
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16.0, color: Colors.blueGrey),
              const SizedBox(width: 6.0),
              Text(
                formatOrderDate(order['createdAt'] ?? 'وقت غير متوفر'),
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const Divider(height: 24.0, thickness: 1.0, color: Colors.grey),

          // Loop through products in the order and display each product's status
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order['products'].length,
            itemBuilder: (context, index) {
              var product = order['products'][index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? 'منتج غير معروف',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Cairo',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                             const SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                          "الكمية: ${product['quantity'] ?? 0} | \$${product['unitPrice'] ?? 0.0}",
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),)
                            ],
                          ),
                          const SizedBox(height: 4.0),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Button for entire order
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (order['status'] == 'ملغي' )
                Text(
                  "الحالة : ${order['status'] ?? 'غير متوفر'}",
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (order['status'] == 'تم التوصيل' )
                Text(
                  "الحالة : ${order['status'] ?? 'غير متوفر'}",
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PastOrderDetails(order: order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18.0),
                label: const Text(
                  "التفاصيل",
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                 
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}