import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OngoingOrderDetails extends StatelessWidget {
  final Map<String, dynamic> order; // استلام البيانات من الصفحة السابقة

  const OngoingOrderDetails({Key? key, required this.order}) : super(key: key);
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
          // Customer Information Section
          SectionCard(
            title: "معلومات العميل",
            children: [
              _buildRow(
                "الاسم:",
                order['userName'] ?? 'غير معروف',
                icon: Icons.person,
              ),
              _buildRow(
                "رقم الهاتف:",
                order['phoneNumber'] ?? 'غير متوفر',
                icon: Icons.phone,
              ),
              _buildRow(
                "العنوان:",
                order['address'] ?? 'غير متوفر',
                icon: Icons.location_on,
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Order Information Section
          SectionCard(
            title: "معلومات الطلب",
            children: [
              _buildRow(
                "رقم الطلب:",
                order['orderNum'] ?? 'غير متوفر',
                icon: Icons.receipt,
              ),
              _buildRow(
                "تاريخ الطلب:",
                formatOrderDate(order['createdAt'] ?? 'غير معروف'),
                icon: Icons.date_range,
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Products Section
          SectionCard(
            title: "تفاصيل المنتجات",
            children: [
              ...List.generate(
                order['products']?.length ?? 0,
                (index) {
                  final item = order['products'][index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? 'منتج غير معروف',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "الكمية: ${item['quantity'] ?? 0}",
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                "السعر: \$${item['unitPrice'] ?? 0.0}",
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                        ],
                      ),
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

          // Final Price Section
          SectionCard(
            title: "السعر النهائي",
            children: [
              Text(
                "\$${order['finalPrice'] ?? 'غير متوفر'}",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
Color _getStatusColor(String status) {
  switch (status) {
    case 'تم التأكيد':
      return Colors.green;
    case 'على الطريق':
      return Colors.orange;
    case 'معلّق':
      return Colors.orange;
    case 'ملغي':
      return Colors.red;
    case 'واصل':
      return Colors.green;
    default:
      return Colors.black87;
  }}
// Reusable method for rows with icons
Widget _buildRow(String label, String value, {IconData? icon, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        if (icon != null)
          Icon(
            icon,
            size: 18.0,
            color: color ?? Colors.black87,
          ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              color: color ?? Colors.black54,
            ),
            textAlign: TextAlign.end,
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
