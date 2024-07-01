import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/services/database.dart';

var etColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(153, 38, 3, 99),
);

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(context) {
    return Provider(
      create: (context) => DatabaseService(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Inter',
          scaffoldBackgroundColor: Colors.white
        ).copyWith(
          colorScheme: etColorScheme,
          appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: etColorScheme.primary,
            foregroundColor: etColorScheme.onPrimary,
          ),
          cardTheme: const CardTheme().copyWith(
            shadowColor: etColorScheme.primaryContainer,
            color: etColorScheme.primaryContainer,
          ),
          floatingActionButtonTheme:
              const FloatingActionButtonThemeData().copyWith(
            backgroundColor: etColorScheme.primary,
            foregroundColor: etColorScheme.onPrimary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(etColorScheme.primary),
              foregroundColor:
                  WidgetStateProperty.all(etColorScheme.onPrimary),
            ),
          ),
        ),
        themeMode: ThemeMode.light,
        home: _getInitialScreen(),
      ),
    );
  }

   Widget _getInitialScreen() {
    // DateTime today = DateTime.now();
    // DateTime birthday = DateTime(today.year, 6, 28); // Set your birthday here

    // if (today.month == birthday.month && today.day == birthday.day) {
    //   return const OpeningScreen();
    // } else {
      return const Expenses();
    // }
  }
}
