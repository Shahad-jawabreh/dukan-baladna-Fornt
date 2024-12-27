import 'dart:convert';
import 'package:dukan_baladna/AbminScreen/AdminDashboard.dart';
import 'package:dukan_baladna/notification/push_notification.dart';
import 'package:intl/intl.dart';
import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'OngoingOrder.dart'; // استيراد صفحة OngoingOrders
import 'PastOrders.dart'; // استيراد صفحة PastOrderPage
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OrdersPage extends StatefulWidget {
  
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
 List<dynamic> pendingOrders = []; // تغيير الاسم إلى pendingOrders
bool isLoading = true;
String errorMessage = '';

int _selectedTabIndex = 0; // افتراض التبويب الأول هو "New Orders"
String user ='';
@override
void initState() {
  super.initState();
  fetchPendingOrders(); // استدعاء الدالة الجديدة
}

Future<void> fetchPendingOrders() async {
  const apiUrl = 'http://10.0.2.2:4000/order/';
  print(token);
  try {
    final headers = {
      'Authorization': 'brear_$token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final orders = data['orders'];

      // Filter only pending orders
      List<dynamic> filteredOrders = orders.where((order) {
        return order['status'] == 'معلق'; // Include only pending orders
      }).toList();

      setState(() {
        pendingOrders = filteredOrders;
        isLoading = false;
        
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load orders. Please try again later.';
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
        title: const Text("New Orders"),
        backgroundColor: const Color(0xFF94A96B),
      ),
    body: Column(
      children: [
        Container(
          color: const Color(0xFF94A96B),
          child: Row(
            children: [
              buildTab("الطلبات الجديده", 0, context),
              buildTab("الطلبات الجارية", 1, context),
              buildTab("الطلبات القديمة", 2, context),
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
                      itemCount: pendingOrders.length,
                      itemBuilder: (context, index) {
                        final order = pendingOrders[index];
                        return buildOrderCard(order);
                      },
                    ),
        ),
      ],
    ),
  );
}
  // تصميم التبويبات
  Widget buildTab(String title, int index, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OngoingOrders()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PastOrders()),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: index == 0 ? Colors.white : Color(0xFF94A96B),
            border: index == 0
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
                color: index == 0 ? Color(0xFF94A96B) : Colors.white,
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

Future<void> changeStatusOrder(String orderId, String status,String user) async {
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
      print("Order status updated successfully.");
// Display success dialog
    saveNotificationDetails(userId,user,'individual','تم تغيير حالة طلبك', '') ;
    sendNotification('تم تغيير حالة طلبك', '', 'individual', userId,user);
      AwesomeDialog(
        context: context,
        title: status == 'ملغي'
            ? 'تم الغاء الطلب بنجاح'
            : 'تم تأكيد الطلب بنجاح',
        dialogType: DialogType.success,
        btnOkText: 'موافق',
        btnOkOnPress: () {},
      ).show();
    } else {
      print('Failed to update product status: ${response.body}');
      AwesomeDialog(
        context: context,
        title: 'خطأ في تحديث حالة المنتج',
        dialogType: DialogType.error,
        btnOkText: 'موافق',
        btnOkOnPress: () {},
      ).show();


    }
      setState(() {
        pendingOrders.removeWhere((order) => order['_id'] == orderId);
      });
  } catch (e) {
    print('Error occurred while updating product status: $e');
    AwesomeDialog(
      context: context,
      title: 'حدث خطأ أثناء تحديث حالة المنتج',
      dialogType: DialogType.error,
      btnOkText: 'موافق',
      btnOkOnPress: () {},
    ).show();
  }
}


void _makePhoneCall(String phoneNumber) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  
  try {
    // Check if the URL can be launched
    bool canLaunch = await canLaunchUrl(phoneUri);
    if (canLaunch) {
      await launchUrl(phoneUri);
    } else {
      print('Error: Could not launch $phoneUri');
      Fluttertoast.showToast(msg: 'Could not dial the number');
    }
  } catch (e) {
    print('Error occurred while trying to make a call: $e');
    Fluttertoast.showToast(msg: 'Error occurred while dialing');
  }
}


Widget buildOrderCard(Map<String, dynamic> order) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 219, 219, 223),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order['userName'] ?? 'Unknown Customer',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                "رقم الطلب: ${order['orderNum'] ?? 'N/A'}",
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            "رقم الهاتف : ${order['phoneNumber'] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          Text(
            "العنوان : ${order['address'] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12.0),

          // Order Date
          Text(
            formatOrderDate(order['createdAt'] ?? 'Unknown time'),
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          const Divider(height: 24.0, thickness: 1.0),
          Text(
            "حالة الطلب: ${order['status'] ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24.0, thickness: 1.0),

          // Product Details
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order['products']?.length ?? 0,
            itemBuilder: (context, index) {
              final item = order['products'][index];
              final productId = item['productId'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? 'Unknown Item',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "الكمية: ${item['quantity'] ?? 0} | \$${item['unitPrice'] ?? 0.0}",
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    
                  ],
                ),
              );
            },
          ),
          const Divider(height: 24.0, thickness: 1.0),
const SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            " السعر النهائي : \$${order['finalPrice'] ?? 0.0}",
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
          Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         // Call Button
                          ElevatedButton.icon(
                            onPressed: () {
                              final phoneNumber = order['phoneNumber']?.toString();
                              if (phoneNumber == null || phoneNumber.isEmpty) {
                                print('Error: Phone number is null or empty');
                                return;
                              }
                              _makePhoneCall(phoneNumber);
                            },
                            icon: const Icon(Icons.phone, size: 18),
                            label: const Text("Call"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final orderId = order['_id']?.toString();
                            if (orderId == null || orderId.isEmpty) {
                              print('Error: orderId is null or empty');
                              return;
                            }
                            changeStatusOrder(orderId, 'ملغي',order['userId']);
                          },
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final orderId = order['_id']?.toString();
                            if (orderId == null || orderId.isEmpty) {
                              print('Error: orderId is null or empty');
                              return;
                            }
                            changeStatusOrder(orderId, 'تم التأكيد',order['userId']);
                          },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text("Accept"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),

                        
                      ],
                    ),
        
        ],
      ),
    ),
  );
}
}