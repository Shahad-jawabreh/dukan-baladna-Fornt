import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart'; // Import LoginPage to navigate to it

class signup extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<signup> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://dukan-baladna.onrender.com/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Signup successful: $responseData');
      
      // Show a snackbar and navigate to the login page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful! Please login.')),
      );

      // Delay to allow the snackbar to be visible before navigating
      await Future.delayed(Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => login()),
      );
    } else {
      print('Signup failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 52, 121, 40),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20),
            Text(
              'Hi !\nCreate an Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            _buildTextField(_usernameController, 'Username'),
            SizedBox(height: 20),
            _buildTextField(_emailController, 'Email'),
            SizedBox(height: 20),
            _buildTextField(_passwordController, 'Password', isObscure: true),
            SizedBox(height: 20),
            _buildTextField(_confirmPasswordController, 'Confirm Password', isObscure: true),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF9E79F),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text(
                        'SIGN UP',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Color(0xFFF9E79F)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a styled text field
  Widget _buildTextField(TextEditingController controller, String label, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isObscure ? Icon(Icons.visibility, color: Colors.grey) : null,
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}