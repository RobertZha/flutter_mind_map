import 'package:flutter/material.dart';
import 'package:flutter_mind_map/link/i_link.dart';
import 'package:flutter_mind_map/mind_map.dart';

abstract class IMindMapNode {
  String getID();
  String getTitle();
  void setTitle(String value);

  MindMap? getMindMap();
  void setMindMap(MindMap value);
  NodeType getNodeType();
  void setNodeType(NodeType value);

  int getLevel();

  bool getExpanded();
  void setExpanded(bool value);

  ILink getLink();
  void setLink(ILink? value);
  Color getLinkColor();
  void setLinkColor(Color? value);

  double getLinkWidth();
  void setLinkWidth(double value);

  IMindMapNode? getParentNode();
  void setParentNode(IMindMapNode parentNode);
  int getHSpace();
  int getVSpace();

  List<IMindMapNode> getLeftItems();
  void setLeftItems(List<IMindMapNode> value);
  void addLeftItem(IMindMapNode item);
  void removeLeftItem(IMindMapNode item);
  void insertLeftItem(IMindMapNode item, int index);
  List<IMindMapNode> getRightItems();
  void setRightItems(List<IMindMapNode> value);
  void addRightItem(IMindMapNode item);
  void removeRightItem(IMindMapNode item);
  void insertRightItem(IMindMapNode item, int index);

  bool getReadOnly();
  bool canExpand();

  Offset? getOffset();
  void setOffset(Offset? value);
  Offset? getOffsetByParent();
  void setOffsetByParent(Offset? value);

  double getLinkInOffset();
  double getLinkOutOffset();

  Size? getSize();
  void setSize(Size? value);

  Rect? getLeftArea();
  Rect? getRightArea();
  Rect? getNodeArea();

  Offset getDragOffset();

  RenderObject? getRenderObject();
  void refresh();

  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}

enum NodeType { root, left, right }

Color stringToColor(String value) {
  if (value.startsWith("#") && value.length >= 9) {
    int alpha = int.parse(value.substring(1, 3), radix: 16);
    int colorValue = int.parse(value.substring(3, 9), radix: 16);
    return Color.fromARGB(
      0xff,
      colorValue >> 16,
      (colorValue >> 8) & 0xFF,
      colorValue & 0xFF,
    ).withOpacity(alpha / 255);
  }
  return Colors.black;
}

String colorToString(Color color) {
  String ax = color.alpha < 16 ? "0" : "";
  String rx = color.red < 16 ? "0" : "";
  String gx = color.green < 16 ? "0" : "";
  String bx = color.blue < 16 ? "0" : "";
  return "#${ax}${color.alpha.toRadixString(16)}${rx}${color.red.toRadixString(16)}${gx}${color.green.toRadixString(16)}${bx}${color.blue.toRadixString(16)}";
}
