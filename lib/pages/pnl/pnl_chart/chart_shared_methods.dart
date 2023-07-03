import 'dart:math';

import 'package:intl/intl.dart';

int getMaxLength(double maxY, double minY) {
  int maxLength = maxY.floor().toString().length - 1;
  if (minY.floor().toString().length - 2 > maxY) {
    maxLength = minY.floor().toString().length - 2;
  }
  maxLength = pow(10, maxLength).toInt();
  if (maxY / maxLength < 1.5) maxLength = maxLength ~/ 10;
  return maxLength;
}

double getRoundedGap(double yInterval) {
  double roundedGap = (yInterval / pow(10, yInterval.toString().length - 1));
  if (roundedGap == 0) {
    roundedGap = 10;
  } else if (roundedGap > 2 && roundedGap <= 2.5) {
    roundedGap = 25;
  } else if (roundedGap >= 2.5 && roundedGap <= 5) {
    roundedGap = 50;
  } else if (roundedGap > 5) {
    roundedGap = 100;
  } else {
    roundedGap = roundedGap.round() * 10;
  }
  return roundedGap;
}

NumberFormat numberFormatNoDec = NumberFormat("#,##0", "en_US");

String getPnLLabelText(double value, double maxY, double minY) {
  if (value.toInt().abs() >= 100000 && (maxY >= 1000000 || minY <= -1000000)) {
    return "\$${value / 1000000}M".replaceAll(".0", "");
  } else if (value.toInt().abs() >= 1000000) {
    return "\$${value.toInt() / 1000}K";
  } else {
    return "\$${value.toInt()}";
  }
}

double getPnLTitleSize(double maxY, double minY, double yInterval) {
  double size = ((maxY.toInt()).toString().length).toDouble();
  if (size < ((minY.toInt()).toString().length).toDouble()) {
    size = ((minY.toInt()).toString().length).toDouble();
  }
  if (yInterval >= 1000) size -= 2;
  if (yInterval >= 100000) size -= 1;
  if (yInterval >= 1000000) size -= 2;
  if ((!(maxY >= 1000000) && !(minY <= -1000000)) && yInterval >= 100000) {
    size += 1;
  } else if ((maxY >= 1000000 || minY <= -1000000) &&
      (yInterval % 1000000 != 0 && yInterval > 1000000)) {
    size += 1;
  }
  size += 1;
  return size * 12;
}

DateTime upperHalf(DateTime val) {
  return DateTime(val.year, val.month, val.day, val.hour,
      [0, 30, 60][(val.minute / 30).ceil()]);
}

DateTime lowerHalf(DateTime val) {
  return DateTime(val.year, val.month, val.day, val.hour,
      [0, 30, 60][(val.minute / 30).floor()]);
}
