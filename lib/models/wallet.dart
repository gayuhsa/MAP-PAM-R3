class Wallet {
  String? id;
  String name;
  String description;
  double balance;
  double initialBalance;

  Wallet({
    this.id,
    required this.name,
    this.description = '',
    required this.balance,
    required this.initialBalance,
  });

  static double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  factory Wallet.fromJson(Map<String, dynamic> json, String docId) {
    final balance = _toDouble(json['balance'], 0.0);
    final initialBalance = _toDouble(json['initialBalance'], balance);
    return Wallet(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      balance: balance,
      initialBalance: initialBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'balance': balance,
      'initialBalance': initialBalance,
    };
  }
}
