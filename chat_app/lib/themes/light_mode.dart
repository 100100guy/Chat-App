// light mode theme

import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  // set colorScheme to a custom instance of ColorScheme
  colorScheme: ColorScheme.light(
    background: Colors.green.shade200,
    primary: Colors.green.shade300,
    secondary: Colors.green.shade100,
    tertiary: Colors.green.shade50,
    inversePrimary: Colors.green.shade900,
  ),
);
