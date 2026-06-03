class Wallet {
  final String id;
  final String name;
  final double balance;
  final String currency;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json, String docId) {
    return Wallet(
      id: docId,
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'balance': balance, 'currency': currency};
  }
}
