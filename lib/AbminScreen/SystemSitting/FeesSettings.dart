import 'package:flutter/material.dart';
class FeesSettings extends StatelessWidget {
  const FeesSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات الرسوم والعمولات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'النسبة المئوية للعمولة...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // حفظ إعدادات الرسوم
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ إعدادات الرسوم.')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
