import 'dart:convert';
import 'package:dukan_baladna/cookerScreens/ProductsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globle.dart';
import 'CategoryPage.dart';
import 'EarningsPage.dart';
import './Orders/OrdersPage.dart';
import 'profilePage.dart';
import 'package:http/http.dart' as http;
import 'ReviewsPage.dart';
import 'SupportPage.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {


  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
   // final token = prefs.getString('auth_token');

print(token);

    try {
      final response = await http.get(
        Uri.parse('$domain/user/profile'),
        headers: {
          'Authorization': 'brear_$token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

     setState(() {
    userProfileImage = data['image']?['secure_url'] ?? userProfileImage;
    userId = data['_id'];
    userName = data['userName'] ?? 'Unknown User';
    phoneNumber = data['phoneNumber'] ?? 'Unknown User';
    address = data['address'] ?? 'Unknown User';
    userEmail = data['email'] ?? 'No Email';
     });

      } else {
        print('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userProfileImage.startsWith('http')
                  ? NetworkImage(userProfileImage)
                  : AssetImage(userProfileImage) as ImageProvider,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.green.shade400],
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'الملف الشخصي',
              onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            _buildDrawerItem(
                icon: Icons.shopping_bag,
                title: 'المنتجات',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductsPage()));
                }),
                
            _buildDrawerItem(
                icon: Icons.shopping_bag,
                title: 'اضافة منتج',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddProductPage()));
                }),
                
            _buildDrawerItem(
              icon: Icons.receipt,
              title: 'الطلبات',
              onTap: () {  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OrdersPage()));},
            ),
            
            _buildDrawerItem(
              icon: Icons.attach_money,
              title: 'الأرباح و التحصيل',
              onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EarningsPage()));
              },
            ),
            
            _buildDrawerItem(
              icon: Icons.comment,
              title: 'الآراء',
              onTap: () {  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ReviewsPage()));},
            ),
            
            Spacer(),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              onTap: () {},
              color: Colors.red,
            ),
            _buildDrawerItem(
  icon: Icons.help_outline,
  title: 'الدعم الفني',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SupportPage()),
    );
  },
),

          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('الأداء'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard('الطلبات', '120', Colors.blue),
                _buildSummaryCard('المنتجات', '45', Colors.orange),
                _buildSummaryCard('الأرباح', '2500\$+', Colors.green),
              ],
            ),
            SizedBox(height: 20),
            _buildSectionHeader('الإشعارات'),
            SizedBox(height: 10),
            _buildNotificationTile(
              'طلب جديد',
              'تم استلام طلب جديد من العميل X',
              Colors.red.shade600,
            ),
            _buildNotificationTile(
              'تعليق جديد',
              'تم إضافة تعليق على منتجك Y',
              Colors.green.shade600,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Function() onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.green.shade800),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade800,
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 100,
        height: 120,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(String title, String subtitle, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.notifications, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'لوحة التحكم',
    home: DashboardPage(),
    theme: ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: Colors.grey.shade100,
      fontFamily: 'Cairo',
    ),
  ));
}
