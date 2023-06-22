import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/classes/pnl2.dart';

class PnLDailyChart extends StatefulWidget {
  const PnLDailyChart({super.key, required this.data, this.isDashboard});

  final List<PnL2> data;
  final bool? isDashboard;

  @override
  State<PnLDailyChart> createState() => PnLDailyChartState();
}

class PnLDailyChartState extends State<PnLDailyChart> {
  late double touchedValue;
  List<FlSpot> points = [];

  double maxY = 0;
  double minY = 0;
  double yInterval = 0;

  bool fitInsideBottomTitle = true;
  bool fitInsideLeftTitle = false;

  @override
  void initState() {
    touchedValue = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    maxY = widget.data[0].pnlChange;
    minY = widget.data[0].pnlChange;
    points = [];
    for (PnL2 pnl in widget.data) {
      if (pnl.pnlChange > maxY) {
        maxY = pnl.pnlChange;
      } else if (pnl.pnlChange < minY) {
        minY = pnl.pnlChange;
      }
      points.add(FlSpot(
          pnl.eventTime.millisecondsSinceEpoch.toDouble(), pnl.pnlChange));
    }
    if (maxY == 0 && minY == 0) {
      maxY = 100000;
    }
    maxY = ((maxY / 100000).ceil() * 100000);
    minY = ((minY / 100000).floor() * 100000);
    yInterval = ((maxY - minY) / 1000000).ceil() *
        100000 *
        (widget.isDashboard == null ? 1 : 2);
    return LineChart(
      pnlDailyData,
    );
  }

  DateTime upperHalf(DateTime val) {
    return DateTime(val.year, val.month, val.day, val.hour,
        [0, 30, 60][(val.minute / 30).ceil()]);
  }

  DateTime lowerHalf(DateTime val) {
    return DateTime(val.year, val.month, val.day, val.hour,
        [0, 30, 60][(val.minute / 30).floor()]);
  }

  LineChartData get pnlDailyData => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        extraLinesData: (maxY > 0 && minY < 0)
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.yellow.withOpacity(0.5),
                    strokeWidth: 3,
                    dashArray: [20, 10],
                  ),
                ],
              )
            : null,
        lineBarsData: [
          lineChartBarData,
        ],
        minX: lowerHalf(
                widget.data.last.eventTime.add(const Duration(minutes: 1)))
            .millisecondsSinceEpoch
            .toDouble(),
        maxX: upperHalf(
                widget.data[0].eventTime.subtract(const Duration(minutes: 1)))
            .millisecondsSinceEpoch
            .toDouble(),
        maxY: maxY,
        minY: minY,
      );

  NumberFormat numberFormatNoDec = NumberFormat("#,##0", "en_US");

  LineTouchData get lineTouchData => LineTouchData(
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            final spot = barData.spots[spotIndex];
            if (spot.x == 0) {
              return null;
            }
            return TouchedSpotIndicatorData(
              FlLine(color: praxisGreen, strokeWidth: 4, dashArray: [20, 15]),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: offWhite,
                    strokeWidth: 3,
                    strokeColor: praxisGreen,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: false,
          tooltipBgColor: offWhite,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              DateTime dt =
                  DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt());
              String minute =
                  dt.minute >= 10 ? dt.minute.toString() : "0${dt.minute}";
              return LineTooltipItem(
                "PnL: \$${numberFormatNoDec.format(flSpot.y.toInt())}\nTime: ${dt.hour >= 10 ? dt.hour : "0${dt.hour}"}:$minute",
                const TextStyle(
                  color: praxisBlue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              );
            }).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
          if (!event.isInterestedForInteractions ||
              lineTouch == null ||
              lineTouch.lineBarSpots == null) {
            setState(() {
              touchedValue = -1;
            });
            return;
          }
          final value = lineTouch.lineBarSpots![0].x;
          if (value == 0 || value == 6) {
            setState(() {
              touchedValue = -1;
            });
            return;
          }
          setState(() {
            touchedValue = value;
          });
        },
        handleBuiltInTouches: true,
      );

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: widget.isDashboard == null
            ? AxisTitles(
                axisNameWidget: const Text(
                  'Time',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                axisNameSize: 25,
                sideTitles: bottomTitles,
              )
            : AxisTitles(
                sideTitles: bottomTitles,
              ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: widget.isDashboard == null
            ? AxisTitles(
                axisNameWidget: const Padding(
                  padding: EdgeInsets.only(left: 50),
                  child: Text(
                    'PnL Change',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                axisNameSize: 25,
                sideTitles: leftTitles(),
              )
            : AxisTitles(
                sideTitles: leftTitles(),
              ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color.fromARGB(255, 196, 181, 46));
    if (value % yInterval == 0) {
      String text = "";
      if (value.toInt().abs() >= 1000000) {
        text = "\$${value.toInt() / 1000000}M";
      } else if (value.toInt().abs() >= 1000) {
        text = "\$${value.toInt() / 1000}K";
      } else {
        text = "\$${value.toInt()}";
      }
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(text, style: style, textAlign: TextAlign.right),
      );
    } else {
      return const Text("");
    }
  }

  SideTitles leftTitles() {
    double size = ((maxY).toString().length).toDouble();
    if (size < ((minY).toString().length).toDouble()) {
      size = ((minY).toString().length).toDouble();
    }
    return SideTitles(
      getTitlesWidget: leftTitleWidgets,
      showTitles: true,
      interval: yInterval,
      reservedSize: 10 * size,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 14,
    );
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    Widget text;
    if ((points.length > 12 * 60 && dt.hour % 2 == 0 && dt.minute == 0) ||
        (points.length > 6 * 60 &&
            points.length <= 12 * 60 &&
            dt.minute == 0) ||
        (points.length <= 6 * 60 && dt.minute % 30 == 0)) {
      text = Text(
          '${dt.hour >= 10 ? dt.hour : "0${dt.hour}"}:${dt.minute / 10}0',
          style: style);
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 20,
        interval: 60000 * 30,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(show: false);

  static FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color.fromARGB(255, 10, 57, 95), width: 4),
          left: BorderSide(color: Color.fromARGB(255, 10, 57, 95), width: 4),
        ),
      );

  LineChartBarData get lineChartBarData => LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: praxisGreen,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: points);
}
