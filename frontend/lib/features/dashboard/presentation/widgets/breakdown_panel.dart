import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/dashboard_models.dart';

class BreakdownPanel extends StatelessWidget {
  const BreakdownPanel({super.key, required this.items});
  final List<CategoryBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              const Text('No expenses recorded for this month.')
            else
              ...items.map((item) {
                final color = colorFromHex(item.color);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.name)),
                          Text(
                            '${currencyFormat.format(item.amount)}  '
                            '${item.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: item.percentage / 100,
                        color: color,
                        backgroundColor: color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
