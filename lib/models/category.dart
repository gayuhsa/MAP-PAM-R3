class Category {
  String? id;
  String name;
  String description;

  Category({this.id, required this.name, this.description = ''});

  factory Category.fromJson(Map<String, dynamic> json, String docId) {
    return Category(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
