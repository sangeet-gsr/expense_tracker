import 'package:expense_tracker/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                fontFamily: 'Inter' , scaffoldBackgroundColor: Colors.white)
            .copyWith(
                colorScheme: etColorScheme,
                appBarTheme: const AppBarTheme().copyWith(
                  backgroundColor: etColorScheme.primary,
                  foregroundColor: etColorScheme.onPrimary,
                ),
                cardTheme: const CardTheme().copyWith(
                  color: etColorScheme.onPrimary,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData()
                    .copyWith(
                        backgroundColor:
                            etColorScheme.primaryContainer.withOpacity(0.8),
                        foregroundColor: etColorScheme.onPrimaryContainer,
                        splashColor: etColorScheme.primaryContainer,
                        iconSize: 28),
                filledButtonTheme: FilledButtonThemeData(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(etColorScheme.primary),
                    foregroundColor:
                        WidgetStateProperty.all(etColorScheme.onPrimary),
                  ),
                ),
                navigationBarTheme: const NavigationBarThemeData().copyWith(
                  indicatorColor: etColorScheme.primaryContainer,
                  backgroundColor:
                      etColorScheme.primaryContainer.withOpacity(0.2),
                ),
                bottomSheetTheme: const BottomSheetThemeData().copyWith(
                    backgroundColor: etColorScheme.onPrimary,
                    modalBackgroundColor: etColorScheme.onPrimary),
                dialogTheme: const DialogTheme().copyWith(
                  backgroundColor: etColorScheme.onPrimary,
                ),
                datePickerTheme: const DatePickerThemeData().copyWith(
                  backgroundColor: etColorScheme.onPrimary,
                )),
        themeMode: ThemeMode.light,
        home: const MainScreen(),
      ),
    );
  }
}
