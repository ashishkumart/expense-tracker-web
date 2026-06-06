import 'package:equatable/equatable.dart';

enum TransactionType {
  income('Income'),
  expense('Expense');

  const TransactionType(this.apiValue);
  final String apiValue;

  static TransactionType fromApi(String value) =>
      value == 'Income' ? income : expense;
}

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String color;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['_id'] as String,
    name: json['name'] as String,
    type: TransactionType.fromApi(json['type'] as String),
    color: json['color'] as String,
  );

  Map<String, dynamic> toRequest() => {
    'name': name,
    'type': type.apiValue,
    'color': color,
  };

  @override
  List<Object?> get props => [id, name, type, color];
}
