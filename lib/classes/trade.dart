class Trade {
  final double quantity;
  final String clientName;
  final String id;
  final DateTime transactionTime;
  final String symbol;
  final double lastPrice;
  final String source;

  Trade(
      {required this.quantity,
      required this.clientName,
      required this.id,
      required this.symbol,
      required this.transactionTime,
      required this.lastPrice,
      required this.source});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionTime': transactionTime,
      'clientName': clientName,
      'quantity': quantity,
      'symbol': symbol,
      'lastPrice': lastPrice,
      'source': source
    };
  }
}
