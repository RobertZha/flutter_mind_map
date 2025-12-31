// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_mind_map/adapter/i_theme_adapter.dart';
import 'package:flutter_mind_map/link/beerse_line_link.dart';
import 'package:flutter_mind_map/link/line_link.dart';
import 'package:flutter_mind_map/link/poly_line_link.dart';
import 'package:flutter_mind_map/mind_map_node.dart';
import 'package:flutter_mind_map/theme/i_mind_map_theme.dart';

///Create a Theme by json
class JsonTheme implements IMindMapTheme {
  /*
   * name: theme name 
   * json: theme json
   */
  JsonTheme(this.name, this.json) {
    for (String key in json.keys) {
      int? level = int.tryParse(key);
      if (level != null) {
        Map<String, dynamic>? theme = json[key];
        if (theme != null) {
          Map<String, dynamic> l = {};
          if (theme.containsKey("BackgroundColor")) {
            l["BackgroundColor"] = fromHex(theme["BackgroundColor"].toString());
          }
          if (theme.containsKey("TextColor")) {
            l["TextColor"] = fromHex(theme["TextColor"].toString());
          }
          if (theme.containsKey("FontSize")) {
            l["FontSize"] = double.tryParse(theme["FontSize"].toString()) ?? 12;
          }
          if (theme.containsKey("Bold")) {
            l["Bold"] = theme["Bold"];
          }
          if (theme.containsKey("LinkColor")) {
            l["LinkColor"] = fromHex(theme["LinkColor"].toString());
          }
          if (theme.containsKey("LinkWidth")) {
            l["LinkWidth"] = int.tryParse(theme["LinkWidth"].toString()) ?? 1;
          }
          if (theme.containsKey("HSpace")) {
            l["HSpace"] = int.tryParse(theme["HSpace"].toString()) ?? 50;
          }
          if (theme.containsKey("VSpace")) {
            l["VSpace"] = int.tryParse(theme["VSpace"].toString()) ?? 20;
          }
          if (theme.containsKey("Border")) {
            Map<String, dynamic> border = theme["Border"];
            Color color = Colors.transparent;
            double width = 0;
            double lw = 0;
            double tw = 0;
            double rw = 0;
            double bw = 0;
            if (border.containsKey("color")) {
              color = fromHex(border["color"].toString());
            }
            if (border.containsKey("width")) {
              if (border["width"] is String) {
                List<String> ls = border["width"].toString().split(",");
                if (ls.length == 4) {
                  lw = double.tryParse(ls[0]) ?? 0;
                  tw = double.tryParse(ls[1]) ?? 0;
                  rw = double.tryParse(ls[2]) ?? 0;
                  bw = double.tryParse(ls[3]) ?? 0;
                } else {
                  width = double.tryParse(ls[0]) ?? 0;
                }
              } else {
                width = double.tryParse(border["width"].toString()) ?? 0;
              }
            }
            if (lw > 0 || tw > 0 || rw > 0 || bw > 0) {
              l["Border"] = Border(
                left: lw == 0
                    ? BorderSide.none
                    : BorderSide(
                        color: color,
                        width: lw,
                        style: BorderStyle.solid,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                top: tw == 0
                    ? BorderSide.none
                    : BorderSide(
                        color: color,
                        width: tw,
                        style: BorderStyle.solid,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                right: rw == 0
                    ? BorderSide.none
                    : BorderSide(
                        color: color,
                        width: rw,
                        style: BorderStyle.solid,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                bottom: bw == 0
                    ? BorderSide.none
                    : BorderSide(
                        color: color,
                        width: bw,
                        style: BorderStyle.solid,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
              );
            } else {
              l["Border"] = Border.all(
                color: color,
                width: width,
                style: BorderStyle.solid,
                strokeAlign: BorderSide.strokeAlignOutside,
              );
            }
          }
          if (theme.containsKey("BorderRadius")) {
            l["BorderRadius"] = BorderRadius.circular(
              double.tryParse(theme["BorderRadius"].toString()) ?? 0,
            );
          }
          if (theme.containsKey("Padding")) {
            l["Padding"] = EdgeInsets.fromLTRB(
              double.tryParse((theme["Padding"]["left"] ?? "0").toString()) ??
                  0,
              double.tryParse((theme["Padding"]["top"] ?? "0").toString()) ?? 0,
              double.tryParse((theme["Padding"]["right"] ?? "0").toString()) ??
                  0,
              double.tryParse((theme["Padding"]["bottom"] ?? "0").toString()) ??
                  0,
            );
          }
          if (theme.containsKey("Link")) {
            switch (theme["Link"].toString()) {
              case "PolyLineLink":
                l["Link"] = PolyLineLink();
                break;
              case "BeerseLineLink":
                l["Link"] = BeerseLineLink();
                break;
              case "LineLink":
                l["Link"] = LineLink();
                break;
            }
          }
          if (theme.containsKey("BorderColors")) {
            l["BorderColors"] = [];
            for (int i = 0; i < theme["BorderColors"].length; i++) {
              l["BorderColors"].add(fromHex(theme["BorderColors"][i]));
            }
          }
          if (theme.containsKey("LinkColors")) {
            l["LinkColors"] = [];
            for (int i = 0; i < theme["LinkColors"].length; i++) {
              l["LinkColors"].add(fromHex(theme["LinkColors"][i]));
            }
          }
          if (theme.containsKey("BackgroundColors")) {
            l["BackgroundColors"] = [];
            for (int i = 0; i < theme["BackgroundColors"].length; i++) {
              l["BackgroundColors"].add(fromHex(theme["BackgroundColors"][i]));
            }
          }
          if (theme.containsKey("LinkOutOffsetMode")) {
            switch (theme["LinkOutOffsetMode"]) {
              case "top":
                l["LinkOutOffsetMode"] = MindMapNodeLinkOffsetMode.top;
                break;
              case "center":
                l["LinkOutOffsetMode"] = MindMapNodeLinkOffsetMode.center;
                break;
              case "bottom":
                l["LinkOutOffsetMode"] = MindMapNodeLinkOffsetMode.bottom;
                break;
            }
          }
          if (theme.containsKey("LinkInOffsetMode")) {
            switch (theme["LinkInOffsetMode"]) {
              case "top":
                l["LinkInOffsetMode"] = MindMapNodeLinkOffsetMode.top;
                break;
              case "center":
                l["LinkInOffsetMode"] = MindMapNodeLinkOffsetMode.center;
                break;
              case "bottom":
                l["LinkInOffsetMode"] = MindMapNodeLinkOffsetMode.bottom;
                break;
            }
          }

          jsonList[level] = l;
        }
      }
    }
  }

  Map<String, dynamic> json;

  /// BackgroundColor
  @override
  Color getBackgroundColor() {
    return Colors.transparent;
  }

  String name = "";

  /// Theme name
  @override
  String getName() {
    return name;
  }

  Map<int, Map<String, dynamic>> jsonList = {};

  /// Get theme by level
  @override
  Map<String, dynamic>? getThemeByLevel(int level) {
    return jsonList[level];
  }

  /// Convert hex to color
  Color fromHex(String hexString) {
    if (hexString.startsWith("#") && hexString.length == 9) {
      int? alpha = int.tryParse(hexString.substring(1, 3), radix: 16);
      int? colorValue = int.tryParse(hexString.substring(3, 9), radix: 16);
      if (alpha != null && colorValue != null) {
        return Color.fromARGB(
          0xff,
          colorValue >> 16,
          (colorValue >> 8) & 0xFF,
          colorValue & 0xFF,
        ).withOpacity(alpha / 255);
      }
    }
    return Colors.transparent;
  }

  /// Convert color to hex
  String toHex(
    Color color, {
    bool includeHashSign = false,
    bool enableAlpha = true,
    bool toUpperCase = true,
  }) {
    final String hex =
        (includeHashSign ? '#' : '') +
        (enableAlpha ? _radix(color.alpha) : '') +
        _radix(color.red) +
        _radix(color.green) +
        _radix(color.blue);
    return toUpperCase ? hex.toUpperCase() : hex;
  }

  String _radix(int value) => value.toRadixString(16).padLeft(2, '0');
}

///Json theme adapter
class JsonThemeAdapter implements IThemeAdapter {
  JsonThemeAdapter(this.theme);
  @override
  IMindMapTheme createTheme() {
    return theme;
  }

  JsonTheme theme;

  @override
  String getName() {
    return theme.getName();
  }
}
