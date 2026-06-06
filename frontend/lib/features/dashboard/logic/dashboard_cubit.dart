import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/category.dart';
import '../../../shared/models/dashboard_models.dart';
import '../../../shared/models/expense_transaction.dart';
import '../data/transaction_repository.dart';

enum DashboardStatus { initial, loading, success, failure, saving }

class DashboardState extends Equatable {
  DashboardState({
    this.status = DashboardStatus.initial,
    DateTime? selectedMonth,
    this.transactions = const [],
    this.summary = const MonthlySummary(),
    this.breakdown = const [],
    this.message,
  }) : selectedMonth =
           selectedMonth ?? DateTime(DateTime.now().year, DateTime.now().month);

  final DashboardStatus status;
  final DateTime selectedMonth;
  final List<ExpenseTransaction> transactions;
  final MonthlySummary summary;
  final List<CategoryBreakdown> breakdown;
  final String? message;

  DashboardState copyWith({
    DashboardStatus? status,
    DateTime? selectedMonth,
    List<ExpenseTransaction>? transactions,
    MonthlySummary? summary,
    List<CategoryBreakdown>? breakdown,
    String? message,
    bool clearMessage = false,
  }) => DashboardState(
    status: status ?? this.status,
    selectedMonth: selectedMonth ?? this.selectedMonth,
    transactions: transactions ?? this.transactions,
    summary: summary ?? this.summary,
    breakdown: breakdown ?? this.breakdown,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [
    status,
    selectedMonth,
    transactions,
    summary,
    breakdown,
    message,
  ];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(DashboardState());
  final TransactionRepository _repository;

  Future<void> load({DateTime? month}) async {
    final selected = month ?? state.selectedMonth;
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        selectedMonth: selected,
        clearMessage: true,
      ),
    );
    try {
      final values = await Future.wait([
        _repository.getTransactions(selected),
        _repository.getSummary(selected),
        _repository.getBreakdown(selected),
      ]);
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          transactions: values[0] as List<ExpenseTransaction>,
          summary: values[1] as MonthlySummary,
          breakdown: values[2] as List<CategoryBreakdown>,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: DashboardStatus.failure, message: '$error'));
    }
  }

  Future<bool> create({
    required double amount,
    required DateTime date,
    required Category category,
    required String note,
  }) async {
    emit(state.copyWith(status: DashboardStatus.saving, clearMessage: true));
    try {
      await _repository.create(
        amount: amount,
        date: date,
        category: category,
        note: note,
      );
      await load();
      return true;
    } catch (error) {
      emit(state.copyWith(status: DashboardStatus.failure, message: '$error'));
      return false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
    } catch (error) {
      emit(state.copyWith(status: DashboardStatus.failure, message: '$error'));
    }
  }
}
