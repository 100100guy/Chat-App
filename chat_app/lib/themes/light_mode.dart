// light mode theme

import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  // set colorScheme to a custom instance of ColorScheme
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Colors.grey.shade400,
    secondary: Colors.grey.shade100,
    tertiary: Colors.grey.shade50,
    inversePrimary: Colors.grey.shade800,
  ),
);
