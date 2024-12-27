import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true; // حالة الإشعارات
  bool deliveryOptionPersonal = true; // خيار شخصيًا
  bool deliveryOptionDelivery = false; // خيار الديليفري
  TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0); // وقت البداية
  TimeOfDay endTime = TimeOfDay(hour: 18, minute: 0); // وقت النهاية

  // اختيار وقت العمل
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تفعيل/إيقاف الإشعارات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفعيل الإشعارات',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            Divider(),

            // اختيار طرق التوصيل
            Text(
              'طرق التوصيل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: Text('شخصيًا'),
              value: deliveryOptionPersonal,
              onChanged: (value) {
                setState(() {
                  deliveryOptionPersonal = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: Text('عبر الديليفري'),
              value: deliveryOptionDelivery,
              onChanged: (value) {
                setState(() {
                  deliveryOptionDelivery = value ?? false;
                });
              },
            ),
            Divider(),

            // ضبط أوقات العمل
            Text(
              'أوقات العمل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text('وقت البدء: ${startTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () {
                _selectTime(context, true);
              },
            ),
            ListTile(
              title: Text('وقت الانتهاء: ${endTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () {
                _selectTime(context, false);
              },
            ),
            SizedBox(height: 20),

            // زر الحفظ
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // تنفيذ حفظ الإعدادات
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: Text('حفظ الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'الإعدادات',
    home: SettingsPage(),
    theme: ThemeData(primarySwatch: Colors.green),
  ));
}
