import 'package:flutter/material.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خيارات المظهر',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('الوضع الفاتح'),
            trailing: Radio(value: 'light', groupValue: 'theme', onChanged: (value) {}),
          ),
          ListTile(
            title: const Text('الوضع الداكن'),
            trailing: Radio(value: 'dark', groupValue: 'theme', onChanged: (value) {}),
          ),
        ],
      ),
    );
  }
}
