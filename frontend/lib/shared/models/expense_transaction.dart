import 'package:equatable/equatable.dart';

import 'category.dart';

class ExpenseTransaction extends Equatable {
  const ExpenseTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
    required this.type,
  });

  final String id;
  final double amount;
  final DateTime date;
  final Category category;
  final String note;
  final TransactionType type;

  factory ExpenseTransaction.fromJson(Map<String, dynamic> json) =>
      ExpenseTransaction(
        id: json['_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String).toLocal(),
        category: Category.fromJson(json['categoryId'] as Map<String, dynamic>),
        note: json['note'] as String? ?? '',
        type: TransactionType.fromApi(json['type'] as String),
      );

  @override
  List<Object?> get props => [id, amount, date, category, note, type];
}
