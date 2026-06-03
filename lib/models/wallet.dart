class Wallet {
  String? id;
  String name;
  double balance;

  Wallet({this.id, required this.name, required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json, String docId) {
    return Wallet(
      id: docId,
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'balance': balance};
  }
}
