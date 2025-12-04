class CategoryModel {
  final String id;
  final String name;
  final String type; // INCOME or EXPENSE
  final String? icon;
  final String? color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['transactionType'] ?? json['type'], // Backend uses 'transactionType'
      icon: json['icon'],
      color: json['color'],
    );
  }
}
