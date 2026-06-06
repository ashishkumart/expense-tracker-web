import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/dashboard_models.dart';
import '../../../shared/models/expense_transaction.dart';

class TransactionRepository {
  const TransactionRepository(this._api);
  final ApiClient _api;

  Map<String, String> _monthQuery(DateTime month) => {
    'month': '${month.month}',
    'year': '${month.year}',
  };

  Future<List<ExpenseTransaction>> getTransactions(DateTime month) async {
    final data =
        await _api.get('/transactions', query: _monthQuery(month))
            as List<dynamic>;
    return data
        .map(
          (item) => ExpenseTransaction.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MonthlySummary> getSummary(DateTime month) async {
    final data = await _api.get(
      '/transactions/summary',
      query: _monthQuery(month),
    );
    return MonthlySummary.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CategoryBreakdown>> getBreakdown(DateTime month) async {
    final data =
        await _api.get(
              '/transactions/breakdown',
              query: {..._monthQuery(month), 'type': 'Expense'},
            )
            as Map<String, dynamic>;
    return (data['categories'] as List<dynamic>)
        .map((item) => CategoryBreakdown.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required double amount,
    required DateTime date,
    required Category category,
    required String note,
  }) => _api.post('/transactions', {
    'amount': amount,
    // Date-only UTC prevents the selected calendar day changing by timezone.
    'date': dateOnlyUtc(date).toIso8601String(),
    'categoryId': category.id,
    'note': note,
    'type': category.type.apiValue,
  });

  Future<void> delete(String id) => _api.delete('/transactions/$id');
}
