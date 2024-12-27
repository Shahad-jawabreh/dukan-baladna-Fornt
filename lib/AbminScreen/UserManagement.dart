import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // لتحليل JSON
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
     try {
      final response = await http.get(
        Uri.parse('https://dukan-baladna.onrender.com/user/allusers'),
        headers: {
          'Authorization': 'brear_$token', // Replace with the actual token
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          users = data['user'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('إدارة المستخدمين'),
      backgroundColor: const Color(0xFF94A96B),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قائمة المستخدمين',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                              backgroundImage: user['image']?['secure_url'] != null
                                  ? NetworkImage(user['image']['secure_url'])
                                  : AssetImage('assets/defualtuser.jpg') as ImageProvider,
                            ),
                        title: Text(user['userName'] ?? 'غير متاح'), // Handle null
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('البريد الإلكتروني: ${user['email'] ?? 'غير متاح'}'), // Handle null
                            Text('الحالة: ${user['status'] ?? 'غير محدد'}'), // Handle null
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            print(user);
                            if (value == 'active') {
                              _changeStatus( user['_id'], 'active');
                            } else if (value == 'not_active') {
                              _changeStatus( user['_id'], 'not_active');
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'active',
                              child: Text('تفعيل الحساب'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'not_active',
                              child: Text('تعطيل الحساب'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('حذف الحساب'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
  );
}

// دالة لتغيير حالة الحساب (تفعيل/تعطيل)
void _changeStatus(String userId, String status) async {
  print(userId);

  try {
    final response = await http.patch(
      Uri.parse('https://dukan-baladna.onrender.com/user/allusers/$userId'),
      headers: {
        'Authorization': 'brear_$token', // استبدل بـ Token صالح
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    print(response.body);
    if (response.statusCode == 200) {
         Fluttertoast.showToast(
      msg: "Change successfully." ,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    } else {
      throw Exception('فشل في تحديث الحالة: ${response.body}');
    }
  } catch (e) {
    
  }
}

  
}