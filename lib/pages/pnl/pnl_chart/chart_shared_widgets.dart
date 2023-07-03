import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:praxis_internals/colour_constants.dart';

var zeroLine = ExtraLinesData(horizontalLines: [
  HorizontalLine(
      y: 0,
      color: Colors.yellow.withOpacity(0.3),
      strokeWidth: 2,
      dashArray: [20, 10])
]);

List<TouchedSpotIndicatorData?> getLineSpots(
    LineChartBarData barData, List<int> spotIndexes) {
  return spotIndexes.map((spotIndex) {
    final spot = barData.spots[spotIndex];
    if (spot.x == 0) return null;
    return TouchedSpotIndicatorData(
      FlLine(color: praxisGreen, strokeWidth: 4, dashArray: [20, 15]),
      FlDotData(
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: offWhite,
            strokeWidth: 3,
            //strokeColor: barData.color,
          );
        },
      ),
    );
  }).toList();
}

const leftTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Color.fromARGB(255, 196, 181, 46));

const bottomLabelStyle = TextStyle(
  fontSize: 14,
);

FlBorderData get borderData => FlBorderData(
      show: true,
      border: const Border(
        bottom: BorderSide(color: Color.fromARGB(255, 10, 57, 95), width: 4),
        left: BorderSide(color: Color.fromARGB(255, 10, 57, 95), width: 4),
      ),
    );

FlGridData get gridData => FlGridData(show: false);
