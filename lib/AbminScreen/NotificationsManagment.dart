import 'dart:math';

import 'package:dukan_baladna/AbminScreen/AdminDashboard.dart';
import 'package:dukan_baladna/notification/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dukan_baladna/globle.dart';

class NotificationsManagement extends StatefulWidget {
  NotificationsManagement({Key? key}) : super(key: key);

  @override
  State<NotificationsManagement> createState() =>
      _NotificationsManagementState();
}

class _NotificationsManagementState extends State<NotificationsManagement> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  String? notificationType; // نوع الإشعار المحدد
  String? selectedUser; // المستخدم المحدد
  String? groupType; // المجموعة المحددة
  List<Map<String, dynamic>> users = [];
  // وظيفة لجلب المستخدمين من الـ API
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
        List<dynamic> fetchedUsers = json.decode(response.body)['user'];
        setState(() {
          users = fetchedUsers.map((user) {
            return {
              'userName': user['userName'].toString(),
              '_id': user['_id'].toString(),
              'image': user['image']?['secure_url']
                  .toString(), // رابط الصورة (أضف هذا في الـ API)
            };
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في جلب المستخدمين.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء جلب المستخدمين.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإشعارات'),
        backgroundColor: const Color(0xFF94A96B),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "إرسال إشعار",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "نوع الإشعار",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "general",
                  child: Text("إشعار عام"),
                ),
                DropdownMenuItem(
                  value: "individual",
                  child: Text("إشعار فردي"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  notificationType = value;
                  if (value == "individual") {
                    fetchUsers();
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            if (notificationType == "general")
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "اختر المجموعة",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "saler",
                    child: Text("ستات البيوت"),
                  ),
                  DropdownMenuItem(
                    value: "buyer",
                    child: Text("الزبائن"),
                  ),
                  DropdownMenuItem(
                    value: "delivery",
                    child: Text("الدليفري"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    groupType = value;
                  });
                },
              ),
            if (notificationType == "individual")
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "اختر المستخدم",
                  border: OutlineInputBorder(),
                ),
                items: users.map((user) {
                  print(user);
                  return DropdownMenuItem<String>(
                    value: user['_id'] ?? '',
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: user['image'] != null
                              ? NetworkImage(user['image'])
                              : AssetImage('assets/defualtuser.jpg')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Text(user['userName'] ?? 'Unknown'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUser = value;
                  });
                },
              ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "عنوان الإشعار",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "محتوى الإشعار",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    bodyController.text.isNotEmpty &&
                    notificationType != null) {
                  try {
                    if (notificationType == "individual") {
                      if (selectedUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى اختيار مستخدم.')),
                        );
                        return;
                      } else {
                        print(selectedUser);
                        print('----------------');
                        print(titleController.text);
                        print(bodyController);
                        await sendNotification(
                          titleController.text, // Example title
                          bodyController.text, // Example body
                          "individual", // Example notification type (can be dynamic based on your selection)
                          userId, // Example sender
                          selectedUser ?? '', // Example receiver
                        );
                      }
                    }
                    if (notificationType == "general") {
                      if (groupType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('يرجى اختيار المجموعة.')),
                        );
                        return;
                      } else {
                        await sendNotification(
                          titleController.text, // Example title
                          bodyController.text, // Example body
                          "general", // Example notification type (can be dynamic based on your selection)
                          userId, // Example sender
                          groupType ?? '', // Example receiver
                        );
                      }
                    }
                    // هنا تضيف منطق الإرسال
                    AwesomeDialog(
                      context: context,
                      title: "تم الإرسال بنجاح!",
                      dialogType: DialogType.success,
                      btnOkOnPress: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminDashboard()));
                      },
                    ).show();
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فشل في إرسال الإشعار.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى ملء جميع الحقول.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF94A96B),
              ),
              child: const Text("إرسال"),
            ),
          ],
        ),
      ),
    );
  }
}
