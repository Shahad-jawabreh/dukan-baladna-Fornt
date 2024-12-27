import 'package:flutter/material.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildStatCard("Users", "1,200", Colors.blue),
        buildStatCard("Products", "320", Colors.green),
        buildStatCard("Orders", "150", Colors.orange),
        buildStatCard("Revenue", "\$5,430", Colors.red),
      ],
    );
  }

  Widget buildStatCard(String title, String count, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,  // لتحديد اللون الخلفي للبطاقة
      child: Container(
        width: 100,  // عرض متناسق
        height: 130,  // ارتفاع متناسق مع المساحة
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 26,  // جعل الأرقام أكبر
                fontWeight: FontWeight.w700,  // جعل الأرقام أكثر وضوحاً
                color: color,  // تخصيص اللون لكل بطاقة
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,  // تقليل حجم النص قليلاً لجعله أكثر توازن
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],  // اللون الرمادي للنص
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
