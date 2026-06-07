class Wallet {
  String? id;
  String? userId;
  String name;
  double balance;

  Wallet({this.id, this.userId, required this.name, required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json, String docId) {
    return Wallet(
      id: docId,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'name': name, 'balance': balance};
  }
}
