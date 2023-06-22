class PnL2 {
  final DateTime eventTime;
  final double pnlChange;

  PnL2({
    required this.eventTime,
    required this.pnlChange,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventTime': eventTime,
      'pnlChange': pnlChange,
    };
  }
}
