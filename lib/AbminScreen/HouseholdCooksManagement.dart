import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HouseholdCooksManagementPage extends StatefulWidget {
  @override
  _HouseholdCooksManagementPageState createState() =>
      _HouseholdCooksManagementPageState();
}

class _HouseholdCooksManagementPageState
    extends State<HouseholdCooksManagementPage> {
  List<dynamic> cooks = [];
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
          'Authorization': 'brear_$token', // Replace with actual token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // Filter the users by role 'saler'
          cooks = data['user']
              .where((user) => user['role'] == 'saler')
              .toList();
          isLoading = false;
        });
        print("User data: $cooks");
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
        title: const Text('إدارة ستات البيوت'),
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
                    'قائمة ستات البيوت',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cooks.length,
                      itemBuilder: (context, index) {
                        var cook = cooks[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: cook['image']?['secure_url'] != null
                                  ? NetworkImage(cook['image']['secure_url'])
                                  : AssetImage('assets/defualtuser.jpg') as ImageProvider,
                            ),

                            title: Text(cook['userName'] ?? 'غير متاح'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('البريد الإلكتروني: ${cook['email']}'),
                                Text('رقم الهاتف: ${cook['phoneNumber']}'),
                                Text('التقييم: ${cook['rating']}'),
                                Text('العمولة: ${cook['commission']}'),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'approve') {
                                  _approveCook(
                                      context, cook['userName'], cook['_id']);
                                } else if (value == 'block') {
                                  _blockCook(
                                      context, cook['userName'], cook['_id']);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'approve',
                                  child: Text('موافقة الحساب'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'block',
                                  child: Text('حظر الحساب'),
                                ),
                              ],
                            ),
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

  void _approveCook(BuildContext context, String cookName, String cookId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$cookName - الموافقة على الحساب'),
          content: const Text('هل ترغب في الموافقة على هذا الحساب؟'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _changeStatus(cookId, 'active');
              },
              child: const Text('نعم'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('لا'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeStatus(String userId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('https://dukan-baladna.onrender.com/user/allusers/$userId'),
        headers: {
          'Authorization': 'brear_$token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
   print("Response: ${response.body}");
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "تم تغيير الحالة بنجاح",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        // Update local state if needed
      } else {
        throw Exception('فشل في تحديث الحالة: ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "حدث خطأ أثناء تحديث الحالة",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _blockCook(BuildContext context, String cookName, String cookId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$cookName - حظر الحساب'),
          content: const Text('هل أنت متأكد أنك ترغب في حظر هذا الحساب؟'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _changeStatus(cookId, 'not_active');
              },
              child: const Text('نعم'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('لا'),
            ),
          ],
        );
      },
    );
  }
}