import 'package:flutter/material.dart';

class PrivacyPolicyEditor extends StatelessWidget {
  const PrivacyPolicyEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تعديل الشروط والسياسات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'اكتب الشروط والسياسات هنا...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // حفظ السياسات
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ الشروط والسياسات.')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
