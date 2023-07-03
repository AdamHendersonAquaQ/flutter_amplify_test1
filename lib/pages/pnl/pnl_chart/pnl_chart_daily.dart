import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/classes/pnl2.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/chart_shared_methods.dart';
import 'package:praxis_internals/pages/pnl/pnl_chart/chart_shared_widgets.dart';

class PnLDailyChart extends StatefulWidget {
  const PnLDailyChart(
      {super.key,
      required this.clientData,
      required this.hedgeData,
      this.isDashboard});

  final List<PnL2> clientData;
  final List<PnL2> hedgeData;

  final bool? isDashboard;

  @override
  State<PnLDailyChart> createState() => PnLDailyChartState();
}

class PnLDailyChartState extends State<PnLDailyChart> {
  List<FlSpot> clientPoints = [];
  List<FlSpot> hedgePoints = [];

  double maxY = 0;
  double minY = 0;
  double yInterval = 0;

  @override
  Widget build(BuildContext context) {
    bool isDash = widget.isDashboard ?? false;
    if (widget.clientData.isNotEmpty) {
      maxY = widget.clientData[0].pnlChange;
      minY = widget.clientData[0].pnlChange;
    } else {
      maxY = widget.hedgeData[0].pnlChange;
      minY = widget.hedgeData[0].pnlChange;
    }
    getClientPoints();
    getHedgePoints();
    if (maxY == 0 && minY == 0) {
      maxY = 10000;
    }
    int maxLength = getMaxLength(maxY, minY);

    maxY = ((maxY / maxLength).ceil() * maxLength.toDouble());
    minY = ((minY / maxLength).floor() * maxLength.toDouble());
    yInterval = (maxY.abs() + minY.abs()) / (isDash ? 5 : 10);

    double roundedGap = getRoundedGap(yInterval);
    yInterval =
        roundedGap * pow(10, yInterval.toString().length - 2).toDouble();

    maxY = ((maxY / yInterval).ceil() * yInterval.toDouble());
    minY = ((minY / yInterval).floor() * yInterval.toDouble());

    return LineChart(
      pnlDailyData,
    );
  }

  void getClientPoints() {
    clientPoints = [];
    for (PnL2 pnl in widget.clientData) {
      if (pnl.pnlChange > maxY) {
        maxY = pnl.pnlChange;
      } else if (pnl.pnlChange < minY) {
        minY = pnl.pnlChange;
      }
      clientPoints.add(FlSpot(
          pnl.eventTime.millisecondsSinceEpoch.toDouble(), pnl.pnlChange));
    }
  }

  void getHedgePoints() {
    hedgePoints = [];
    for (PnL2 pnl in widget.hedgeData) {
      if (pnl.pnlChange > maxY) {
        maxY = pnl.pnlChange;
      } else if (pnl.pnlChange < minY) {
        minY = pnl.pnlChange;
      }
      hedgePoints.add(FlSpot(
          pnl.eventTime.millisecondsSinceEpoch.toDouble(), pnl.pnlChange));
    }
  }

  LineChartData get pnlDailyData {
    return LineChartData(
      lineTouchData: lineTouchData,
      gridData: gridData,
      titlesData: titlesData,
      borderData: borderData,
      extraLinesData: (maxY > 0 && minY < 0) ? zeroLine : null,
      lineBarsData: [clientLineChartBarData, hedgeLineChartBarData],
      minX: lowerHalf(widget.clientData.isNotEmpty
              ? widget.clientData.last.eventTime
              : widget.hedgeData.last.eventTime)
          .millisecondsSinceEpoch
          .toDouble(),
      maxX: upperHalf(widget.clientData.isNotEmpty
              ? widget.clientData[0].eventTime
              : widget.hedgeData[0].eventTime)
          .millisecondsSinceEpoch
          .toDouble(),
      maxY: maxY,
      minY: minY,
    );
  }

  LineTouchData get lineTouchData => LineTouchData(
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return getLineSpots(barData, spotIndexes);
        },
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: false,
          tooltipPadding: const EdgeInsets.all(3),
          tooltipMargin: 10,
          tooltipBgColor: offWhite.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              if (barSpot.barIndex == 0) {
                DateTime dt =
                    DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt());
                String minute =
                    dt.minute >= 10 ? dt.minute.toString() : "0${dt.minute}";
                return LineTooltipItem(
                  "Time: ${dt.hour >= 10 ? dt.hour : "0${dt.hour}"}:$minute\nClient: \$${numberFormatNoDec.format(flSpot.y.toInt())}",
                  const TextStyle(
                    color: praxisBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                );
              } else {
                return LineTooltipItem(
                  "Hedge: \$${numberFormatNoDec.format(flSpot.y.toInt())}",
                  const TextStyle(
                    color: praxisBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                );
              }
            }).toList();
          },
        ),
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
    if (value % yInterval == 0) {
      String text = getPnLLabelText(value, maxY, minY);
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(text, style: leftTitleStyle, textAlign: TextAlign.right),
      );
    } else {
      return const Text("");
    }
  }

  SideTitles leftTitles() {
    return SideTitles(
      getTitlesWidget: leftTitleWidgets,
      showTitles: true,
      interval: yInterval,
      reservedSize: getPnLTitleSize(maxY, minY, yInterval),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    int length = (clientPoints.isNotEmpty ? clientPoints : hedgePoints).length;
    Widget text;
    if ((length > 12 * 60 && dt.hour % 2 == 0 && dt.minute == 0) ||
        (length > 6 * 60 && length <= 12 * 60 && dt.minute == 0) ||
        (length <= 6 * 60 && dt.minute % 30 == 0)) {
      text = Text(
          '${dt.hour >= 10 ? dt.hour : "0${dt.hour}"}:${dt.minute / 10}0',
          style: bottomLabelStyle);
    } else {
      text = const Text('', style: bottomLabelStyle);
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

  LineChartBarData get clientLineChartBarData => LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: praxisGreen,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: clientPoints);

  LineChartBarData get hedgeLineChartBarData => LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: const Color.fromARGB(255, 18, 108, 182),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: hedgePoints);
}
