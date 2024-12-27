import 'dart:convert';
import 'package:dukan_baladna/AbminScreen/AdminDashboard.dart';
import 'package:dukan_baladna/notification/push_notification.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'OngoingOrderDetails.dart'; // استيراد صفحة تفاصيل الطلبات الجارية
import 'PastOrders.dart'; // استيراد صفحة الطلبات الماضية
import 'OrdersPage.dart'; // استيراد صفحة New Order
import 'package:awesome_dialog/awesome_dialog.dart';

class OngoingOrders extends StatefulWidget {
  const OngoingOrders({Key? key}) : super(key: key);

  @override
  _OngoingOrdersState createState() => _OngoingOrdersState();
}

class _OngoingOrdersState extends State<OngoingOrders> {
  List<dynamic> ongoingOrders = []; // Change to List<dynamic>
  bool isLoading = true;
  String errorMessage = '';
  int _selectedTabIndex = 1;
  String user = '';
  @override
  void initState() {
    super.initState();
    fetchOngoingOrders();
    
  }

  Future<void> fetchOngoingOrders() async {
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


if (response.statusCode == 200) {
  final data = json.decode(response.body); // Decode JSON response
  final orders = data['orders']; // Access 'orders' field from the response
  List<dynamic> filteredOrders = []; // List to store filtered orders

  for (var order in orders) {
      // Create a new order object with only the filtered products
        var filteredOrder = {
        'orderNum': order['orderNum'],
        'userName': order['userName'],
        'userId': order['userId'],
        'address': order['address'],
        '_id': order['_id'],
        'phoneNumber': order['phoneNumber'],
        'createdAt': order['createdAt'],
        'products': order['products'],
         'status': order['status'],
         'finalPrice' : order['finalPrice'],
      };
      if (order['status'] == "في الطريق" || order['status'] == "تم التأكيد" || order['status'] == "تم ارسالة للتوصيل")
      filteredOrders.add(filteredOrder); // Add the filtered order to the list
    
  }

  setState(() {
    ongoingOrders = filteredOrders; // Update state with filtered orders
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
  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("الطلبات"),
      backgroundColor: const Color(0xFF94A96B),
      centerTitle: true,
    ),
    body: Column(
      children: [
        Container(
          color: const Color(0xFF94A96B),
          child: Row(
            children: [
              buildTab("طلبات جديده", 0, context),
              buildTab("الطلبات قيد التنفيذ", 1, context),
              buildTab("طلبات قديمة", 2, context),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ongoingOrders.isEmpty
                  ? Center(child: Text(errorMessage.isEmpty ? 'No ongoing orders' : errorMessage))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: ongoingOrders.length,
                      itemBuilder: (context, index) {
                        final order = ongoingOrders[index];
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
          // Navigate to New Order page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrdersPage()),
          );
        } else if (index == 1) {
          // Remain on the current page for Ongoing Orders
        } else if (index == 2) {
          // Navigate to the Past Orders page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PastOrders()),
          );
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
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر الإلغاء في الزاوية اليسرى
        if (order['status'] != 'ملغي')
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 28.0),
            onPressed: () async {
           AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'هل متأكد من حذف الطلب؟',
            btnCancelOnPress: () {},
            btnOkOnPress: () async{await updateOrderStatus(order['_id'], 'ملغي',order['userId']);},
            ).show();

              
            },
          ),
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

    // تاريخ الطلب
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

    // عرض المنتجات في الطلب
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
              // اسم المنتج
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
                          ),
                        )
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

    // أزرار التحكم في الطلب
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (order['status'] != 'تم ارسالة للتوصيل')
          ElevatedButton.icon(
            onPressed: () async {
              await updateOrderStatus(order['_id'], 'تم ارسالة للتوصيل',order['userId']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            icon: const Icon(Icons.delivery_dining, size: 18.0),
            label: const Text(
              "إرسال الطلب للتوصيل",
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        if (order['status'] == 'تم ارسالة للتوصيل')
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
                builder: (context) => OngoingOrderDetails(order: order),
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






Future<void> updateOrderStatus(String orderId,String status,String user) async {
  final apiUrl = '$domain/order/$orderId';
  final url = Uri.parse(apiUrl);

  // Body to update the product status
  final body = json.encode({
    'status': status,
  });

  try {
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'brear_$token', // Ensure correct token
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
    saveNotificationDetails(userId,user,'individual','تم تغيير حالة طلبك', '') ;
    sendNotification('تم تغيير حالة طلبك', '', 'individual', userId,user);
      if(status == 'تم ارسالة للتوصيل')
       setState(() {
        var order = ongoingOrders.firstWhere((order) => order['_id'] == orderId);
        order['status'] = 'تم ارسالة للتوصيل';
      });
      else{
         setState(() {
           ongoingOrders.removeWhere((order) => order['_id'] == orderId);

      });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في إرسال الطلب للتوصيل. حاول مرة أخرى.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("خطأ: $e")),
    );
  }
}
}