class Category {
  String? id;
  String? userId;
  String name;

  Category({this.id, this.userId, required this.name});

  factory Category.fromJson(Map<String, dynamic> json, String docId) {
    return Category(
      id: docId,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'name': name};
  }
}
