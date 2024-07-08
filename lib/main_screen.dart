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
            if (action == Command.cancel) {
              _restoreExpense(editingExpense, index);
            } else {
              _updateExpense(editedExpense, action);
            }
          },
          expense: expense),
    );
  }

  void _restoreExpense(Expense? expense, int index) {
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

  Future<void> _showDialog(ExpenseBucket bucket) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            bucket.category.name.substring(0, 1).toUpperCase() +
                bucket.category.name.substring(1),
          ),
          titleTextStyle: const TextStyle().copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          content: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var expense in bucket.expenses)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(expense.title),
                          Text(
                            expense.amount.toStringAsFixed(2),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            const Divider(
              thickness: 1,
            ),
            Text(
              bucket.totalExpenses.toStringAsFixed(2),
            ),
          ],
        );
      },
    );
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
          : Chart(expenses: expenses, onShowDialog: _showDialog),
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
