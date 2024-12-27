import 'package:dukan_baladna/cookerScreens/DashboardPage.dart';
import 'package:dukan_baladna/globle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
    theme: ThemeData(
      primaryColor: Colors.green, // اللون الأخضر
      scaffoldBackgroundColor: Colors.white, // خلفية بيضاء
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.black),
      ),
    ),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController repPasswordController;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with global variables
    nameController = TextEditingController(text: userName);
    phoneController = TextEditingController(text: phoneNumber);
    emailController = TextEditingController(text: userEmail);
    passwordController = TextEditingController();
    repPasswordController = TextEditingController();
  }

  Future<void> editProfile(String name, String phone, String email, String imagePath, String password, String repPassword) async {
    if (password != repPassword) {
      AwesomeDialog(
        context: context,
        title: 'خطأ',
        desc: 'كلمة المرور غير متطابقة',
        dialogType: DialogType.error,
        btnOkText: 'موافق',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      print("Sending request...");
      print(userId);
      // Create the URI for the API endpoint
      var uri = Uri.parse("$domain/user/profile/$userId");

      // Create a multipart request
      var request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'brear_$token'; // Replace with actual token if needed

      // Add form fields to the request
      request.fields['userName'] = name;
      request.fields['phoneNumber'] = phone;
      request.fields['email'] = email;
      request.fields['password'] = password;
      // Add image to the request if available
      if (imagePath.isNotEmpty) {
        var imageFile = await http.MultipartFile.fromPath('image', imagePath);
        request.files.add(imageFile);
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          title: '!تم التعديل بنجاح ',
          dialogType: DialogType.success,
          btnOkOnPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ).show();
        return;
      } else {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        if (data['message'] == 'email is already exists') {
          AwesomeDialog(
            context: context,
            title: 'خطأ',
            desc: 'هذا الايميل مخصص لشخص آخر',
            dialogType: DialogType.error,
            btnOkText: 'موافق',
            btnOkOnPress: () {},
          ).show();
          return;
        }
      }
    } catch (e) {
      print("Error: $e"); // طباعة الخطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // صورة شخصية
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery); // تغيير getImage إلى pickImage
                setState(() {
                  if (pickedFile != null) {
                    _imagePath = pickedFile.path;
                  }
                });
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imagePath.isNotEmpty ? FileImage(File(_imagePath)) : null,
                child: _imagePath.isEmpty ? Icon(Icons.camera_alt, color: Colors.green) : null,
              ),
            ),
            SizedBox(height: 20),

            // اسم المستخدم
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'الاسم'),
            ),
            SizedBox(height: 10),

            // رقم الهاتف
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),

            // البريد الإلكتروني
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),

            // كلمة المرور
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
              obscureText: true,
            ),
            SizedBox(height: 10),

            // إعادة كلمة المرور
            TextField(
              controller: repPasswordController,
              decoration: InputDecoration(labelText: 'إعادة كلمة المرور'),
              obscureText: true,
            ),
            SizedBox(height: 10),

            // زر حفظ التعديلات
            ElevatedButton(
              onPressed: () {
                // Update global variables with the new values
                userName = nameController.text;
                phoneNumber = phoneController.text;
                userEmail = emailController.text;
                String password = passwordController.text;
                String repPassword = repPasswordController.text;
                if(password != repPassword) {
                     AwesomeDialog(
                      context: context,
                      title:  'كلمة السر غير متطابقه',
                      dialogType: DialogType.error,
                      btnOkOnPress: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()));
                      },
                    ).show();
                }else
                editProfile(userName, phoneNumber, userEmail, _imagePath, password, repPassword);
              },
              child: Text('حفظ التعديلات'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
