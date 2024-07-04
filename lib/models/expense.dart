import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const uuid = Uuid();

final formatter = DateFormat.yMd();

enum Category { housing, groceries, transport, shopping, entertainment, dineout, health, utilities, others }

enum Command { add, update, cancel }

const categoryIcons = {
  Category.housing: Icons.home_rounded,
  Category.groceries: Icons.shopping_cart_rounded,
  Category.transport: Icons.two_wheeler_rounded,
  Category.shopping: Icons.shopping_bag_rounded,
  Category.entertainment: Icons.movie_filter_rounded,
  Category.dineout: Icons.restaurant_menu_rounded,
  Category.health: Icons.medication_rounded,
  Category.utilities: Icons.gas_meter_rounded,
  Category.others: Icons.miscellaneous_services_rounded,
};
const categoryHelpers = {
  Category.housing: 'Rent, Loans, Insurance, etc.',
  Category.groceries: 'Groceries, Food, Housing supplies etc.',
  Category.transport: 'Bike, Car, Public transport etc.',
  Category.shopping: 'Fashion, Electronics, etc.',
  Category.entertainment: 'Movies, Games, etc.',
  Category.dineout: 'Restaurants, Fast food, etc.',
  Category.health: 'Medicines, Doctor, etc.',
  Category.utilities: 'Electricity, Water, Gas, Internet, Mobile bills etc.',
  Category.others: 'Miscellaneous expenses.',
};

class Expense {
  Expense(
      {this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.category});

  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }

  String get categoryString {
    return category.toString().split('.').last;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': categoryString,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
    };
  }
}

class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }

    return sum;
  }
}
