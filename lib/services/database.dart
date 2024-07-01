import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database? _database;

  static const String _databaseName = 'expenses.db';
  static const int _databaseVersion = 1;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    // Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    // await deleteDatabase(path);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, amount DOUBLE NOT NULL, category TEXT NOT NULL, date TEXT NOT NULL)');
    });
  }

  Future<void> closeDatabase() async {
  if (_database != null) {
    await _database!.close();
    _database = null;
  }
}

  Future<void> addExpense(Expense expense) async {
    try {
      final db = await getDatabase();
      final e = expense.toMap();
      await db.insert('expenses', e,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } on Exception catch (e) {
      logger.e("Error adding expense: $e");
    }
  }

  Future<void> removeExpense(int id) async {
    final db = await getDatabase();
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getExpenses(filterByMonth, filterByYear) async {
    try {
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final db = await getDatabase();
      final List<Map<String, dynamic>> maps = await db.query('expenses', where: 'strftime("%m", date) = ? AND strftime("%Y", date) = ?', whereArgs: [filterByMonth, filterByYear], orderBy: 'date DESC');
      return [
        for (final {
          'id': id,
          'title': title,
          'amount': amount,
          'category': category,
          'date': date
        } in maps) Expense(id: id, title: title, amount: amount, date: formatter.parse(date), category: getCategoryFromString(category))
      ];
    } on Exception catch (e) {
      logger.e("Error fetching expenses: $e");
      return <Expense>[];
    }
  }

  Category getCategoryFromString(category) {
    try {
      return Category.values.firstWhere((e) => e.toString() == 'Category.$category');
    } catch (e) {
      return Category.others;
    }
  }
  // Add methods for CRUD operations
}
