import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrdersBarChart extends StatelessWidget {
  const OrdersBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 250,  // Adjusted height for the chart to make it more balanced with text
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: [
              makeGroupData(0, 12),
              makeGroupData(1, 15),
              makeGroupData(2, 8),
              makeGroupData(3, 10),
              makeGroupData(4, 5),
              makeGroupData(5, 18),
              makeGroupData(6, 7),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 40,  // Reserve space for left titles to avoid clipping
                  getTitlesWidget: (value, titleMeta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 14,  // Adjusted font size for the left axis labels
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, titleMeta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Mon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      case 1:
                        return const Text('Tue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      case 2:
                        return const Text('Wed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      case 3:
                        return const Text('Thu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      case 4:
                        return const Text('Fri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      case 5:
                        return const Text('Sat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      case 6:
                        return const Text('Sun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500));
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y, // Correct parameter for newer versions
          color: Color(0xFF94A96B), // Customize the color here
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
