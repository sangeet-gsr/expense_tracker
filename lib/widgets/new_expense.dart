import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense, this.expense});

  final void Function(Expense, Command) onAddExpense;
  final Expense? expense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.groceries;
  var action = Command.add;

  @override
  void initState() {
    super.initState();
    if (widget.expense?.title != null) {
      action = Command.update;
    }
    _selectedDate = widget.expense?.date ?? DateTime.now(); // Set default date to current date
    _dateController.text =
        DateFormat('yyyy-MM-dd').format(_selectedDate!);
    _titleController.text = widget.expense?.title ?? '';
    _amountController.text = widget.expense?.amount.toString() ?? '';
    _selectedCategory = widget.expense?.category ?? Category.groceries;

  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount and date are provided'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }
    widget.onAddExpense(
        Expense(
            id: widget.expense?.id,
            title: _titleController.text,
            amount: enteredAmount,
            date: _selectedDate!,
            category: _selectedCategory),
        action);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Text(
              "${action == Command.add ? "Add a new": "Update"} expense",
              style: TextStyle(
                fontSize: 24,
                fontFamily: "Sharp Sans",
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          TextField(
            controller: _titleController,
            maxLength: 50,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              label: Text("Title"),
            ),
          ),
          //  const SizedBox(
          //   height: 16,
          // ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefix: Text('₹ '),
              label: Text("Amount"),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Date',
            ),
            readOnly: true,
            onTap: () async {
              _selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 1,
                    DateTime.now().month, DateTime.now().day),
                lastDate: DateTime.now(),
              );
              if (_selectedDate != null) {
                _dateController.text =
                    DateFormat('yyyy-MM-dd').format(_selectedDate!);
              }
            },
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please select a date';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          DropdownButtonFormField(
            dropdownColor: Theme.of(context).colorScheme.onPrimary,
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            value: _selectedCategory,
            items: Category.values
                .map(
                  (category) => DropdownMenuItem(
                      value: category,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name.substring(0, 1).toUpperCase() +
                              category.name.substring(1)), // Main text
                          Text(
                            categoryHelpers[category]!, // Helper text
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )),
                )
                .toList(),
            selectedItemBuilder: (BuildContext context) {
              return Category.values.map((Category category) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(category.name.substring(0, 1).toUpperCase() +
                      category.name
                          .substring(1)), // Only main text for selected item
                );
              }).toList();
            },
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  widget.onAddExpense(
                      Expense(
                        title: '',
                        amount: 0.0,
                        date: DateTime.now(),
                        category: Category.groceries,
                      ),
                      Command.cancel);
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(
                width: 20,
              ),
              FilledButton(
                onPressed: _submitExpenseData,
                child: Text('${action == Command.add ? "Add" : "Update"} Expense'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
