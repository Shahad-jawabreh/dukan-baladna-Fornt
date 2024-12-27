import 'package:flutter/material.dart';
import 'package:dukan_baladna/customer/cart/cart.dart';
import 'package:dukan_baladna/customer/category/category.dart';
import 'package:dukan_baladna/notification/NotificationPage.dart';
import 'package:dukan_baladna/customer/profilePage.dart';
import 'package:dukan_baladna/auth/loginAndsiginup.dart';
import '../globle.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Navbar extends StatefulWidget implements PreferredSizeWidget { // Implement PreferredSizeWidget

  @override
  _NavbarState createState() => _NavbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Set the height of the AppBar
}
class _NavbarState extends State<Navbar> {
  bool _isDataFetched = false; // Flag to track if data is fetched already

  @override
  void initState() {
    super.initState();
print('fff');
    // Fetch data only if it's not fetched yet
    if (isLogin && !_isDataFetched) {
      numberOfItemInsideCart(userId);
      fetchNotificationCount();
      _isDataFetched = true;  // Set the flag to true after fetching
    }
  }

  Future<void> fetchNotificationCount() async {
    const notificationApiUrl = "https://dukan-baladna.onrender.com/notification";
    try {
      final response = await http.get(
        Uri.parse(notificationApiUrl),
        headers: {
          'Authorization': 'brear_$token', // Ensure 'Bearer_' is correct
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['notifications'] != null) {
          final unseenCount = data['notifications']
              .where((notification) => notification['status'] == 'unseen')
              .length;

          if (notificationCount != unseenCount) {
            setState(() {
              notificationCount = unseenCount;
            });
          }
        }
      } else {
        throw Exception('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        notificationCount = 0;
      });
    }
  }

  Future<void> numberOfItemInsideCart(String userId) async {
    final cartApiUrl = "https://dukan-baladna.onrender.com/cart/$userId";
    try {
      final response = await http.get(
        Uri.parse(cartApiUrl),
        headers: {
          'Authorization': 'brear_$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['cart'] != null && data['cart'].isNotEmpty) {
          final products = data['cart'][0]['products'];
          int count = products.length;
          if (cartCount != count) {
            setState(() {
              cartCount = count;
            });
          }
        } else {
          setState(() {
            cartCount = 0;
          });
        }
      } else {
        throw Exception('Failed to load cart items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() {
        cartCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF347928),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryPage()),
              );
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
  'Duken Baladna',
  style: TextStyle(
    color: Colors.white,      
    fontWeight: FontWeight.bold,  
    fontSize: 23,           
  ),
  textAlign: TextAlign.center,  
),

          ),
          const SizedBox(width: 10),
          if (isLogin) ...[
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage()),
                    );
                  },
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          GestureDetector(
            onTap: () {
              if (isLogin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => loginAndsignup()),
                );
              }
            },
            child: isLogin
                ? CircleAvatar(
                    backgroundImage: userProfileImage != 'assets/defualtuser.jpg'
                        ? NetworkImage(userProfileImage)
                        : const AssetImage('assets/defualtuser.jpg')
                            as ImageProvider,
                    radius: 20,
                  )
                : const Icon(Icons.login, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
