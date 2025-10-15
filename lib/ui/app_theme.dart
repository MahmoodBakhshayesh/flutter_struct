import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color.fromRGBO(50, 118, 177, 1); // your main color
  final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'OpenSans',
    appBarTheme: const AppBarTheme(centerTitle: false),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}
