import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/database.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final databaseService = DatabaseService();
  List<Expense> expenses = [];
  var filterByMonth = DateTime.now().month;
  var filterByYear = DateTime.now().year;
  var selected = false;
  bool isLoading = true;
  var index = 0;
  var category = Category.groceries;
  Expense? editingExpense;

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
        expenses = expenses;
      });
    } catch (error) {
      logger.e(error);
    } finally {}
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: (addExpense, action) {
        if (action == Command.add) {
          _addExpense(addExpense, action);
        }
      }),
    );
  }

  Future<void> _addExpense(Expense expense, Command action) async {
    try {
      if (action == Command.add) {
        print("adding expense...");
        await databaseService.addExpense(expense);
        await _fetchExpenses(databaseService);
        setState(() {});
      }
    } on Exception catch (e) {
      logger.e("Error adding expense: $e");
    }
  }

  Future<void> _updateExpense(Expense expense, Command action) async {
    try {
      if (action == Command.update) {
        print("updating expense: ${expense.id}");
        print("updating expense: ${expense.title}");
        print("updating expense: ${expense.amount}");
        print("updating expense: ${expense.date}");
        print("updating expense: ${expense.category}");
        await databaseService.updateExpense(expense);
        await _fetchExpenses(databaseService);
        setState(() {});
      }
    } on Exception catch (e) {
      logger.e("Error adding expense: $e");
    }
  }

  void _openEditExpenseOverlay(Expense expense) {
    editingExpense = expense;
    final index = expenses.indexOf(expense);
    setState(() {
      expenses.remove(expense);
    });

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
          onAddExpense: (editedExpense, action) {
            print("action: $action");
            if (action == Command.cancel) {
              print("cancelling update");
              _restoreExpense(editingExpense, index);
            } else {
              _updateExpense(editedExpense, action);
            }
          },
          expense: expense),
    );
  }

  void _restoreExpense(Expense? expense, int index) {
    print("restoring expense");
    if (expense != null) {
      setState(() {
        expenses.insert(index, expense);
      });
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

  _switchScreen(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: const Text("Expense Tracker",
            style: TextStyle(
              fontFamily: 'Sharp Sans',
            )),
      ),
      body: index == 0
          ? Expenses(
              isLoading: isLoading,
              expenses: expenses,
              filterByMonth: filterByMonth,
              filterByYear: filterByYear,
              filterExpenses: _filterExpenses,
              removeExpense: _removeExpense,
              editExpense: _openEditExpenseOverlay,
            )
          : Chart(
              expenses: expenses,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseOverlay,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
          height: 50,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: index,
          onDestinationSelected: _switchScreen,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_rounded), label: "Home"),
            NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded), label: "Categories"),
          ]),
    );
  }
}
