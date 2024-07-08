import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/helper/filterbar.dart';
import 'package:flutter/material.dart';

class Expenses extends StatelessWidget {
  const Expenses(
      {super.key,
      required this.isLoading,
      required this.expenses,
      required this.filterByMonth,
      required this.filterByYear,
      required this.filterExpenses,
      required this.removeExpense, 
      required this.editExpense});

  final bool isLoading;
  final List<Expense> expenses;
  final int filterByMonth;
  final int filterByYear;
  final Function filterExpenses;
  final Function removeExpense;
  final Function editExpense;

  @override
  Widget build(context) {
    Widget mainContent;

    if (isLoading) {
      mainContent = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (expenses.isEmpty) {
      mainContent = const Center(
        child: Text("Wow, no expenses! You must be a financial wizard!"),
      );
    } else {
      mainContent = ExpensesList(
        expenses: expenses,
        onRemoveExpense: (expense){
          removeExpense(expense);
        },
        onEditExpense: (expense){
          editExpense(expense);
        },
      );
    }

    return Column(
      children: [
        FilterBar(
            expenses: expenses,
            filterByMonth: filterByMonth,
            filterByYear: filterByYear,
            onSelect: (month, year){
              filterExpenses(month, year);
            }),
        Expanded(
          child: mainContent,
        ),
      ],
    );
  }
}
