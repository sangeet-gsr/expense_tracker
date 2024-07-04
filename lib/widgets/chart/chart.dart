import 'package:expense_tracker/widgets/chart/chart_bar.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class Chart extends StatelessWidget {
  const Chart({super.key, required this.expenses});

  final List<Expense> expenses;

  List<ExpenseBucket> get buckets {
    return Category.values
        .map((category) => ExpenseBucket.forCategory(expenses, category))
        .toList();
  }

  double get grandTotal {
    double grandTotal = 0;

    for (final bucket in buckets) {
      grandTotal += bucket.totalExpenses;
    }
    return grandTotal;
  }

  double totalExpensePercentage(ExpenseBucket bucket) {
    double totalExpensePercentage = 0;
    if (bucket.totalExpenses > 0) {
      totalExpensePercentage = bucket.totalExpenses / grandTotal;

      if (totalExpensePercentage < 0.02) {
        return 0.02;
      }
      return totalExpensePercentage;
    }
    return totalExpensePercentage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("You've spent"),
              Text(
                expenses.isNotEmpty
                    ? '₹ ${NumberFormat('#,##,##0.00', 'en_IN').format(expenses.fold(0.0, (prev, e) => prev + e.amount))}'
                    : "₹ 0",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: buckets.length,
            itemBuilder: (context, index) {
              return Container(
                color: Theme.of(context).colorScheme.onPrimary,
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            buckets[index]
                                    .category
                                    .name
                                    .substring(0, 1)
                                    .toUpperCase() +
                                buckets[index].category.name.substring(1),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₹ ${buckets[index].totalExpenses.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ChartBar(
                              fill: totalExpensePercentage(buckets[index])),
                          Container(
                            width: 60,
                            alignment: Alignment.centerRight,
                            child: Text(
                              grandTotal == 0
                                  ? '0.0%'
                                  : '${(buckets[index].totalExpenses / grandTotal * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
