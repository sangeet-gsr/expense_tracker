import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const dropdownItems = [
  DropdownMenuItem(value: 1, child: Text('Jan')),
  DropdownMenuItem(value: 2, child: Text('Feb')),
  DropdownMenuItem(value: 3, child: Text('Mar')),
  DropdownMenuItem(value: 4, child: Text('Apr')),
  DropdownMenuItem(value: 5, child: Text('May')),
  DropdownMenuItem(value: 6, child: Text('Jun')),
  DropdownMenuItem(value: 7, child: Text('Jul')),
  DropdownMenuItem(value: 8, child: Text('Aug')),
  DropdownMenuItem(value: 9, child: Text('Sep')),
  DropdownMenuItem(value: 10, child: Text('Oct')),
  DropdownMenuItem(value: 11, child: Text('Nov')),
  DropdownMenuItem(value: 12, child: Text('Dec')),
];

class FilterBar extends StatelessWidget {
  const FilterBar(
      {super.key,
      required this.expenses,
      required this.filterByMonth,
      required this.filterByYear,
      required this.onSelect});

  final List<Expense> expenses;
  final int filterByMonth;
  final int filterByYear;
  final void Function(int month, int year) onSelect;

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 0),
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              expenses.isNotEmpty
                  ? NumberFormat('#,##,##0.00', 'en_IN')
                      .format(expenses.fold(0.0, (prev, e) => prev + e.amount))
                  : "",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isDense: true,
                    value: filterByMonth,
                    icon: const Icon(Icons.arrow_drop_down),
                    borderRadius: BorderRadius.circular(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    dropdownColor: Theme.of(context).colorScheme.onPrimary,
                    items: dropdownItems,
                    onChanged: (value) {
                      onSelect(value!, filterByYear);
                    },
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    isDense: true,
                    value: filterByYear,
                    icon: const Icon(Icons.arrow_drop_down),
                    borderRadius: BorderRadius.circular(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    dropdownColor: Theme.of(context).colorScheme.onPrimary,
                    items: [
                      for (var year = 2015; year <= DateTime.now().year; year++)
                        DropdownMenuItem(
                            value: year, child: Text(year.toString())),
                    ],
                    onChanged: (value) {
                      onSelect(filterByMonth, value!);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
