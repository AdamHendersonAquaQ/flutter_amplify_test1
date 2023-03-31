class Position {
  final String symbol;
  final int position;

  Position({required this.symbol, required this.position});

  Map<String, dynamic> toMap() {
    return {'symbol': symbol, 'position': position};
  }
}
