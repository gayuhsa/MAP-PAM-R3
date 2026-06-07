class Category {
  String? id;
  String name;

  Category({this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json, String docId) {
    return Category(id: docId, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
