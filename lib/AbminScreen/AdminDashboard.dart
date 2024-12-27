import 'package:flutter/material.dart';
import 'Dashboard/OrdersBarChart.dart';  // For daily order chart
import 'Dashboard/PieChartWidget.dart';  // For top-selling products chart
import 'Dashboard/QuickStats.dart';  // For quick stats widget
import '../cookerScreens/Orders/OrdersPage.dart';  // Make sure to import the OrdersPage (or the screen to show orders)
import 'UserManagement.dart';
import 'HouseholdCooksManagement.dart';
import 'FoodManagement.dart';
import 'ComplaintsManagement.dart';
import 'SystemSitting/SystemSettings.dart';
import 'NotificationsManagment.dart';
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Color(0xFF94A96B),
        centerTitle: true,
      ),
      // Drawer (Sidebar)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF94A96B),
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              leading: const Icon(Icons.dashboard),
              onTap: () {
                Navigator.pop(context);  // Close the drawer after selection
              },
            ),
            ListTile(
              title: const Text('Orders'),  // Added "Orders" option
              leading: const Icon(Icons.receipt),  // Icon for orders
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),  // Navigate to OrdersPage
                );
              },
            ),
            ListTile(
  title: const Text('User Management'),
  leading: const Icon(Icons.manage_accounts),  // Icon for User Management
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  UserManagementPage()),  // Navigate to User Management screen
    );
  },
),
             ListTile(
              title: const Text('Household Cooks Management'), // Added Household Cooks Management option
              leading: const Icon(Icons.kitchen),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HouseholdCooksManagementPage()), // Navigate to HouseholdCooksManagementPage
                );
              },
            ),
               // إضافة خيار "إدارة الأكلات"
            ListTile(
              title: const Text(' Food Managment'),
              leading: const Icon(Icons.restaurant),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  FoodManagement()), 
                );
              },
            ),
            ListTile(
  title: const Text(' Complaints Managment'),
  leading: const Icon(Icons.report_problem),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComplaintsManagement()),
    );
  },
),
ListTile(
  title: const Text('System setting'),
  leading: const Icon(Icons.settings),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SystemSettings()),
    );
  },
),
ListTile(
  title: const Text('Notification Management'),
  leading: const Icon(Icons.notifications),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  NotificationsManagement()),
    );
  },
),

            // Add more menu items here as needed
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Section
              const Text(
                "Quick Stats",
                style: TextStyle(
                  fontSize: 22,  // Increased font size for consistency
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const QuickStats(),  // Quick Stats Widget

              const SizedBox(height: 20),

              // Charts Section
              const Text(
                "Charts",
                style: TextStyle(
                  fontSize: 22,  // Adjusted font size for title
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Daily Orders",
                style: TextStyle(
                  fontSize: 18,  // Adjusted size for subtitle
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 200, child: OrdersBarChart()),  // Orders Bar Chart

              const SizedBox(height: 20),
              const Text(
                "Top Selling Categories",
                style: TextStyle(
                  fontSize: 18,  // Adjusted size for subtitle
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 200, child: PieChartWidget()),  // Pie Chart Widget
            ],
          ),
        ),
      ),
    );
  }
}
