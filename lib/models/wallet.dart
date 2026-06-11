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

  factory Wallet.fromJson(Map<String, dynamic> json, String docId) {
    final balance = (json['balance'] ?? 0.0).toDouble();
    final initialBalance = (json['initialBalance'] ?? balance).toDouble();
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
