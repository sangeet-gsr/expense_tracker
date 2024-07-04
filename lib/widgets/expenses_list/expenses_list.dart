import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key, required this.expenses, required this.onRemoveExpense, required this.onEditExpense});

  final List<Expense> expenses;

  final void Function(Expense expense) onRemoveExpense;
  final void Function(Expense expense) onEditExpense;

  Future<bool> _confirmDismiss(context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      itemCount: expenses.length,
      itemBuilder: (context, index) => Dismissible(
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.endToStart) {
            return await _confirmDismiss(context);
          }
          if (direction == DismissDirection.startToEnd) {
            return Future.value(true);
          }
          return false;
        },
        background: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.primary,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          alignment: Alignment.centerLeft,
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ),
        secondaryBackground: Container(
          // Secondary background for edit
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          alignment: Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        key: ValueKey(expenses[index]),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onRemoveExpense(expenses[index]);
          }
          if (direction == DismissDirection.startToEnd){
            onEditExpense(expenses[index]);
          }
        },
        child: ExpenseItem(
          expenses[index],
        ),
      ),
    );
  }
}
