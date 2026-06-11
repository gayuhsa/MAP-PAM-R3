class Wallet {
  String? id;
  String name;
  String description;
  double balance;

  Wallet({
    this.id,
    required this.name,
    this.description = '',
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json, String docId) {
    return Wallet(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'balance': balance};
  }
}
