import 'package:dukan_baladna/globle.dart';
import 'package:dukan_baladna/customer/home_page.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // Import login.dart
import 'signup.dart'; // Import login.dart

class loginAndsignup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 52, 121, 40),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_restaurant,
                            color: Color.fromARGB(255, 52, 121, 40),
                            size: 50,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Dukan Baladna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Professional Business',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: () {
                      flagLog = true;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF9E79F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    ),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => signup()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFFF9E79F), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Color(0xFFF9E79F),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // Add the left arrow at the top
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
                 onPressed: () {
                 Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                
              },
            ),
          ),
        ],
      ),
    );
  }
}
