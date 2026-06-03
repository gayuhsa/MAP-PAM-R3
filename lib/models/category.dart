class Category {
  final String id;
  final String name;
  final int colorHex;
  final String iconName;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json, String docId) {
    return Category(
      id: docId,
      name: json['name'] ?? '',
      colorHex: json['colorHex'] ?? 0xFFFFFFFF,
      iconName: json['iconName'] ?? 'help',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'colorHex': colorHex, 'iconName': iconName};
  }
}
