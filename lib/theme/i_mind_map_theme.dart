import 'package:flutter/material.dart';

abstract class IMindMapTheme {
  Map<String, dynamic>? getThemeByLevel(int level);
  Color getBackgroundColor();
}
