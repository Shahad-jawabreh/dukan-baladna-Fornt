// lib/screens/welcome_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import HomePage to navigate to it

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the animation as a scaling animation
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller!.forward();

    // Start a timer to navigate to HomePage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/1.png'), // Add the image path here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Positioned animated logo and loading indicator with welcome message
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6, // Adjust this value to move text down
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _animation!,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Welcome Text
                  Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  SizedBox(height: 30), // Space between text and loader
                  // Loading Indicator
                  CircularProgressIndicator(
                    color: Color(0xFF505632),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}