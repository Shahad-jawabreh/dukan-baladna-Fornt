import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PastOrderDetails extends StatelessWidget {
  final Map<String, dynamic> order; // استلام البيانات من الصفحة السابقة

  const PastOrderDetails({Key? key, required this.order}) : super(key: key);
String formatOrderDate(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) {
    return 'Unknown time';
  }

  try {
    // Parse the API-provided date string
    DateTime dateTime = DateTime.parse(createdAt);

    // Format it to show date and hour
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    return formattedDate;
  } catch (e) {
    // Handle any parsing errors
    return 'Invalid date';
  }
}
  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("تفاصيل الطلب"),
      backgroundColor: const Color(0xFF94A96B),
      centerTitle: true,
      elevation: 4.0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قسم معلومات المستخدم
          SectionCard(
            title: "معلومات العميل",
            children: [
              _buildRow("الاسم:", order['userName'] ?? 'غير معروف'),
              _buildRow("رقم الهاتف:", order['phoneNumber'] ?? 'غير متوفر'),
              _buildRow("العنوان:", order['address'] ?? 'غير متوفر'),
            ],
          ),
          const SizedBox(height: 16.0),

          // قسم معلومات الطلب
          SectionCard(
            title: "معلومات الطلب",
            children: [
              _buildRow("رقم الطلب:", order['orderNum'] ?? 'غير متوفر'),
              _buildRow(
                "تاريخ الطلب:",
                formatOrderDate(order['createdAt'] ?? 'غير معروف'),
              ),
              _buildRow(
                "الحالة:",
                order['status'] ?? 'غير معروف',
                color: _getStatusColor(order['status'] ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // قسم المنتجات
          SectionCard(
            title: "تفاصيل المنتجات",
            children: [
              ...List.generate(
                order['products']?.length ?? 0,
                (index) {
                  final item = order['products'][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? 'منتج غير معروف',
                            style: const TextStyle(fontSize: 16.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "الكمية: ${item['quantity'] ?? 0} | السعر: \$${item['unitPrice'] ?? 0.0}",
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8.0),
              _buildRow(
                "إجمالي المنتجات:",
                "${order['products']?.length ?? 0} منتج",
                color: Colors.blueAccent,
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // السعر النهائي
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "السعر النهائي: \$${order['finalPrice'] ?? 0.0}",
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// دالة للحصول على لون الحالة
Color _getStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return Colors.green;
    case 'onway':
      return Colors.orange;
    case 'pending':
      return Colors.orange;
    case 'cancelled':
      return Colors.red;
    case 'delivered':
      return Colors.green;
    default:
      return Colors.black87;
  }
}


  Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.0, color: color ?? Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionCard({Key? key, required this.title, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 16.0, thickness: 1.0),
            ...children,
          ],
        ),
      ),
    );
  }
}
