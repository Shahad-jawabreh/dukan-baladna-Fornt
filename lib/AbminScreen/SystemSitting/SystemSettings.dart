import 'package:flutter/material.dart';
import 'FeesSettings.dart';
import 'PaymentSettings.dart';
import 'PrivacyPolicyEditor.dart';
import 'ThemeSettings.dart';

class SystemSettings extends StatelessWidget {
  const SystemSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // عدد الصفحات الفرعية
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات النظام'),
          backgroundColor: const Color(0xFF94A96B),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.policy), text: 'السياسات'),
              Tab(icon: Icon(Icons.monetization_on), text: 'الرسوم'),
              Tab(icon: Icon(Icons.payment), text: 'الدفع'),
              Tab(icon: Icon(Icons.palette), text: 'المظهر'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrivacyPolicyEditor(), // صفحة السياسات
            FeesSettings(),        // صفحة الرسوم
            PaymentSettings(),     // صفحة الدفع
            ThemeSettings(),       // صفحة المظهر
          ],
        ),
      ),
    );
  }
}
