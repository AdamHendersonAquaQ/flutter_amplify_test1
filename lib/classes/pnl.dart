class PnL {
  final String source;
  final double sum;
  final double? previousSum;

  PnL({
    required this.source,
    required this.sum,
    this.previousSum,
  });

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'sum': sum,
      'previousSum': previousSum,
    };
  }
}
