import 'package:expense_tracker/services/database.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/helper/custom_title.dart';
import 'package:expense_tracker/widgets/helper/filterbar.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> with WidgetsBindingObserver {
  final databaseService = DatabaseService();
  List<Expense> expenses = [];
  var filterByMonth = DateTime.now().month;
  var filterByYear = DateTime.now().year;
  var selected = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchExpenses(databaseService);
  }

  Future<void> _fetchExpenses(DatabaseService service) async {
    try {
      expenses = await service.getExpenses(
          filterByMonth.toString().padLeft(2, '0'), filterByYear.toString());

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      logger.e(error);
    } finally {}
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  Future<void> _addExpense(Expense expense) async {
    try {
      await databaseService.addExpense(expense);
      await _fetchExpenses(databaseService);
      setState(() {});
    } on Exception catch (e) {
      logger.e("Error adding expense: $e");
    }
  }

  Future<void> _removeExpense(Expense expense) async {
    final expenseIndex = expenses.indexOf(expense);
    if (expenseIndex == -1) {
      return;
    }

    setState(() {
      expenses.removeAt(expenseIndex);
    });

    final success = await _attemptRemoveExpenseFromDatabase(expense);

    if (!success) {
      setState(() {
        expenses.insert(expenseIndex, expense);
      });
      _showErrorMessage("Failed to delete expense. Please try again.");
      return;
    }

    // _showUndoSnackBar(expense, expenseIndex);
  }

  Future<bool> _attemptRemoveExpenseFromDatabase(Expense expense) async {
    try {
      await databaseService.removeExpense(expense.id!);
      return true;
    } catch (e) {
      // Consider logging the error
      return false;
    }
  }

  // void _showUndoSnackBar(Expense expense, int expenseIndex) {
  //   ScaffoldMessenger.of(context).clearSnackBars();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text("Expense deleted."),
  //       duration: const Duration(milliseconds: 3000),
  //       action: SnackBarAction(
  //         label: "Undo",
  //         onPressed: () async {
  //           setState(() {
  //             expenses.insert(expenseIndex, expense);
  //           });
  //           await databaseService.addExpense(expense);
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.7),
      ),
    );
  }

  Future<void> _filterExpenses(month, year) async {
    setState(() {
      filterByMonth = month;
      filterByYear = year;
    });
    await _fetchExpenses(databaseService);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DatabaseService().closeDatabase(); // Close the database connection
    super.dispose();
  }

  @override
  Widget build(context) {
    Widget mainContent;

    if (isLoading) {
      // Show spinner while loading
      mainContent = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (expenses.isEmpty) {
      // Show message if no expenses and not loading
      mainContent = const Center(
        child: Text("No expenses found. Start adding some!"),
      );
    } else {
      // Show expenses list if not loading and expenses are available
      mainContent = ExpensesList(
        expenses: expenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
        appBar: AppBar(
          // title: const CustomTitle(),
          title: const Text("Expense Tracker",
              style: TextStyle(
                fontFamily: 'Sharp Sans',
              )),
          // actions: [
          //   IconButton(
          //     iconSize: 32,
          //     onPressed: _openAddExpenseOverlay,
          //     icon: const Icon(Icons.add),
          //   ),
          // ],
        ),
        body: Column(
          children: [
            FilterBar(
                expenses: expenses,
                filterByMonth: filterByMonth,
                filterByYear: filterByYear,
                onSelect: _filterExpenses),
            Chart(
              expenses: expenses,
            ),
            Expanded(
              child: mainContent,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddExpenseOverlay,
          child: const Icon(Icons.add),
        ));
  }
}
