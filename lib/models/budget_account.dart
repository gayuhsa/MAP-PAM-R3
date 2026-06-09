class BudgetAccount {
  String? id;
  String name;
  String categoryId;
  String keterangan;
  double volume;
  String satuan;
  double jumlah; // anggaran yang dialokasikan

  BudgetAccount({
    this.id,
    required this.name,
    required this.categoryId,
    required this.keterangan,
    required this.volume,
    required this.satuan,
    required this.jumlah,
  });

  factory BudgetAccount.fromJson(Map<String, dynamic> json, String docId) {
    return BudgetAccount(
      id: docId,
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      keterangan: json['keterangan'] ?? '',
      volume: (json['volume'] ?? 0.0).toDouble(),
      satuan: json['satuan'] ?? '',
      jumlah: (json['jumlah'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'categoryId': categoryId,
      'keterangan': keterangan,
      'volume': volume,
      'satuan': satuan,
      'jumlah': jumlah,
    };
  }
}
