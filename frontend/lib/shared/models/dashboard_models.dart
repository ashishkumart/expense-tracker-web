import 'package:equatable/equatable.dart';

class MonthlySummary extends Equatable {
  const MonthlySummary({this.income = 0, this.expense = 0, this.balance = 0});
  final double income;
  final double expense;
  final double balance;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) => MonthlySummary(
    income: (json['income'] as num).toDouble(),
    expense: (json['expense'] as num).toDouble(),
    balance: (json['balance'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [income, expense, balance];
}

class CategoryBreakdown extends Equatable {
  const CategoryBreakdown({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.amount,
    required this.percentage,
  });
  final String categoryId;
  final String name;
  final String color;
  final double amount;
  final double percentage;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      CategoryBreakdown(
        categoryId: json['categoryId'] as String,
        name: json['name'] as String,
        color: json['color'] as String,
        amount: (json['amount'] as num).toDouble(),
        percentage: (json['percentage'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [categoryId, name, color, amount, percentage];
}
