class PnL {
  final double? totalPnL;
  final double? previousPnL;
  final int change;

  PnL({
    required this.totalPnL,
    this.previousPnL,
    required this.change,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalPnL': totalPnL,
      'previousPnL': previousPnL,
      'change': change,
    };
  }
}
