class Trade {
  final int quantity;
  final String clientName;
  final int id;
  final DateTime transactionTime;
  final String symbol;
  final double lastPrice;

  Trade(
      {required this.quantity,
      required this.clientName,
      required this.id,
      required this.symbol,
      required this.transactionTime,
      required this.lastPrice});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionTime': transactionTime,
      'clientName': clientName,
      'quantity': quantity,
      'symbol': symbol,
      'lastPrice': lastPrice
    };
  }
}
