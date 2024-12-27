import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الدعم الفني'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تواصل معنا',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email, color: Colors.green),
              title: Text('support@example.com'),
              subtitle: Text('للدعم عبر البريد الإلكتروني'),
              onTap: () {
                // افتح البريد الإلكتروني
                launchUrl('mailto:support@example.com' as Uri);
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('+123456789'),
              subtitle: Text('للدعم عبر الهاتف'),
              onTap: () {
                // إجراء اتصال
                launchUrl('tel:+123456789' as Uri);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.green),
              title: Text('الدردشة المباشرة'),
              subtitle: Text('تحدث معنا مباشرة'),
              onTap: () {
                // افتح صفحة دردشة أو نظام دعم
              },
            ),
          ],
        ),
      ),
    );
  }
}
