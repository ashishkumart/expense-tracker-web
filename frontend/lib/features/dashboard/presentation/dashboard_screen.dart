import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../logic/dashboard_cubit.dart';
import 'widgets/breakdown_panel.dart';
import 'widgets/kpi_card.dart';
import 'widgets/transaction_form.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listenWhen: (previous, current) =>
          current.message != null && previous.message != current.message,
      listener: (context, state) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!))),
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    _MonthSelector(month: state.selectedMonth),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 32) / 3;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: width,
                          child: KpiCard(
                            title: 'Total Income',
                            value: state.summary.income,
                            icon: Icons.trending_up,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: KpiCard(
                            title: 'Total Expense',
                            value: state.summary.expense,
                            icon: Icons.trending_down,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: KpiCard(
                            title: 'Remaining Balance',
                            value: state.summary.balance,
                            icon: Icons.account_balance_wallet_outlined,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1000;
                    final form = const TransactionForm();
                    final breakdown = BreakdownPanel(items: state.breakdown);
                    return wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 380, child: form),
                              const SizedBox(width: 20),
                              Expanded(child: breakdown),
                            ],
                          )
                        : Column(
                            children: [
                              form,
                              const SizedBox(height: 20),
                              breakdown,
                            ],
                          );
                  },
                ),
                const SizedBox(height: 24),
                _TransactionTable(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.month});
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final months = List.generate(25, (index) {
      final offset = index - 12;
      return DateTime(month.year, month.month + offset);
    });
    return DropdownButton<DateTime>(
      value: months[12],
      items: months
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(monthFormat.format(item)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) context.read<DashboardCubit>().load(month: value);
      },
    );
  }
}

class _TransactionTable extends StatelessWidget {
  const _TransactionTable({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transactions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (state.status == DashboardStatus.loading)
              const LinearProgressIndicator()
            else if (state.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('No transactions this month.')),
              )
            else
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Note')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('')),
                  ],
                  rows: state.transactions.map((transaction) {
                    final isIncome = transaction.type.apiValue == 'Income';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(indianDateFormat.format(transaction.date)),
                        ),
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: colorFromHex(
                                  transaction.category.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(transaction.category.name),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            transaction.note.isEmpty ? '—' : transaction.note,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(Text(transaction.type.apiValue)),
                        DataCell(
                          Text(
                            '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _confirmDelete(context, transaction.id),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete transaction?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) {
      context.read<DashboardCubit>().delete(id);
    }
  }
}
