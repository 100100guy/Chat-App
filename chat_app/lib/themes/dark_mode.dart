// light mode theme

import 'package:flutter/material.dart';

final ThemeData darkMode = ThemeData(
  // set colorScheme to a custom instance of ColorScheme
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade600,
    tertiary: Colors.grey.shade700,
    inversePrimary: Colors.grey.shade300,
  ),
);
