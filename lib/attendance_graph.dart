import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'attendance_data.dart';
import 'dashboad.dart';

class AttendanceGraph extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    // Sample data for AttendanceData
    List<AttendanceData> data = [
      AttendanceData('2024-06-01', 10),
      AttendanceData('2024-06-02', 15),
      AttendanceData('2024-06-03', 20),
      AttendanceData('2024-06-04', 18),
      AttendanceData('2024-06-05', 12),
    ];

    return BarChart(
      BarChartData(

        barGroups: data
            .asMap()
            .entries
            .map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              y: entry.value.count.toDouble(),
              colors: [Colors.blue],
            ),
          ],
          showingTooltipIndicators: [0],
        ))
            .toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            getTitles: (double value) => data[value.toInt()].date,
            margin: 16,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            getTitles: (double value) => value.toInt().toString(),
            margin: 16,
          ),
        ),
        gridData: FlGridData(
          show: true,
          checkToShowHorizontalLine: (value) => true,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
      ),
    );
  }
}
