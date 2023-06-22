class Position {
  final String symbol;
  final double position;
  final double hedge;
  final double nett;
  final double latestPrice;
  final double value;

  Position(
      {required this.symbol,
      required this.position,
      required this.hedge,
      required this.nett,
      required this.latestPrice,
      required this.value});

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'position': position,
      'hedge': hedge,
      'nett': nett,
      'latestPrice': latestPrice,
      'value': value
    };
  }
}
