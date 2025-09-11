import 'package:flutter/material.dart';
import 'package:flutter_mind_map/adapter/i_theme_adapter.dart';
import 'package:flutter_mind_map/link/beerse_line_link.dart';
import 'package:flutter_mind_map/link/poly_line_link.dart';
import 'package:flutter_mind_map/theme/i_mind_map_theme.dart';

class MyTheme implements IMindMapTheme {
  @override
  String getName() {
    return "MyTheme";
  }

  @override
  Map<String, dynamic>? getThemeByLevel(int level) {
    switch (level) {
      case 0:
        return {
          "BackgroundColor": Colors.white,
          "TextColor": Colors.black,
          "FontSize": 16.0,
          "Bold": true,
          "LinkColor": Colors.deepPurpleAccent,
          "LinkWidth": 1.5,
          "HSpace": 50,
          "VSpace": 20,
          "Border": Border.all(
            color: Colors.deepPurpleAccent,
            width: 2,
            style: BorderStyle.solid,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          "BorderRadius": BorderRadius.circular(100),
          "Padding": EdgeInsets.fromLTRB(20, 10, 20, 10),
          "Link": PolyLineLink(),
        };
      case 1:
        return {
          "BackgroundColor": Colors.transparent,
          "TextColor": Colors.black,
          "FontSize": 14.0,
          "HSpace": 50,
          "VSpace": 20,
          "Border": Border.all(color: Colors.deepOrangeAccent, width: 1.5),
          "BorderRadius": BorderRadius.circular(6),
          "Padding": EdgeInsets.fromLTRB(12, 6, 12, 6),
          "LinkWidth": 1.5,
          "LinkColors": [
            Colors.deepPurpleAccent,
            Colors.blueAccent,
            Colors.green,
            Colors.deepOrangeAccent,
            Colors.cyan,
            Colors.redAccent,
            Colors.brown,
          ],
          "BorderColors": [
            Colors.deepPurpleAccent,
            Colors.blueAccent,
            Colors.green,
            Colors.deepOrangeAccent,
            Colors.cyan,
            Colors.redAccent,
            Colors.brown,
          ],
          "Link": BeerseLineLink(),
        };
      case 2:
        return {
          "BackgroundColor": Colors.transparent,
          "TextColor": Colors.black,
          "FontSize": 12.0,
          "HSpace": 40,
          "VSpace": 10,
          "Border": Border.all(color: Colors.transparent, width: 0),
          "BorderRadius": BorderRadius.circular(0),
          "Padding": EdgeInsets.fromLTRB(6, 0, 6, 0),
          "LinkWidth": 1.0,
        };
    }
    return null;
  }

  @override
  Color getBackgroundColor() {
    return Colors.white;
  }
}

class MyThemeAdapter implements IThemeAdapter {
  @override
  IMindMapTheme createTheme() {
    return MyTheme();
  }

  @override
  String getName() {
    return "MyTheme";
  }
}
