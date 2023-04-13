class PnL {
  final int totalPnL;
  final int dailyPnL;
  final int change;

  PnL({
    required this.totalPnL,
    required this.dailyPnL,
    required this.change,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalPnL': totalPnL,
      'dailyPnL': dailyPnL,
      'change': change,
    };
  }
}
