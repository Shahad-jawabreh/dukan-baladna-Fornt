import 'dart:convert';
import 'package:dukan_baladna/customer/home_page.dart';
import 'package:dukan_baladna/auth/loginAndsiginup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../globle.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      // Redirect to login if no token is found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginAndsignup()),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://dukan-baladna.onrender.com/user/profile'),
        headers: {
          'Authorization': 'brear_$token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userProfileImage = data['image']?['secure_url'] ?? userProfileImage;
          userName = data['userName'] ?? userName;
          userEmail = data['email'] ?? userEmail;
        });
      } else {
        print('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userProfileImage.startsWith('http')
                  ? NetworkImage(userProfileImage)
                  : AssetImage(userProfileImage) as ImageProvider,
            ),
            SizedBox(height: 16),
            Text(
              userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Delete the token from SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                isLogin = false;
                // Navigate back to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
