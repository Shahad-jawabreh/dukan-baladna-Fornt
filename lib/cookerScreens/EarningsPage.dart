import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';  // For the graph
import 'dart:math';

void main() {
  runApp(MaterialApp(
    home: EarningsPage(),
    theme: ThemeData(
      primaryColor: Colors.green,
      scaffoldBackgroundColor: Colors.white,
    ),
  ));
}

class EarningsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأرباح والتحصيل'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Earnings Table
            Text(
              'تفاصيل الطلبات المكتملة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('رقم الطلب')),
                DataColumn(label: Text('المنتج')),
                DataColumn(label: Text('الأرباح')),
              ],
              rows: const <DataRow>[
                DataRow(cells: <DataCell>[
                  DataCell(Text('1')),
                  DataCell(Text('منتج 1')),
                  DataCell(Text('100 جنيه')),
                ]),
                DataRow(cells: <DataCell>[
                  DataCell(Text('2')),
                  DataCell(Text('منتج 2')),
                  DataCell(Text('150 جنيه')),
                ]),
                DataRow(cells: <DataCell>[
                  DataCell(Text('3')),
                  DataCell(Text('منتج 3')),
                  DataCell(Text('200 جنيه')),
                ]),
                DataRow(cells: <DataCell>[
                  DataCell(Text('4')),
                  DataCell(Text('منتج 4')),
                  DataCell(Text('120 جنيه')),
                ]),
              ],
            ),
            SizedBox(height: 20),

            // Monthly Earnings Graph
            Text(
              'إجمالي الأرباح الشهرية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 250,
              padding: EdgeInsets.all(10),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 500,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(fromY: 0, toY: 350, color: Colors.green, width: 25),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(fromY: 0, toY: 200, color: Colors.green, width: 25),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(fromY: 0, toY: 400, color: Colors.green, width: 25),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(fromY: 0, toY: 450, color: Colors.green, width: 25),
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(fromY: 0, toY: 500, color: Colors.green, width: 25),
                    ]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Withdraw Earnings Section
            Text(
              'طلب سحب الأرباح',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'اختر طريقة التحويل:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              hint: Text('اختر طريقة التحويل'),
              items: <String>['حساب بنكي', 'محفظة إلكترونية']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // Logic to handle the selected withdrawal method
                print('طريقة التحويل المختارة: $value');
              },
            ),
            SizedBox(height: 20),

            // Button for requesting withdrawal
            ElevatedButton(
              onPressed: () {
                // Logic for requesting withdrawal
                print('تم تقديم طلب سحب الأرباح');
              },
              child: Text('طلب سحب الأرباح'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
            ),
            SizedBox(height: 20),

            // Withdrawal Status
            Text(
              'حالة طلب السحب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'في انتظار المعالجة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.access_time, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
