import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 40,
            color: Colors.blue,
            title: "Electronics",
            titleStyle: TextStyle(
              fontSize: 16,  // Adjusted font size for better balance
              fontWeight: FontWeight.bold,
              color: Colors.white,  // White color for better readability
            ),
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.green,
            title: "Fashion",
            titleStyle: TextStyle(
              fontSize: 16,  // Consistent font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.orange,
            title: "Home",
            titleStyle: TextStyle(
              fontSize: 16,  // Consistent font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: 10,
            color: Colors.red,
            title: "Beauty",
            titleStyle: TextStyle(
              fontSize: 16,  // Consistent font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 50,  // Adjusted radius for better space
      ),
    );
  }
}
