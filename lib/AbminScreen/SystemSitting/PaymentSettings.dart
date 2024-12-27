import 'package:flutter/material.dart';

class PaymentSettings extends StatelessWidget {
  const PaymentSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات بوابات الدفع',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('PayPal'),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          ListTile(
            title: const Text('Stripe'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          ListTile(
            title: const Text('Visa/MasterCard'),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
        ],
      ),
    );
  }
}
