class Trade {
  final int quantity;
  final String clientName;
  final int id;
  final String symbol;
  final double lastPrice;

  Trade(
      {required this.quantity,
      required this.clientName,
      required this.id,
      required this.symbol,
      required this.lastPrice});
}
