import 'package:dukan_baladna/AbminScreen/AdminDashboard.dart';
import 'package:dukan_baladna/cookerScreens/DashboardPage.dart';
import 'package:dukan_baladna/customer/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'customer/welcome_screen.dart'; // Correct path to your WelcomePage
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto', // Set global font for the app
      ),
      home: DashboardPage(),
      locale: Locale('ar'), // Arabic locale, which defaults to RTL text direction
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'AE'), // Add Arabic language support
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
