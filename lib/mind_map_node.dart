import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map/adapter/i_node_adapter.dart';
import 'package:flutter_mind_map/base64_image_validator.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/beerse_line_link.dart';
import 'package:flutter_mind_map/link/i_link.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class MindMapNode extends StatefulWidget implements IMindMapNode {
  MindMapNode({super.key});

  @override
  void clearStyle() {
    _backgroundColor = null;
    _backgroundColors = [];
    _border = null;
    _borderColors = [];
    _borderRadius = null;
    _hSpace = null;
    _vSpace = null;
    _link = null;
    _linkColor = null;
    _linkColors = [];
    _padding = null;
    _shadow = null;
    _textStyle = null;
    for (IMindMapNode node in getLeftItems()) {
      node.clearStyle();
    }
    for (IMindMapNode node in getRightItems()) {
      node.clearStyle();
    }
  }

  ///Export Data to JSON
  @override
  Map<String, dynamic> getData() {
    List<Map<String, dynamic>> list = [];
    List<Map<String, dynamic>> leftlist = [];

    for (IMindMapNode n in getLeftItems()) {
      if (getNodeType() == NodeType.root) {
        leftlist.add(n.getData());
      } else {
        list.add(n.getData());
      }
    }

    for (IMindMapNode n in getRightItems()) {
      list.add(n.getData());
    }

    Map<String, dynamic> json = leftlist.isEmpty
        ? {"id": getID(), "content": getTitle(), "nodes": list}
        : {
            "id": getID(),
            "content": getTitle(),
            "image": _image,
            "iamge2": _image2,
            "extended": getExtended(),
            "leftNodes": leftlist,
            "nodes": list,
          };
    return json;
  }

  bool _isLoading = false;

  ///Import Data from JSON
  @override
  void loadData(Map<String, dynamic> json) {
    _isLoading = true;
    if (json.containsKey("id") &&
        json.containsKey("content") &&
        json.containsKey("nodes")) {
      setID(json["id"].toString());
      setTitle(json["content"].toString());
      setImage(json["image"] ?? "");
      setImage2(json["image2"] ?? "");
      setExtended(json["extended"] ?? "");
      List<dynamic> list = json["nodes"];
      if (list.isNotEmpty) {
        for (Map<String, dynamic> j in list) {
          if (j.containsKey("id") &&
              j.containsKey("content") &&
              j.containsKey("nodes")) {
            MindMapNode node = MindMapNode();
            if (getParentNode() == null) {
              addRightItem(node);
            } else {
              if (getNodeType() == NodeType.left) {
                addLeftItem(node);
              } else {
                addRightItem(node);
              }
            }
            node.loadData(j);
          }
        }
      }
      if (json["leftNodes"] != null) {
        List<dynamic> leftList = json["leftNodes"];
        for (Map<String, dynamic> j in leftList) {
          if (j.containsKey("id") &&
              j.containsKey("content") &&
              j.containsKey("nodes")) {
            MindMapNode node = MindMapNode();
            addLeftItem(node);
            node.loadData(j);
          }
        }
      }
    }
    if (getNodeType() == NodeType.root) {
      switch (getMindMap()?.getMindMapType() ?? MindMapType.leftAndRight) {
        case MindMapType.leftAndRight:
          if (getLeftItems().isNotEmpty && getRightItems().isEmpty) {
            while (getLeftItems().isNotEmpty) {
              IMindMapNode node = getLeftItems().first;
              removeLeftItem(node);
              addRightItem(node);
            }
          }
          if (getLeftItems().isEmpty && getRightItems().isNotEmpty) {
            while (getRightItems().length > getLeftItems().length + 1) {
              IMindMapNode node = getRightItems().last;
              removeRightItem(node);
              addLeftItem(node);
            }
          }

          break;
        case MindMapType.left:
          if (getLeftItems().isNotEmpty && getRightItems().isNotEmpty) {
            while (getLeftItems().isNotEmpty) {
              IMindMapNode node = getLeftItems().last;
              removeLeftItem(node);
              addRightItem(node);
            }
          }
          while (getRightItems().isNotEmpty) {
            IMindMapNode node = getRightItems().first;
            removeRightItem(node);
            addLeftItem(node);
          }
          break;
        case MindMapType.right:
          if (getLeftItems().isNotEmpty && getRightItems().isNotEmpty) {
            while (getLeftItems().isNotEmpty) {
              IMindMapNode node = getLeftItems().last;
              removeLeftItem(node);
              addRightItem(node);
            }
          } else {
            while (getLeftItems().isNotEmpty) {
              IMindMapNode node = getLeftItems().first;
              removeLeftItem(node);
              addRightItem(node);
            }
          }
          break;
      }
    }
    _isLoading = false;
  }

  ///Export Data&Style to JSON
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> properties = {};
    properties["ID"] = _id;
    properties["Title"] = _title;
    properties["Extended"] = _extended;
    properties["Image"] = _image;
    properties["Image2"] = _image2;
    if (_image2Width != null) {
      properties["ImageWidth"] = _imageWidth;
    }
    if (_imageHeight != null) {
      properties["ImageHeight"] = _imageHeight;
    }
    if (_imageSpace != null) {
      properties["ImageSpace"] = _imageSpace;
    }
    properties["ImagePosition"] = _imagePosition.name;
    if (_image2Width != null) {
      properties["Image2Width"] = _image2Width;
    }
    if (_image2Height != null) {
      properties["Image2Height"] = _image2Height;
    }
    properties["Expanded"] = _expanded.toString();
    if (_link != null) {
      properties["Link"] = _link!.getName();
    }
    if (_linkColor != null) {
      properties["LinkColor"] = colorToString(_linkColor!);
    }
    if (_linkColors.isNotEmpty) {
      List<String> l = [];
      for (Color c in _linkColors) {
        l.add(colorToString(c));
      }
      properties["LinkColors"] = l;
    }
    if (_linkWidth != null) {
      properties["LinkWidth"] = _linkWidth.toString();
    }
    if (_borderColors.isNotEmpty) {
      List<String> l = [];
      for (Color c in _borderColors) {
        l.add(colorToString(c));
      }
      properties["BorderColors"] = l;
    }
    if (_hSpace != null) {
      properties["HSpace"] = _hSpace.toString();
    }
    if (_vSpace != null) {
      properties["VSpace"] = _vSpace.toString();
    }
    if (_backgroundColor != null) {
      properties["BackgroundColor"] = colorToString(_backgroundColor!);
    }
    if (_border != null) {
      properties["Border"] = {
        "Top": {
          "Color": colorToString(_border!.top.color),
          "Width": _border!.top.width.toString(),
        },
        "Left": {
          "Color": colorToString((_border as Border).left.color),
          "Width": (_border as Border).right.width.toString(),
        },
        "Bottom": {
          "Color": colorToString(_border!.bottom.color),
          "Width": _border!.bottom.width.toString(),
        },
        "Right": {
          "Color": colorToString((_border as Border).right.color),
          "Width": (_border as Border).right.width.toString(),
        },
      };
    }
    if (_borderRadius != null) {
      properties["BorderRadius"] = (_borderRadius as BorderRadius).bottomLeft.x
          .toString();
    }
    if (_padding != null) {
      properties["Padding"] = {
        "Left": _padding!.left.toString(),
        "Top": _padding!.top.toString(),
        "Right": _padding!.right.toString(),
        "Bottom": _padding!.bottom.toString(),
      };
    }
    if (_textStyle != null) {
      Color color = _textStyle!.color ?? Colors.black;
      properties["TextStyle"] = {
        "Color": colorToString(color),
        "FontSize": (_textStyle!.fontSize ?? 16).toString(),
        "Bold": _textStyle!.fontWeight == FontWeight.bold,
      };
    }
    if (_linkInOffsetMode != null) {
      properties["LinkInOffsetMode"] = _linkInOffsetMode!.name;
    }
    if (_linkOutOffsetMode != null) {
      properties["LinkOutOffsetMode"] = _linkOutOffsetMode!.name;
    }
    if (_linkOutPadding != null && _linkOutPadding != 0) {
      properties["LinkOutPadding"] = _linkOutPadding;
    }
    List<Map<String, dynamic>> leftNodes = [];
    for (IMindMapNode node in _leftItems) {
      leftNodes.add(node.toJson());
    }
    List<Map<String, dynamic>> rightNodes = [];
    for (IMindMapNode node in _rightItems) {
      rightNodes.add(node.toJson());
    }
    Map<String, dynamic> json = {
      "MindMapNode": {
        "Nodes": {"Left": leftNodes, "Right": rightNodes},
        "Properties": properties,
      },
    };
    return json;
  }

  ///Load Data&Style from JSON
  @override
  void fromJson(Map<String, dynamic> json) {
    _isLoading = true;
    if (json.containsKey("MindMapNode")) {
      Map<String, dynamic> nodeJson = json["MindMapNode"];
      if (nodeJson.containsKey("Properties")) {
        Map<String, dynamic> proJson = nodeJson["Properties"];

        if (proJson.containsKey("ID")) {
          setID(proJson["ID"].toString());
        }
        if (proJson.containsKey("Title")) {
          setTitle(proJson["Title"].toString());
        }
        if (proJson.containsKey("Image")) {
          setImage(proJson["Image"].toString());
        }
        if (proJson.containsKey("ImageWidth")) {
          setImageWidth(
            double.tryParse(proJson["ImageWidth"].toString()) ?? 16,
          );
        }
        if (proJson.containsKey("ImageHeight")) {
          setImageHeight(
            double.tryParse(proJson["ImageHeight"].toString()) ?? 16,
          );
        }
        if (proJson.containsKey("ImageSpace")) {
          setImageSpace(double.tryParse(proJson["ImageSpace"].toString()) ?? 8);
        }
        if (proJson.containsKey("ImagePosition")) {
          for (var item in MindMapNodeImagePosition.values) {
            if (item.name == proJson["ImagePosition"].toString()) {
              setImagePosition(item);
              break;
            }
          }
        }

        if (proJson.containsKey("Image2")) {
          setImage2(proJson["Image2"].toString());
        }
        if (proJson.containsKey("Image2Width")) {
          setImage2Width(
            double.tryParse(proJson["Image2Width"].toString()) ?? 16,
          );
        }
        if (proJson.containsKey("Image2Height")) {
          setImage2Height(
            double.tryParse(proJson["Image2Height"].toString()) ?? 16,
          );
        }
        if (proJson.containsKey("Extended")) {
          setExtended(proJson["Extended"].toString());
        }

        if (proJson.containsKey("Expanded")) {
          setExpanded(bool.tryParse(proJson["Expanded"].toString()) ?? true);
        }
        if (proJson.containsKey("Link")) {
          ILink? link = getMindMap()?.createLink(proJson["Link"].toString());
          if (link != null) {
            setLink(link);
          }
        }
        if (proJson.containsKey("LinkColor")) {
          setLinkColor(stringToColor(proJson["LinkColor"].toString()));
        }
        if (proJson.containsKey("LinkColors")) {
          if (proJson["LinkColors"] is List) {
            List<Color> list = [];
            for (String s in proJson["LinkColors"]) {
              list.add(stringToColor(s));
            }
            if (list.isNotEmpty) {
              setLinkColors(list);
            }
          }
        }
        if (proJson.containsKey("LinkWidth")) {
          setLinkWidth(double.tryParse(proJson["LinkWidth"]));
        }
        if (proJson.containsKey("BorderColors")) {
          if (proJson["BorderColors"] is List) {
            List<Color> list = [];
            for (String s in proJson["BorderColors"]) {
              list.add(stringToColor(s));
            }
            if (list.isNotEmpty) {
              setBorderColors(list);
            }
          }
        }
        if (proJson.containsKey("HSpace")) {
          setHSpace(int.tryParse(proJson["HSpace"]) ?? 50);
        }
        if (proJson.containsKey("VSpace")) {
          setVSpace(int.tryParse(proJson["VSpace"]) ?? 20);
        }
        if (proJson.containsKey("BackgroundColor")) {
          setBackgroundColor(stringToColor(proJson["BackgroundColor"]));
        }
        if (proJson.containsKey("Border")) {
          Color? topColor;
          double? topWidth;
          Color? leftColor;
          double? leftWidth;
          Color? bottomColor;
          double? bottomWidth;
          Color? rightColor;
          double? rightWidth;
          Map<String, dynamic> borderJson = proJson["Border"];
          if (borderJson.containsKey("Top")) {
            Map<String, dynamic> topJson = borderJson["Top"];
            if (topJson.containsKey("Color")) {
              topColor = stringToColor(topJson["Color"]);
            }
            if (topJson.containsKey("Width")) {
              topWidth = double.tryParse(topJson["Width"]);
            }
          }
          if (borderJson.containsKey("Left")) {
            Map<String, dynamic> leftJson = borderJson["Left"];
            if (leftJson.containsKey("Color")) {
              leftColor = stringToColor(leftJson["Color"]);
            }
            if (leftJson.containsKey("Width")) {
              leftWidth = double.tryParse(leftJson["Width"]);
            }
          }
          if (borderJson.containsKey("Bottom")) {
            Map<String, dynamic> bottomJson = borderJson["Bottom"];
            if (bottomJson.containsKey("Color")) {
              bottomColor = stringToColor(bottomJson["Color"]);
            }
            if (bottomJson.containsKey("Width")) {
              bottomWidth = double.tryParse(bottomJson["Width"]);
            }
          }
          if (borderJson.containsKey("Right")) {
            Map<String, dynamic> rightJson = borderJson["Right"];
            if (rightJson.containsKey("Color")) {
              rightColor = stringToColor(rightJson["Color"]);
            }
            if (rightJson.containsKey("Width")) {
              rightWidth = double.tryParse(rightJson["Width"]);
            }
          }

          setBorder(
            Border(
              top: topColor == null || topWidth == null || topWidth <= 0
                  ? BorderSide.none
                  : BorderSide(
                      color: topColor,
                      width: topWidth,
                      style: BorderStyle.solid,
                    ),
              left: leftColor == null || leftWidth == null || leftWidth <= 0
                  ? BorderSide.none
                  : BorderSide(
                      color: leftColor,
                      width: leftWidth,
                      style: BorderStyle.solid,
                    ),
              bottom:
                  bottomColor == null || bottomWidth == null || bottomWidth <= 0
                  ? BorderSide.none
                  : BorderSide(
                      color: bottomColor,
                      width: bottomWidth,
                      style: BorderStyle.solid,
                    ),
              right: rightColor == null || rightWidth == null || rightWidth <= 0
                  ? BorderSide.none
                  : BorderSide(
                      color: rightColor,
                      width: rightWidth,
                      style: BorderStyle.solid,
                    ),
            ),
          );
        }
        if (proJson.containsKey("BorderRadius")) {
          setBorderRadius(
            BorderRadius.circular(
              double.tryParse(proJson["BorderRadius"].toString()) ?? 0,
            ),
          );
        }
        if (proJson.containsKey("Padding")) {
          Map<String, dynamic> padJson = proJson["Padding"];
          double? left;
          double? top;
          double? right;
          double? bottom;
          if (padJson.containsKey("Left")) {
            left = double.tryParse(padJson["Left"]);
          }
          if (padJson.containsKey("Top")) {
            top = double.tryParse(padJson["Top"]);
          }
          if (padJson.containsKey("Right")) {
            right = double.tryParse(padJson["Right"]);
          }
          if (padJson.containsKey("Bottom")) {
            bottom = double.tryParse(padJson["Bottom"]);
          }
          if (left != null || top != null || right != null || bottom != null) {
            setPadding(
              EdgeInsets.fromLTRB(left ?? 0, top ?? 0, right ?? 0, bottom ?? 0),
            );
          }
        }
        if (proJson.containsKey("TextStyle")) {
          Map<String, dynamic> tsJson = proJson["TextStyle"];
          Color? color;
          double? fontSize;
          bool? bold;
          if (tsJson.containsKey("Color")) {
            color = stringToColor(tsJson["Color"]);
          }
          if (tsJson.containsKey("FontSize")) {
            fontSize = double.tryParse(tsJson["FontSize"]);
          }
          if (tsJson.containsKey("Bold")) {
            bold = bool.tryParse(tsJson["Bold"].toString());
          }
          if (color != null || fontSize != null || bold != null) {
            setTextStyle(
              TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: bold == true ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }
        }
        if (proJson.containsKey("LinkInOffsetMode")) {
          for (MindMapNodeLinkOffsetMode o
              in MindMapNodeLinkOffsetMode.values) {
            if (o.name == proJson["LinkInOffsetMode"]) {
              setLinkInOffsetMode(o);
              break;
            }
          }
        }
        if (proJson.containsKey("LinkOutOffsetMode")) {
          for (MindMapNodeLinkOffsetMode o
              in MindMapNodeLinkOffsetMode.values) {
            if (o.name == proJson["LinkOutOffsetMode"]) {
              setLinkOutOffsetMode(o);
              break;
            }
          }
        }
        if (proJson.containsKey("LinkOutPadding")) {
          setLinkOutPadding(
            double.tryParse(proJson["LinkOutPadding"].toString()) ?? 0,
          );
        }
      }
      if (nodeJson.containsKey("Nodes")) {
        Map<String, dynamic> nodes = nodeJson["Nodes"];
        if (nodes.containsKey("Left")) {
          for (Map<String, dynamic> l in nodes["Left"]) {
            if (l.isNotEmpty) {
              IMindMapNode? n = getMindMap()?.createNode(l.keys.first);
              if (n != null) {
                addLeftItem(n);
                n.fromJson(l);
              }
            }
          }
        }
        if (nodes.containsKey("Right")) {
          for (Map<String, dynamic> r in nodes["Right"]) {
            if (r.isNotEmpty) {
              IMindMapNode? n = getMindMap()?.createNode(r.keys.first);
              if (n != null) {
                addRightItem(n);
                n.fromJson(r);
              }
            }
          }
        }
      }
    }
    _isLoading = false;
  }

  /// add left child node
  void addLeftChildNode() {
    MindMapNode node = MindMapNode();
    node.setParentNode(this);
    node.setTitle("New Node");
    if (getNodeType() == NodeType.root && getRightItems().isNotEmpty) {
      insertLeftItem(node, 0);
    } else {
      addLeftItem(node);
    }
    getMindMap()?.refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  /// add right child node
  void addRightChildNode() {
    MindMapNode node = MindMapNode();
    node.setParentNode(this);
    node.setTitle("New Node");
    addRightItem(node);
    getMindMap()?.refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  bool? _canExpand;

  ///set can expand
  void setCanExpand(bool value) {
    _canExpand = value;
  }

  /// can expand
  @override
  bool canExpand() {
    if (_canExpand != null) {
      return _canExpand!;
    } else {
      return getParentNode() != null ? getParentNode()!.canExpand() : true;
    }
  }

  bool _expanded = false;

  ///Expanded
  @override
  bool getExpanded() {
    if (getLevel() < (getMindMap()?.getExpandedLevel() ?? 0) - 1) {
      return true;
    }
    return _expanded;
  }

  /// set expanded
  @override
  void setExpanded(bool value) {
    if (_expanded != value) {
      _expanded = value;
      _state?.refresh();
      if (getMindMap() != null) {
        getMindMap()!.refresh();
        if (!_isLoading) {
          getMindMap()?.onChanged();
        }
      }
    }
  }

  /// Selected
  bool getSelected() {
    if (getMindMap() != null && getMindMap()!.getSelectedNode() == this) {
      return true;
    }
    return false;
  }

  /// Level
  @override
  int getLevel() {
    if (getParentNode() != null) {
      return getParentNode()!.getLevel() + 1;
    } else {
      return 0;
    }
  }

  ILink? _link;

  /// Link
  @override
  ILink getLink() {
    return _link != null
        ? _link!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Link"]
                      is ILink
              ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Link"]
                    as ILink
              : (getParentNode() != null
                    ? getParentNode()!.getLink()
                    : BeerseLineLink()));
  }

  /// set link
  @override
  void setLink(ILink? value) {
    _link = value;
    _state?.refresh();
    if (!_isLoading) {
      getMindMap()?.refresh();
      getMindMap()?.onChanged();
    }
  }

  Color? _linkColor;

  /// Link Color
  @override
  Color getLinkColor() {
    if (_linkColor != null) {
      return _linkColor!;
    }
    List<Color> list = getLinkColors();
    if (list.isNotEmpty) {
      int index = 0;
      if (getParentNode() != null) {
        List<IMindMapNode> list1 = [];
        if (getParentNode()!.getNodeType() == NodeType.root) {
          list1.addAll(getParentNode()!.getRightItems());
          for (int i = 0; i < getParentNode()!.getLeftItems().length; i++) {
            IMindMapNode node = getParentNode()!
                .getLeftItems()[getParentNode()!.getLeftItems().length - i - 1];
            list1.add(node);
          }
        } else {
          list1.addAll(getParentNode()!.getRightItems());
          list1.addAll(getParentNode()!.getLeftItems());
        }
        index = list1.indexOf(this);
      }
      return list[index % list.length];
    }
    return (getMindMap()?.getTheme() != null &&
            getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
            getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["LinkColor"]
                is Color
        ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["LinkColor"]
              as Color
        : (getParentNode() != null
              ? getParentNode()!.getLinkColor()
              : Colors.black));
  }

  /// set link color
  @override
  void setLinkColor(Color? value) {
    _linkColor = value;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  List<Color> _linkColors = [];

  /// Link Colors
  List<Color> getLinkColors() {
    if (_linkColors.isNotEmpty) {
      return _linkColors;
    } else {
      if (getMindMap()?.getTheme() != null &&
          getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
          getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["LinkColors"]
              is List) {
        List<Color> list = [];
        for (dynamic v
            in getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["LinkColors"]
                as List) {
          if (v is Color) {
            list.add(v);
          }
        }
        if (list.isNotEmpty) {
          return list;
        }
      }
    }
    return [];
  }

  /// set link colors
  void setLinkColors(List<Color> value) {
    _linkColors = value;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  double? _linkWidth;

  /// Link Width
  @override
  double getLinkWidth() {
    return _linkWidth != null
        ? _linkWidth!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(
                        getLevel(),
                      )!["LinkWidth"] !=
                      null
              ? double.tryParse(
                      getMindMap()!
                          .getTheme()!
                          .getThemeByLevel(getLevel())!["LinkWidth"]!
                          .toString(),
                    ) ??
                    1
              : (getParentNode() != null
                    ? getParentNode()!.getLinkWidth()
                    : 1));
  }

  /// set link width
  @override
  void setLinkWidth(double? value) {
    _linkWidth = value;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  List<Color> _borderColors = [];

  /// Border Colors
  List<Color> getBorderColors() {
    if (_borderColors.isNotEmpty) {
      return _borderColors;
    } else {
      if (getMindMap()?.getTheme() != null &&
          getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
          getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["BorderColors"]
              is List) {
        List<Color> list = [];
        for (dynamic v
            in getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["BorderColors"]
                as List) {
          if (v is Color) {
            list.add(v);
          }
        }
        if (list.isNotEmpty) {
          return list;
        }
      }
    }
    return [];
  }

  /// set border colors
  void setBorderColors(List<Color> value) {
    _borderColors = value;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  IMindMapNode? _parentNode;

  /// Parent Node
  @override
  IMindMapNode? getParentNode() {
    return _parentNode;
  }

  /// set parent node
  @override
  void setParentNode(IMindMapNode value) {
    _parentNode = value;
  }

  int? _hSpace;
  int? _vSpace;

  /// HSpace
  @override
  int getHSpace() {
    int bw = getMindMap()?.getButtonWidth() ?? 24;
    return _hSpace ??
        (getMindMap()?.getTheme() != null &&
                getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
                getMindMap()?.getTheme()?.getThemeByLevel(
                      getLevel(),
                    )!["HSpace"] !=
                    null
            ? int.tryParse(
                    getMindMap()!
                        .getTheme()!
                        .getThemeByLevel(getLevel())!["HSpace"]!
                        .toString(),
                  ) ??
                  0
            : (getParentNode() != null
                  ? getParentNode()!.getHSpace()
                  : (bw * 2 + 40)));
  }

  /// set hspace
  void setHSpace(int value) {
    _hSpace = value;
    refresh();
    getMindMap()?.refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  /// VSpace
  @override
  int getVSpace() {
    return _vSpace ??
        (getMindMap()?.getTheme() != null &&
                getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
                getMindMap()?.getTheme()?.getThemeByLevel(
                      getLevel(),
                    )!["VSpace"] !=
                    null
            ? int.tryParse(
                    getMindMap()!
                        .getTheme()!
                        .getThemeByLevel(getLevel())!["VSpace"]!
                        .toString(),
                  ) ??
                  0
            : (getParentNode() != null ? getParentNode()!.getVSpace() : 20));
  }

  /// set vspace
  void setVSpace(int value) {
    _vSpace = value;
    refresh();
    getMindMap()?.refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  @override
  State<StatefulWidget> createState() => MindMapNodeState();

  MindMapNodeState? _state;

  /// refresh
  @override
  void refresh() {
    if (_state != null) {
      _state!.refresh();

      ///getMindMap()?.refresh();
    }
  }

  String _id = Uuid().v1();

  /// ID
  @override
  String getID() {
    return _id;
  }

  /// set id
  void setID(String id) {
    _id = id;
  }

  String _title = "";

  /// Title
  @override
  String getTitle() {
    return _title;
  }

  /// set title
  @override
  void setTitle(String value) {
    if (_title != value) {
      _title = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  String _oldImageBase64 = "";
  Uint8List? image;

  String _image = "";
  String getImage() {
    if (_image.isEmpty) {
      return (getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Image"] !=
                  null
          ? getMindMap()!
                .getTheme()!
                .getThemeByLevel(getLevel())!["Image"]!
                .toString()
          : "");
    } else {
      return _image;
    }
  }

  void setImage(String value) {
    if (_image != value) {
      _oldImageBase64 = "";
      image = null;
      _image = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  MindMapNodeImagePosition _imagePosition = MindMapNodeImagePosition.left;

  MindMapNodeImagePosition getImagePosition() {
    if (getMindMap()?.getMapType() == MapType.fishbone &&
        getNodeType() == NodeType.root) {
      return getMindMap()?.getFishboneMapType() == FishboneMapType.leftToRight
          ? MindMapNodeImagePosition.right
          : MindMapNodeImagePosition.left;
    }
    return _imagePosition;
  }

  void setImagePosition(MindMapNodeImagePosition value) {
    if (_imagePosition != value) {
      _imagePosition = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  double? _imageWidth;
  double getImageWidth() {
    if (getImage().isEmpty) {
      return 0;
    }
    return _imageWidth != null
        ? _imageWidth!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(
                        getLevel(),
                      )!["ImageWidth"] !=
                      null
              ? double.tryParse(
                      getMindMap()!
                          .getTheme()!
                          .getThemeByLevel(getLevel())!["ImageWidth"]!
                          .toString(),
                    ) ??
                    0
              : 16);
  }

  void setImageWidth(double value) {
    if (_imageWidth != value) {
      _imageWidth = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  double? _imageHeight;
  double getImageHeight() {
    if (getImage().isEmpty) {
      return 0;
    }
    return _imageHeight != null
        ? _imageHeight!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(
                        getLevel(),
                      )!["ImageHeight"] !=
                      null
              ? double.tryParse(
                      getMindMap()!
                          .getTheme()!
                          .getThemeByLevel(getLevel())!["ImageHeight"]!
                          .toString(),
                    ) ??
                    0
              : 16);
  }

  void setImageHeight(double value) {
    if (_imageHeight != value) {
      _imageHeight = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  double? _imageSpace;
  double getImageSpace() {
    if (getImage().isEmpty) {
      return 0;
    }
    return _imageSpace != null
        ? _imageSpace!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(
                        getLevel(),
                      )!["ImageSpace"] !=
                      null
              ? double.tryParse(
                      getMindMap()!
                          .getTheme()!
                          .getThemeByLevel(getLevel())!["ImageSpace"]!
                          .toString(),
                    ) ??
                    0
              : 0);
  }

  void setImageSpace(double value) {
    if (_imageSpace != value) {
      _imageSpace = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  String _oldImage2Base64 = "";
  Uint8List? image2;

  String _image2 = "";
  String getImage2() {
    if (_image2.isEmpty) {
      return (getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(
                    getLevel(),
                  )!["Image2"] !=
                  null
          ? getMindMap()!
                .getTheme()!
                .getThemeByLevel(getLevel())!["Image2"]!
                .toString()
          : "");
    } else {
      return _image2;
    }
  }

  void setImage2(String value) {
    if (_image2 != value) {
      _oldImage2Base64 = "";
      image2 = null;
      _image2 = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  double? _image2Width;
  double getImage2Width() {
    if (getImage2().isEmpty) {
      return 0;
    }
    return _image2Width != null
        ? _image2Width!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(
                        getLevel(),
                      )!["Image2Width"] !=
                      null
              ? double.tryParse(
                      getMindMap()!
                          .getTheme()!
                          .getThemeByLevel(getLevel())!["Image2Width"]!
                          .toString(),
                    ) ??
                    0
              : 16);
  }

  void setImage2Width(double value) {
    if (_image2Width != value) {
      _image2Width = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  double? _image2Height;
  double getImage2Height() {
    if (getImage2().isEmpty) {
      return 0;
    }
    return _image2Height != null
        ? _image2Height!
        : (getMindMap()?.getTheme() != null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) !=
                      null &&
                  getMindMap()?.getTheme()?.getThemeByLevel(
                        getLevel(),
                      )!["Image2Height"] !=
                      null
              ? double.tryParse(
                      getMindMap()!
                          .getTheme()!
                          .getThemeByLevel(getLevel())!["Image2Height"]!
                          .toString(),
                    ) ??
                    0
              : 16);
  }

  void setImage2Height(double value) {
    if (_image2Height != value) {
      _image2Height = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  String _extended = "";

  /// Extended
  @override
  String getExtended() {
    return _extended;
  }

  /// set extended
  @override
  void setExtended(String value) {
    _extended = value;
  }

  Widget? _child;

  /// Child
  Widget? getChild() {
    return _child;
  }

  /// set child
  void setChild(Widget? value) {
    _child = value;
  }

  Color? _backgroundColor;

  /// Background Color
  Color getBackgroundColor() {
    if (_backgroundColor != null) {
      return _backgroundColor!;
    }
    List<Color> list = getBackgroundColors();
    if (list.isNotEmpty) {
      int index = 0;
      List<IMindMapNode> list1 = [];
      if (getParentNode() != null) {
        if (getParentNode()!.getNodeType() == NodeType.root) {
          list1.addAll(getParentNode()!.getRightItems());
          for (int i = 0; i < getParentNode()!.getLeftItems().length; i++) {
            IMindMapNode node = getParentNode()!
                .getLeftItems()[getParentNode()!.getLeftItems().length - i - 1];
            list1.add(node);
          }
        } else {
          list1.addAll(getParentNode()!.getRightItems());
          list1.addAll(getParentNode()!.getLeftItems());
        }
        index = list1.indexOf(this);
      }
      return list[index % list.length];
    }
    return getMindMap()?.getTheme() != null &&
            getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
            getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["BackgroundColor"]
                is Color
        ? getMindMap()?.getTheme()?.getThemeByLevel(
                getLevel(),
              )!["BackgroundColor"]
              as Color
        : (getParentNode() != null && getParentNode() is MindMapNode
              ? (getParentNode() as MindMapNode).getBackgroundColor()
              : (getMindMap() != null
                    ? getMindMap()!.getBackgroundColor()
                    : Colors.transparent));
  }

  /// set background color
  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  List<Color> _backgroundColors = [];

  /// Background Colors
  List<Color> getBackgroundColors() {
    if (_backgroundColors.isNotEmpty) {
      return _backgroundColors;
    } else {
      if (getMindMap()?.getTheme() != null &&
          getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
          getMindMap()?.getTheme()?.getThemeByLevel(
                getLevel(),
              )!["BackgroundColors"]
              is List) {
        List<Color> list = [];
        for (dynamic v
            in getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["BackgroundColors"]
                as List) {
          if (v is Color) {
            list.add(v);
          }
        }
        if (list.isNotEmpty) {
          return list;
        }
      }
    }
    return [];
  }

  /// set background colors
  void setBackgroundColors(List<Color> value) {
    _backgroundColors = value;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  BoxBorder? _border;

  /// Border
  BoxBorder getBorder() {
    if (_border != null) {
      return _border!;
    } else {
      BoxBorder border =
          getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Border"]
                  is BoxBorder
          ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Border"]
                as BoxBorder
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getBorder()
                : Border.all(
                    color: Colors.black,
                    width: 1.0,
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ));

      List<Color> list = getBorderColors();
      if (list.isNotEmpty) {
        int index = 0;
        if (getParentNode() != null) {
          List<IMindMapNode> list1 = [];
          if (getParentNode()!.getNodeType() == NodeType.root) {
            list1.addAll(getParentNode()!.getRightItems());
            for (int i = 0; i < getParentNode()!.getLeftItems().length; i++) {
              IMindMapNode node =
                  getParentNode()!.getLeftItems()[getParentNode()!
                          .getLeftItems()
                          .length -
                      i -
                      1];
              list1.add(node);
            }
          } else {
            list1.addAll(getRightItems());
            list1.addAll(getParentNode()!.getLeftItems());
          }
          index = list1.indexOf(this);
        }
        Color color = list[index % list.length];
        BorderSide top = BorderSide.none;
        BorderSide left = BorderSide.none;
        BorderSide bottom = BorderSide.none;
        BorderSide right = BorderSide.none;

        if (border.top != BorderSide.none) {
          top = border.top.copyWith(color: color);
        }
        if (border.bottom != BorderSide.none) {
          bottom = border.bottom.copyWith(color: color);
        }
        if (border is Border && border.left != BorderSide.none) {
          left = border.left.copyWith(color: color);
        }
        if (border is Border && border.right != BorderSide.none) {
          right = border.right.copyWith(color: color);
        }
        border = BoxBorder.fromLTRB(
          top: top,
          right: right,
          left: left,
          bottom: bottom,
        );
      }

      return border;
    }
  }

  /// set border
  void setBorder(BoxBorder border) {
    _border = border;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  BorderRadiusGeometry? _borderRadius;

  /// Border Radius
  BorderRadiusGeometry getBorderRadius() {
    if (_borderRadius != null) {
      return _borderRadius!;
    } else {
      return getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(
                    getLevel(),
                  )!["BorderRadius"]
                  is BorderRadiusGeometry
          ? getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["BorderRadius"]
                as BorderRadiusGeometry
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getBorderRadius()
                : BorderRadius.circular(5.0));
    }
  }

  /// set border radius
  void setBorderRadius(BorderRadiusGeometry borderRadius) {
    _borderRadius = borderRadius;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  List<BoxShadow>? _shadow;

  /// Shadow
  List<BoxShadow>? getShadow() {
    return _shadow;
  }

  /// set shadow
  void setShadow(List<BoxShadow>? shadow) {
    _shadow = shadow;
    refresh();
  }

  Gradient? _gradient;

  /// Gradient
  Gradient? getGradient() {
    return _gradient;
  }

  /// set gradient
  void setGradient(Gradient? gradient) {
    _gradient = gradient;
    refresh();
  }

  EdgeInsets? _padding;

  /// Padding
  EdgeInsets? getPadding() {
    if (_padding != null) {
      return _padding!;
    } else {
      return getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Padding"]
                  is EdgeInsets
          ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Padding"]
                as EdgeInsets
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getPadding()
                : EdgeInsets.fromLTRB(20, 6, 20, 6));
    }
  }

  /// set padding
  void setPadding(EdgeInsets? padding) {
    _padding = padding;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  TextStyle? _textStyle;

  /// Text Style
  TextStyle? getTextStyle() {
    TextStyle? result;
    if (_textStyle != null) {
      result = _textStyle;
    } else {
      double? fontSize =
          getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["FontSize"]
                  is double
          ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["FontSize"]
                as double
          : null;
      Color? textColor =
          getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(
                    getLevel(),
                  )!["TextColor"]
                  is Color
          ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["TextColor"]
                as Color
          : null;
      bool? bold =
          getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Bold"]
                  is bool
          ? getMindMap()?.getTheme()?.getThemeByLevel(getLevel())!["Bold"]
                as bool
          : null;
      result = textColor != null || fontSize != null || bold != null
          ? TextStyle(
              color: textColor ?? Colors.black,
              fontSize: fontSize ?? 16,
              fontWeight: bold == true ? FontWeight.bold : FontWeight.normal,
            )
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getTextStyle()
                : TextStyle(fontSize: 16.0, color: Colors.black));
    }
    if (result != null) {
      if ((getMindMap()?.getReadOnly() ?? false) &&
          (getMindMap()?.getEnabledExtendedClick() ?? false) &&
          getExtended().isNotEmpty) {
        result = result.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.solid,
        );
      }
    }
    return result;
  }

  /// set text style
  void setTextStyle(TextStyle? textStyle) {
    _textStyle = textStyle;
    refresh();
    if (!_isLoading) {
      getMindMap()?.onChanged();
    }
  }

  List<IMindMapNode> _leftItems = [];
  List<IMindMapNode> _rightItems = [];

  ///Add Left Item
  @override
  void addLeftItem(IMindMapNode item) {
    _leftItems.add(item);
    item.setParentNode(this);
    item.setNodeType(NodeType.left);
    refresh();
    getMindMap()?.refresh();
  }

  ///Add Right Item
  @override
  void addRightItem(IMindMapNode item) {
    _rightItems.add(item);
    item.setParentNode(this);
    item.setNodeType(NodeType.right);
    refresh();
    getMindMap()?.refresh();
  }

  ///Get Left Items
  @override
  List<IMindMapNode> getLeftItems() {
    return _leftItems;
  }

  ///Get Right Items
  @override
  List<IMindMapNode> getRightItems() {
    return _rightItems;
  }

  ///Insert Left Item
  @override
  void insertLeftItem(IMindMapNode item, int index) {
    if (index >= _leftItems.length) {
      _leftItems.add(item);
    } else {
      _leftItems.insert(index < 0 ? 0 : index, item);
    }
    item.setParentNode(this);
    item.setNodeType(NodeType.left);
    refresh();
  }

  ///Insert Right Item
  @override
  void insertRightItem(IMindMapNode item, int index) {
    if (index >= _rightItems.length) {
      _rightItems.add(item);
    } else {
      _rightItems.insert(index < 0 ? 0 : index, item);
    }
    item.setParentNode(this);
    item.setNodeType(NodeType.right);
    refresh();
  }

  ///Remove Left Item
  @override
  void removeLeftItem(IMindMapNode item) {
    _leftItems.remove(item);
    refresh();
  }

  ///Remove Right Item
  @override
  void removeRightItem(IMindMapNode item) {
    _rightItems.remove(item);
    refresh();
  }

  ///Set Left Items
  @override
  void setLeftItems(List<IMindMapNode> value) {
    _leftItems = value;
    refresh();
  }

  ///Set Right Items
  @override
  void setRightItems(List<IMindMapNode> value) {
    _rightItems = value;
    refresh();
  }

  NodeType _nodeType = NodeType.root;

  /// Get Node Type
  @override
  NodeType getNodeType() {
    return _nodeType;
  }

  /// Set Node Type
  @override
  void setNodeType(NodeType value) {
    _nodeType = value;
    if (value == NodeType.left) {
      _leftItems.addAll(_rightItems);
      _rightItems.clear();
      for (IMindMapNode n in _leftItems) {
        n.setNodeType(value);
      }
    }
    if (value == NodeType.right) {
      _rightItems.addAll(_leftItems);
      _leftItems.clear();
      for (IMindMapNode n in _rightItems) {
        n.setNodeType(value);
      }
    }
  }

  MindMap? _mindMap;

  /// Get Mind Map
  @override
  MindMap? getMindMap() {
    if (_mindMap != null) {
      return _mindMap!;
    } else {
      return getParentNode()?.getMindMap();
    }
  }

  /// Set Mind Map
  @override
  void setMindMap(MindMap value) {
    _mindMap = value;
  }

  /// Get Read Only
  @override
  bool getReadOnly() {
    if (getParentNode() != null) {
      return getParentNode()!.getReadOnly();
    }
    return getMindMap() != null ? getMindMap()!.getReadOnly() : true;
  }

  Offset _dragOffset = Offset.zero;

  /// Set Drag Offset
  void setDragOfset(Offset value) {
    _dragOffset = value;
  }

  /// Get Drag Offset
  @override
  Offset getDragOffset() {
    return _dragOffset;
  }

  Offset? _offset;

  /// Get Offset
  @override
  Offset? getOffset() {
    return _offset;
  }

  /// Set Offset
  @override
  void setOffset(Offset? value) {
    if (_offset == null ||
        (value != null &&
            _offset != null &&
            (_offset!.dx != value.dx || _offset!.dy != value.dy))) {
      _offset = value;
    }
    if (value == null) {
      for (IMindMapNode node in getLeftItems()) {
        node.setOffset(value);
      }
      for (IMindMapNode node in getRightItems()) {
        node.setOffset(value);
      }
      _state?.refresh();
    }
  }

  Offset? _offsetParent;

  /// Get Offset By Parent
  @override
  Offset? getOffsetByParent() {
    return _offsetParent;
  }

  /// Set Offset By Parent
  @override
  void setOffsetByParent(Offset? value) {
    if (_offsetParent == null ||
        (value != null &&
            _offsetParent != null &&
            (_offsetParent!.dx != value.dx || _offsetParent!.dy != value.dy))) {
      _offsetParent = value;
      if (getParentNode() != null) {
        getParentNode()!.refresh();
      }
    }
  }

  Size? _size;

  /// Get Size
  @override
  Size? getSize() {
    return _size;
  }

  /// Set Size
  @override
  void setSize(Size? value) {
    if (_size == null ||
        (_size != null &&
            value != null &&
            (_size!.width > value.width + 10 ||
                _size!.width < value.width - 10 ||
                _size!.height != value.height))) {
      _size = value;
      if (getParentNode() != null) {
        getParentNode()!.refresh();
      }
    }
  }

  @override
  double getFishboneHeight() {
    double h = 0;
    for (IMindMapNode node in getRightItems()) {
      h += (node.getSize()?.height ?? 0);
      h += node.getFishboneHeight();
    }
    for (int i = 0; i < getLeftItems().length; i++) {
      IMindMapNode node = getLeftItems()[getLeftItems().length - 1 - i];
      h += (node.getSize()?.height ?? 0);
      h += node.getFishboneHeight();
    }
    if (getNodeType() == NodeType.root) {
      h += getVSpace();
    } else {
      h += (getParentNode()?.getVSpace() ?? getVSpace());
    }

    return h;
  }

  double _fishboneWidth = 0;

  @override
  double getFishboneWidth() {
    if (getRightItems().isEmpty && getLeftItems().isEmpty) {
      return _fishboneWidth == 0
          ? (getSize()?.width ?? 200) +
                (getParentNode()?.getHSpace() ?? 0) +
                (getSize()?.height ?? 200)
          : _fishboneWidth;
    } else {
      double w = _fishboneWidth;
      for (IMindMapNode node in getRightItems()) {
        double w1 = node.getFishboneWidth();
        if (w1 > w) {
          w = w1;
        }
      }
      for (IMindMapNode node in getLeftItems()) {
        double w1 = node.getFishboneWidth();
        if (w1 > w) {
          w = w1;
        }
      }
      if (getParentNode()?.getNodeType() == NodeType.root) {
        if (w < (getSize()?.width ?? 0) / 2) {
          w = (getSize()?.width ?? 0) / 2;
        }
      }
      return w;
    }
  }

  @override
  void setFishboneWidth(double value) {
    if (_fishboneWidth != value) {
      _fishboneWidth = value;
      if (getParentNode() != null) {
        getParentNode()!.refresh();
      }
    }
  }

  FishboneNodeMode _fishboneNodeMode = FishboneNodeMode.up;
  @override
  FishboneNodeMode getFishboneNodeMode() {
    return _fishboneNodeMode;
  }

  @override
  void setFishboneNodeMode(FishboneNodeMode value) {
    _fishboneNodeMode = value;
  }

  Offset _fishbonePosition = Offset.zero;
  @override
  Offset getFishbonePosition() {
    return _fishbonePosition;
  }

  @override
  void setFishbonePosition(Offset value) {
    if (getNodeType() != NodeType.root) {
      if (getRightItems().isEmpty && getLeftItems().isEmpty) {
        if (getParentNode()?.getNodeType() == NodeType.root) {
          setFishboneWidth((getSize()?.width ?? 0) / 2);
        } else {
          IMindMapNode? topNode = getFishboneTopNode();
          if (topNode != null) {
            if (getMindMap()?.getFishboneMapType() ==
                FishboneMapType.leftToRight) {
              if (topNode.getFishboneNodeMode() == FishboneNodeMode.up) {
                double h =
                    (getSize()?.height ?? 0) +
                    value.dy -
                    topNode.getFishbonePosition().dy -
                    (topNode.getSize()?.height ?? 0) / 2;
                double r = value.dx + (getSize()?.width ?? 0) + h;
                double w =
                    r -
                    topNode.getFishbonePosition().dx -
                    (topNode.getSize()?.width ?? 0) / 2;
                setFishboneWidth(w);
              } else {
                double h = topNode.getFishbonePosition().dy - value.dy;
                double r = value.dx + (getSize()?.width ?? 0) + h;
                double w =
                    r -
                    topNode.getFishbonePosition().dx -
                    (topNode.getSize()?.width ?? 0) / 2;
                setFishboneWidth(w);
              }
            } else {
              if (topNode.getFishboneNodeMode() == FishboneNodeMode.up) {
                double h =
                    (getSize()?.height ?? 0) +
                    value.dy -
                    topNode.getFishbonePosition().dy -
                    (topNode.getSize()?.height ?? 0) / 2;
                double r = value.dx - h;
                double w =
                    topNode.getFishbonePosition().dx +
                    (topNode.getSize()?.width ?? 0) / 2 -
                    r;
                setFishboneWidth(w);
              } else {
                double h = topNode.getFishbonePosition().dy - value.dy;
                double r = value.dx - h;
                double w =
                    topNode.getFishbonePosition().dx +
                    (topNode.getSize()?.width ?? 0) / 2 -
                    r;
                setFishboneWidth(w);
              }
            }
          }
        }
      }
    }
    _fishbonePosition = value;
  }

  IMindMapNode? getFishboneTopNode() {
    IMindMapNode? result;
    IMindMapNode? parentNode = getParentNode();
    while (parentNode != null) {
      if (parentNode.getParentNode()?.getNodeType() == NodeType.root) {
        result = parentNode;
        break;
      }
      parentNode = parentNode.getParentNode();
    }
    return result;
  }

  /// Get Left Area
  @override
  Rect? getLeftArea() {
    Offset o = Offset(_offset?.dx ?? 0, _offset?.dy ?? 0);
    if (getRenderObject() is RenderBox) {
      Offset po = (getRenderObject() as RenderBox).localToGlobal(
        Offset.zero,
        ancestor: getMindMap()?.getRenderObject(),
      );
      o = Offset(o.dx + po.dx, o.dy + po.dy);
    }

    Rect rect = Rect.fromLTRB(
      o.dx - getHSpace() * 2,
      o.dy - getVSpace(),
      o.dx,
      o.dy + (_size?.height ?? 0) + getVSpace(),
    );
    if (getLeftItems().isNotEmpty) {
      double l = rect.left;
      double t = rect.top;
      double b = rect.bottom;
      for (IMindMapNode n in getLeftItems()) {
        Offset o = n.getOffset() ?? Offset.zero;
        if (n.getRenderObject() is RenderBox) {
          Offset po = (n.getRenderObject() as RenderBox).localToGlobal(
            Offset.zero,
            ancestor: getMindMap()?.getRenderObject(),
          );
          if (o.dx + po.dx < l) {
            l = o.dx + po.dx;
          }
          if (o.dy + po.dy - getVSpace() < t) {
            t = o.dy + po.dy - getVSpace();
          }
          if (o.dy + po.dy + (n.getSize()?.height ?? 0) + getVSpace() > b) {
            b = o.dy + po.dy + (n.getSize()?.height ?? 0) + getVSpace();
          }
        }
      }
      rect = Rect.fromLTRB(l, t, rect.right, b);
    }
    return rect;
  }

  /// Get Right Area
  @override
  Rect? getRightArea() {
    Offset o = Offset(_offset?.dx ?? 0, _offset?.dy ?? 0);
    if (getRenderObject() is RenderBox) {
      Offset po = (getRenderObject() as RenderBox).localToGlobal(
        Offset.zero,
        ancestor: getMindMap()?.getRenderObject(),
      );
      o = Offset(o.dx + po.dx + (_size?.width ?? 0), o.dy + po.dy);
    }

    Rect rect = Rect.fromLTRB(
      o.dx,
      o.dy - getVSpace(),
      o.dx + getHSpace() * 2,
      o.dy + (_size?.height ?? 0) + getVSpace(),
    );
    if (getRightItems().isNotEmpty) {
      double r = rect.right;
      double t = rect.top;
      double b = rect.bottom;
      for (IMindMapNode n in getRightItems()) {
        Offset o = n.getOffset() ?? Offset.zero;
        if (n.getRenderObject() is RenderBox) {
          Offset po = (n.getRenderObject() as RenderBox).localToGlobal(
            Offset.zero,
            ancestor: getMindMap()?.getRenderObject(),
          );
          if (o.dx + po.dx + (n.getSize()?.width ?? 0) > r) {
            r = o.dx + po.dx + (n.getSize()?.width ?? 0);
          }
          if (o.dy + po.dy - getVSpace() < t) {
            t = o.dy + po.dy - getVSpace();
          }
          if (o.dy + po.dy + (n.getSize()?.height ?? 0) + getVSpace() > b) {
            b = o.dy + po.dy + (n.getSize()?.height ?? 0) + getVSpace();
          }
        }
      }
      rect = Rect.fromLTRB(rect.left, t, r, b);
    }
    return rect;
  }

  /// Get Node Area
  @override
  Rect? getNodeArea() {
    return null;
  }

  /// Get Link In Area
  @override
  RenderObject? getRenderObject() {
    if (_state != null) {
      return _state!.getRenderObject();
    }
    return null;
  }

  MindMapNodeLinkOffsetMode? _linkInOffsetMode;

  /// Set Link In Offset Mode
  MindMapNodeLinkOffsetMode getLinkInOffsetMode() {
    if (_linkInOffsetMode != null) {
      return _linkInOffsetMode!;
    } else {
      return getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(
                    getLevel(),
                  )!["LinkInOffsetMode"]
                  is MindMapNodeLinkOffsetMode
          ? getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["LinkInOffsetMode"]
                as MindMapNodeLinkOffsetMode
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getLinkInOffsetMode()
                : MindMapNodeLinkOffsetMode.center);
    }
  }

  /// Set Link In Offset Mode
  void setLinkInOffsetMode(MindMapNodeLinkOffsetMode value) {
    if (_linkInOffsetMode != value) {
      _linkInOffsetMode = value;
      if (getParentNode() != null) {
        getParentNode()!.refresh();
      }
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  /// Get Link In Offset
  @override
  double getLinkInOffset() {
    if (getLinkInOffsetMode() == MindMapNodeLinkOffsetMode.top) {
      return 0 -
          (getSize()?.height ?? 0) / 2 +
          ((getBorderRadius() as BorderRadius).topLeft.x >
                  (getSize()?.height ?? 0) / 2
              ? (getSize()?.height ?? 0) / 2
              : (getBorderRadius() as BorderRadius).topLeft.x) +
          getBorder().top.width / 2;
    }
    if (getLinkInOffsetMode() == MindMapNodeLinkOffsetMode.bottom) {
      return (getSize()?.height ?? 0) / 2 -
          ((getBorderRadius() as BorderRadius).bottomLeft.x >
                  (getSize()?.height ?? 0) / 2
              ? (getSize()?.height ?? 0) / 2
              : (getBorderRadius() as BorderRadius).bottomLeft.x) -
          getBorder().bottom.width / 2;
    }
    return 0;
  }

  MindMapNodeLinkOffsetMode? _linkOutOffsetMode;

  /// Set Link Out Offset Mode
  MindMapNodeLinkOffsetMode getLinkOutOffsetMode() {
    if (_linkOutOffsetMode != null) {
      return _linkOutOffsetMode!;
    } else {
      return getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(
                    getLevel(),
                  )!["LinkOutOffsetMode"]
                  is MindMapNodeLinkOffsetMode
          ? getMindMap()?.getTheme()?.getThemeByLevel(
                  getLevel(),
                )!["LinkOutOffsetMode"]
                as MindMapNodeLinkOffsetMode
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getLinkOutOffsetMode()
                : MindMapNodeLinkOffsetMode.center);
    }
  }

  /// Set Link Out Offset Mode
  void setLinkOutOffsetMode(MindMapNodeLinkOffsetMode value) {
    if (_linkOutOffsetMode != value) {
      _linkOutOffsetMode = value;
      if (getParentNode() != null) {
        getParentNode()!.refresh();
      }
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  /// Get Link Out Offset
  @override
  double getLinkOutOffset() {
    if (getLinkOutOffsetMode() == MindMapNodeLinkOffsetMode.top) {
      return 0 -
          (getSize()?.height ?? 0) / 2 +
          ((getBorderRadius() as BorderRadius).topRight.x >
                  (getSize()?.height ?? 0) / 2
              ? (getSize()?.height ?? 0) / 2
              : (getBorderRadius() as BorderRadius).topRight.x) +
          getBorder().top.width / 2;
    }
    if (getLinkOutOffsetMode() == MindMapNodeLinkOffsetMode.bottom) {
      return (getSize()?.height ?? 0) / 2 -
          ((getBorderRadius() as BorderRadius).bottomRight.x >
                  (getSize()?.height ?? 0) / 2
              ? (getSize()?.height ?? 0) / 2
              : (getBorderRadius() as BorderRadius).bottomRight.x) -
          getBorder().bottom.width / 2;
    }
    return 0;
  }

  double? _linkOutPadding;
  @override
  double getLinkOutPadding() {
    if (_linkOutPadding != null) {
      return _linkOutPadding!;
    } else {
      return getMindMap()?.getTheme() != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(getLevel()) != null &&
              getMindMap()?.getTheme()?.getThemeByLevel(
                    getLevel(),
                  )!["LinkOutPadding"] !=
                  null
          ? (double.tryParse(
                  getMindMap()
                          ?.getTheme()
                          ?.getThemeByLevel(getLevel())!["LinkOutPadding"]
                          .toString() ??
                      "0",
                ) ??
                0)
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getLinkOutPadding()
                : 0);
    }
  }

  void setLinkOutPadding(double value) {
    if (_linkOutPadding != value) {
      _linkOutPadding = value;
      refresh();
      getMindMap()?.refresh();
      if (!_isLoading) {
        getMindMap()?.onChanged();
      }
    }
  }

  final FocusNode _focusNode = FocusNode();

  bool _doubleTapForTextField = false;
}

class MindMapNodeState extends State<MindMapNode> {
  @override
  void initState() {
    super.initState();
    if (widget.getMindMap() != null) {
      widget.getMindMap()!.addOnSelectedNodeChangedListeners(
        onSelectedNodeChanged,
      );
    }
    widget._focusNode.addListener(() {
      if (!widget._focusNode.hasFocus) {
        widget._doubleTapForTextField = false;
      }
    });
  }

  @override
  void dispose() {
    if (widget.getMindMap() != null) {
      widget.getMindMap()!.removeOnSelectedNodeChangedListeners(
        onSelectedNodeChanged,
      );
    }

    super.dispose();
  }

  void onSelectedNodeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    widget._state = this;

    ///Set Map Size
    if (widget.getParentNode() == null &&
        (!widget.getSelected() || !widget._focusNode.hasFocus)) {
      WidgetsBinding.instance.addPostFrameCallback((c) {
        if (mounted && !widget.getSelected()) {
          RenderObject? ro = context.findRenderObject();
          if (ro != null && ro is RenderBox) {
            widget.getMindMap()?.setSize(ro.size);
          }
        }
      });
    }
    switch (widget.getMindMap()?.getMapType() ?? MapType.mind) {
      case MapType.mind:
        List<Widget> leftItems = [];
        if (widget.getNodeType() == NodeType.root ||
            widget.getNodeType() == NodeType.left) {
          for (IMindMapNode item in widget.getLeftItems()) {
            leftItems.add(item as Widget);
          }
        }
        List<Widget> rightItems = [];
        if (widget.getNodeType() == NodeType.root ||
            widget.getNodeType() == NodeType.right) {
          for (IMindMapNode item in widget.getRightItems()) {
            rightItems.add(item as Widget);
          }
        }
        return CustomPaint(
          painter: widget.getOffset() == null
              ? null
              : widget.getLink().getPainter(widget),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            ///spacing: widget.getHSpace().toDouble(),
            children: [
              ///Left Items
              ...(leftItems.isEmpty ||
                      (!widget.getExpanded() &&
                          (widget.getMindMap()?.getReadOnly() ?? false))
                  ? []
                  : [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        spacing: widget.getVSpace().toDouble(),
                        children: leftItems,
                      ),
                    ]),

              ///LeftSpace
              ...(widget.getNodeType() != NodeType.right
                  ? [
                      Container(
                        constraints: BoxConstraints(
                          minWidth: widget.getHSpace().toDouble(),
                          maxWidth: widget.getHSpace().toDouble(),
                          minHeight:
                              (widget.getMindMap()?.getButtonWidth() ?? 24)
                                  .toDouble(),
                        ),
                        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...(widget.getSelected()
                                ? (widget.getReadOnly()
                                      ? (widget.getNodeType() ==
                                                    NodeType.left &&
                                                widget.canExpand() &&
                                                widget
                                                    .getLeftItems()
                                                    .isNotEmpty &&
                                                (widget
                                                            .getMindMap()
                                                            ?.getExpandedLevel() ??
                                                        0) <=
                                                    widget.getLevel() + 1
                                            ? [
                                                ///Left Expand Button
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        (widget
                                                                .getMindMap()
                                                                ?.getButtonWidth() ??
                                                            24) +
                                                        widget
                                                                .getLinkOutOffset()
                                                                .abs() *
                                                            2,
                                                  ),
                                                  padding: EdgeInsets.fromLTRB(
                                                    0,
                                                    widget.getLinkOutOffset() >
                                                            0
                                                        ? widget.getLinkOutOffset() *
                                                              2
                                                        : 0,
                                                    0,
                                                    widget.getLinkOutOffset() <
                                                            0
                                                        ? widget
                                                                  .getLinkOutOffset()
                                                                  .abs() *
                                                              2
                                                        : 0,
                                                  ),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                      maxHeight:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          widget
                                                              .getMindMap()
                                                              ?.getButtonBackground() ??
                                                          Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                          ),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        widget
                                                            .getMindMap()
                                                            ?.setSelectedNode(
                                                              widget,
                                                            );
                                                        widget.setExpanded(
                                                          !widget.getExpanded(),
                                                        );
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(
                                                        widget.getExpanded()
                                                            ? Icons
                                                                  .remove_circle_outline
                                                            : Icons
                                                                  .add_circle_outline,
                                                        size:
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                        color:
                                                            widget
                                                                .getMindMap()
                                                                ?.getButtonColor() ??
                                                            Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            : [])
                                      : [
                                          ///left Add Button
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  (widget
                                                              .getMindMap()
                                                              ?.getButtonWidth() ??
                                                          24)
                                                      .toDouble(),
                                              maxHeight:
                                                  (widget
                                                              .getMindMap()
                                                              ?.getButtonWidth() ??
                                                          24)
                                                      .toDouble(),
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (widget
                                                      .getMindMap()
                                                      ?.getButtonBackground() ??
                                                  Colors.white),
                                              border: Border.all(
                                                color:
                                                    (widget
                                                        .getMindMap()
                                                        ?.getButtonColor() ??
                                                    Colors.black),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                (widget
                                                            .getMindMap()
                                                            ?.getButtonWidth() ??
                                                        24)
                                                    .toDouble(),
                                              ),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                widget._focusNode.unfocus();
                                                widget.addLeftChildNode();
                                              },
                                              padding: EdgeInsets.zero,
                                              hoverColor: Colors.green.shade200,
                                              highlightColor: Colors.green,
                                              icon: Icon(
                                                Icons.add_rounded,
                                                size:
                                                    (widget
                                                            .getMindMap()
                                                            ?.getButtonWidth() ??
                                                        24) -
                                                    6,
                                                color:
                                                    (widget
                                                        .getMindMap()
                                                        ?.getButtonColor() ??
                                                    Colors.black),
                                              ),
                                            ),
                                          ),

                                          ///Sapce
                                          widget.getNodeType() ==
                                                      NodeType.root ||
                                                  (widget
                                                          .getMindMap()
                                                          ?.getShowRecycle() ??
                                                      false)
                                              ? SizedBox(width: 0, height: 0)
                                              : SizedBox(width: 6),

                                          ///left Delete Button
                                          widget.getNodeType() ==
                                                      NodeType.root ||
                                                  (widget
                                                          .getMindMap()
                                                          ?.getShowRecycle() ??
                                                      false)
                                              ? SizedBox(width: 0, height: 0)
                                              : Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                    maxHeight:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (widget
                                                            .getMindMap()
                                                            ?.getButtonBackground() ??
                                                        Colors.white),
                                                    border: Border.all(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                        ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            content: Text(
                                                              widget
                                                                      .getMindMap()
                                                                      ?.getDeleteNodeString() ??
                                                                  "Delete this node?",
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  widget
                                                                          .getMindMap()
                                                                          ?.getCancelString() ??
                                                                      "Cancel",
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                  widget
                                                                          .getMindMap()
                                                                          ?.getOkString() ??
                                                                      "OK",
                                                                ),
                                                                onPressed: () {
                                                                  widget
                                                                      .getParentNode()
                                                                      ?.removeLeftItem(
                                                                        widget,
                                                                      );
                                                                  widget
                                                                      .getMindMap()
                                                                      ?.onChanged();
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    hoverColor:
                                                        Colors.red.shade200,
                                                    highlightColor: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.close_rounded,
                                                      size:
                                                          (widget
                                                                  .getMindMap()
                                                                  ?.getButtonWidth() ??
                                                              24) -
                                                          6,
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                    ),
                                                  ),
                                                ),

                                          ///Space
                                          !(widget
                                                          .getMindMap()
                                                          ?.hasTextField() ??
                                                      true) &&
                                                  (widget
                                                          .getMindMap()
                                                          ?.hasEditButton() ??
                                                      false)
                                              ? SizedBox(width: 6)
                                              : SizedBox(width: 0),

                                          ///Edit Button
                                          !(widget
                                                          .getMindMap()
                                                          ?.hasTextField() ??
                                                      true) &&
                                                  (widget
                                                          .getMindMap()
                                                          ?.hasEditButton() ??
                                                      false)
                                              ? Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                    maxHeight:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (widget
                                                            .getMindMap()
                                                            ?.getButtonBackground() ??
                                                        Colors.white),
                                                    border: Border.all(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                        ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      widget
                                                          .getMindMap()
                                                          ?.onEdit(widget);
                                                    },
                                                    hoverColor:
                                                        Colors.blue.shade200,
                                                    highlightColor: Colors.blue,
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      size:
                                                          (widget
                                                                  .getMindMap()
                                                                  ?.getButtonWidth() ??
                                                              24) -
                                                          8,
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(width: 0, height: 0),
                                        ])
                                : (widget.getReadOnly()
                                      ? (widget.getNodeType() ==
                                                    NodeType.left &&
                                                widget.canExpand() &&
                                                !widget.getExpanded() &&
                                                widget
                                                    .getLeftItems()
                                                    .isNotEmpty &&
                                                (widget
                                                            .getMindMap()
                                                            ?.getExpandedLevel() ??
                                                        0) <=
                                                    widget.getLevel() + 1
                                            ? [
                                                ///Left Expand Button
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        (widget
                                                                .getMindMap()
                                                                ?.getButtonWidth() ??
                                                            24) +
                                                        widget
                                                                .getLinkOutOffset()
                                                                .abs() *
                                                            2,
                                                  ),
                                                  padding: EdgeInsets.fromLTRB(
                                                    0,
                                                    widget.getLinkOutOffset() >
                                                            0
                                                        ? widget.getLinkOutOffset() *
                                                              2
                                                        : 0,
                                                    0,
                                                    widget.getLinkOutOffset() <
                                                            0
                                                        ? widget
                                                                  .getLinkOutOffset()
                                                                  .abs() *
                                                              2
                                                        : 0,
                                                  ),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                      maxHeight:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonBackground() ??
                                                          Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                          ),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        widget
                                                            .getMindMap()
                                                            ?.setSelectedNode(
                                                              widget,
                                                            );
                                                        widget.setExpanded(
                                                          !widget.getExpanded(),
                                                        );
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        size:
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                        color:
                                                            (widget
                                                                .getMindMap()
                                                                ?.getButtonColor() ??
                                                            Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            : [])
                                      : [])),
                          ],
                        ),
                      ),
                    ]
                  : []),

              ///Node
              MindMapNodeTitle(node: widget),

              ///RightSpace
              ...(widget.getNodeType() != NodeType.left
                  ? [
                      Container(
                        constraints: BoxConstraints(
                          minWidth: widget.getHSpace().toDouble(),
                          maxWidth: widget.getHSpace().toDouble(),
                          minHeight:
                              (widget.getMindMap()?.getButtonWidth() ?? 24)
                                  .toDouble(),
                        ),
                        padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...(widget.getSelected()
                                ? (widget.getReadOnly()
                                      ? (widget.getNodeType() ==
                                                    NodeType.right &&
                                                widget.canExpand() &&
                                                widget
                                                    .getRightItems()
                                                    .isNotEmpty &&
                                                (widget
                                                            .getMindMap()
                                                            ?.getExpandedLevel() ??
                                                        0) <=
                                                    widget.getLevel() + 1
                                            ? [
                                                ///Right Expand Button
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        (widget
                                                                .getMindMap()
                                                                ?.getButtonWidth() ??
                                                            24) +
                                                        widget
                                                                .getLinkOutOffset()
                                                                .abs() *
                                                            2,
                                                  ),
                                                  padding: EdgeInsets.fromLTRB(
                                                    0,
                                                    widget.getLinkOutOffset() >
                                                            0
                                                        ? widget.getLinkOutOffset() *
                                                              2
                                                        : 0,
                                                    0,
                                                    widget.getLinkOutOffset() <
                                                            0
                                                        ? widget
                                                                  .getLinkOutOffset()
                                                                  .abs() *
                                                              2
                                                        : 0,
                                                  ),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                      maxHeight:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonBackground() ??
                                                          Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                          ),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        widget
                                                            .getMindMap()
                                                            ?.setSelectedNode(
                                                              widget,
                                                            );
                                                        widget.setExpanded(
                                                          !widget.getExpanded(),
                                                        );
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(
                                                        widget.getExpanded()
                                                            ? Icons
                                                                  .remove_circle_outline
                                                            : Icons
                                                                  .add_circle_outline,
                                                        size:
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                        color:
                                                            (widget
                                                                .getMindMap()
                                                                ?.getButtonColor() ??
                                                            Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            : [])
                                      : [
                                          ///Edit Button
                                          !(widget
                                                          .getMindMap()
                                                          ?.hasTextField() ??
                                                      true) &&
                                                  (widget
                                                          .getMindMap()
                                                          ?.hasEditButton() ??
                                                      false)
                                              ? Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                    maxHeight:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (widget
                                                            .getMindMap()
                                                            ?.getButtonBackground() ??
                                                        Colors.white),
                                                    border: Border.all(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                        ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      widget
                                                          .getMindMap()
                                                          ?.onEdit(widget);
                                                    },
                                                    hoverColor:
                                                        Colors.blue.shade200,
                                                    highlightColor: Colors.blue,
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      size:
                                                          (widget
                                                                  .getMindMap()
                                                                  ?.getButtonWidth() ??
                                                              24) -
                                                          8,
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(width: 0, height: 0),

                                          ///Space
                                          !(widget
                                                          .getMindMap()
                                                          ?.hasTextField() ??
                                                      true) &&
                                                  (widget
                                                          .getMindMap()
                                                          ?.hasEditButton() ??
                                                      false)
                                              ? SizedBox(width: 6)
                                              : SizedBox(width: 0),

                                          ///Right Delete Button
                                          widget.getNodeType() ==
                                                      NodeType.root ||
                                                  (widget
                                                          .getMindMap()
                                                          ?.getShowRecycle() ??
                                                      false)
                                              ? SizedBox(width: 0, height: 0)
                                              : Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                    maxHeight:
                                                        (widget
                                                                    .getMindMap()
                                                                    ?.getButtonWidth() ??
                                                                24)
                                                            .toDouble(),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        (widget
                                                            .getMindMap()
                                                            ?.getButtonBackground() ??
                                                        Colors.white),
                                                    border: Border.all(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                        ),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            content: Text(
                                                              widget
                                                                      .getMindMap()
                                                                      ?.getDeleteNodeString() ??
                                                                  "Delete this node?",
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  widget
                                                                          .getMindMap()
                                                                          ?.getCancelString() ??
                                                                      "Cancel",
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                  widget
                                                                          .getMindMap()
                                                                          ?.getOkString() ??
                                                                      "OK",
                                                                ),
                                                                onPressed: () {
                                                                  widget
                                                                      .getParentNode()
                                                                      ?.removeRightItem(
                                                                        widget,
                                                                      );
                                                                  widget
                                                                      .getMindMap()
                                                                      ?.onChanged();
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    hoverColor:
                                                        Colors.red.shade200,
                                                    highlightColor: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.close_rounded,
                                                      size:
                                                          (widget
                                                                  .getMindMap()
                                                                  ?.getButtonWidth() ??
                                                              24) -
                                                          6,
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonColor() ??
                                                          Colors.black),
                                                    ),
                                                  ),
                                                ),

                                          ///Sapce
                                          widget.getNodeType() ==
                                                      NodeType.root ||
                                                  (widget
                                                          .getMindMap()
                                                          ?.getShowRecycle() ??
                                                      false)
                                              ? SizedBox(width: 0, height: 0)
                                              : SizedBox(width: 6),

                                          ///Right add Button
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  (widget
                                                              .getMindMap()
                                                              ?.getButtonWidth() ??
                                                          24)
                                                      .toDouble(),
                                              maxHeight:
                                                  (widget
                                                              .getMindMap()
                                                              ?.getButtonWidth() ??
                                                          24)
                                                      .toDouble(),
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (widget
                                                      .getMindMap()
                                                      ?.getButtonBackground() ??
                                                  Colors.white),
                                              border: Border.all(
                                                color:
                                                    (widget
                                                        .getMindMap()
                                                        ?.getButtonColor() ??
                                                    Colors.black),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                (widget
                                                            .getMindMap()
                                                            ?.getButtonWidth() ??
                                                        24)
                                                    .toDouble(),
                                              ),
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                widget._focusNode.unfocus();
                                                widget.addRightChildNode();
                                              },
                                              padding: EdgeInsets.zero,
                                              hoverColor: Colors.green.shade200,
                                              highlightColor: Colors.green,
                                              icon: Icon(
                                                Icons.add_rounded,
                                                size:
                                                    (widget
                                                            .getMindMap()
                                                            ?.getButtonWidth() ??
                                                        24) -
                                                    6,
                                                color:
                                                    (widget
                                                        .getMindMap()
                                                        ?.getButtonColor() ??
                                                    Colors.black),
                                              ),
                                            ),
                                          ),
                                        ])
                                : (widget.getReadOnly()
                                      ? (widget.getNodeType() ==
                                                    NodeType.right &&
                                                widget.canExpand() &&
                                                !widget.getExpanded() &&
                                                widget
                                                    .getRightItems()
                                                    .isNotEmpty &&
                                                (widget
                                                            .getMindMap()
                                                            ?.getExpandedLevel() ??
                                                        0) <=
                                                    widget.getLevel() + 1
                                            ? [
                                                ///Right Expand Button
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxHeight:
                                                        (widget
                                                                .getMindMap()
                                                                ?.getButtonWidth() ??
                                                            24) +
                                                        widget
                                                                .getLinkOutOffset()
                                                                .abs() *
                                                            2,
                                                  ),
                                                  padding: EdgeInsets.fromLTRB(
                                                    0,
                                                    widget.getLinkOutOffset() >
                                                            0
                                                        ? widget.getLinkOutOffset() *
                                                              2
                                                        : 0,
                                                    0,
                                                    widget.getLinkOutOffset() <
                                                            0
                                                        ? widget
                                                                  .getLinkOutOffset()
                                                                  .abs() *
                                                              2
                                                        : 0,
                                                  ),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                      maxHeight:
                                                          (widget
                                                                      .getMindMap()
                                                                      ?.getButtonWidth() ??
                                                                  24)
                                                              .toDouble(),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (widget
                                                              .getMindMap()
                                                              ?.getButtonBackground() ??
                                                          Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                          ),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        widget
                                                            .getMindMap()
                                                            ?.setSelectedNode(
                                                              widget,
                                                            );
                                                        widget.setExpanded(
                                                          !widget.getExpanded(),
                                                        );
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      icon: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        size:
                                                            (widget
                                                                        .getMindMap()
                                                                        ?.getButtonWidth() ??
                                                                    24)
                                                                .toDouble(),
                                                        color:
                                                            (widget
                                                                .getMindMap()
                                                                ?.getButtonColor() ??
                                                            Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            : [])
                                      : [])),
                          ],
                        ),
                      ),
                    ]
                  : []),

              ///Right Items
              ...(rightItems.isEmpty ||
                      (!widget.getExpanded() &&
                          (widget.getMindMap()?.getReadOnly() ?? false))
                  ? []
                  : [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: widget.getVSpace().toDouble(),
                        children: rightItems,
                      ),
                    ]),
            ],
          ),
        );
      case MapType.fishbone:
        if (widget.getNodeType() == NodeType.root) {
          double maxHeight = 0;

          double maxWidth = 0;
          if (widget.getLeftItems().isEmpty && widget.getRightItems().isEmpty) {
            maxWidth =
                maxWidth +
                (widget.getSize()?.width ?? 0) +
                widget.getHSpace() +
                (widget.getMindMap()?.getButtonWidth() ?? 0) +
                12 +
                widget.getImage2Width();
            maxHeight =
                (widget.getSize()?.height ?? 0) + widget.getVSpace() * 2;
          } else {
            if (widget.getMindMap()?.getFishboneMapType() ==
                FishboneMapType.leftToRight) {
              List<List<IMindMapNode>> items = [];
              List<IMindMapNode> c = [];
              for (var item in widget.getRightItems()) {
                if (maxHeight <
                    (item.getSize()?.height ?? 0) +
                        item.getFishboneHeight() +
                        widget.getVSpace().toDouble()) {
                  maxHeight =
                      (item.getSize()?.height ?? 0) +
                      item.getFishboneHeight() +
                      widget.getVSpace().toDouble();
                }
                c.add(item);
                if (c.length >= 2) {
                  items.add(c);
                  c = [];
                }
              }
              for (
                int index = 0;
                index < widget.getLeftItems().length;
                index++
              ) {
                var item = widget
                    .getLeftItems()[widget.getLeftItems().length - index - 1];
                if (maxHeight <
                    (item.getSize()?.height ?? 0) +
                        item.getFishboneHeight() +
                        widget.getVSpace().toDouble()) {
                  maxHeight =
                      (item.getSize()?.height ?? 0) +
                      item.getFishboneHeight() +
                      widget.getVSpace().toDouble();
                }
                c.add(item);
                if (c.length >= 2) {
                  items.add(c);
                  c = [];
                }
              }
              if (c.isNotEmpty) {
                items.add(c);
              }
              maxWidth += (widget.getSize()?.width ?? 0) + widget.getHSpace();
              for (List<IMindMapNode> item in items) {
                double d1 =
                    item[0].getFishboneWidth() +
                    (item[0].getSize()?.width ?? 0) / 2;
                double d2 = item.length <= 1
                    ? 0
                    : item[1].getFishboneWidth() +
                          (item[1].getSize()?.width ?? 0) / 2 +
                          widget.getHSpace();

                maxWidth += d1 < d2 ? d2 : d1;
                maxWidth += widget.getHSpace();
                if (item == items.last) {
                  double w1 =
                      item[0].getFishboneWidth() +
                      item[0].getFishbonePosition().dx +
                      (item[0].getSize()?.width ?? 0) / 2;
                  maxWidth = maxWidth < w1 ? w1 : maxWidth;
                }
                if (item.length > 1) {
                  double w1 =
                      item[1].getFishboneWidth() +
                      item[1].getFishbonePosition().dx +
                      (item[1].getSize()?.width ?? 0) / 2;
                  maxWidth = maxWidth < w1 ? w1 : maxWidth;
                }
              }
            } else {
              List<List<IMindMapNode>> items = [];
              List<IMindMapNode> c = [];
              for (var item in widget.getLeftItems()) {
                if (maxHeight <
                    (item.getSize()?.height ?? 0) +
                        item.getFishboneHeight() +
                        widget.getVSpace().toDouble()) {
                  maxHeight =
                      (item.getSize()?.height ?? 0) +
                      item.getFishboneHeight() +
                      widget.getVSpace().toDouble();
                }
                c.add(item);
                if (c.length >= 2) {
                  items.add(c);
                  c = [];
                }
              }
              for (
                int index = 0;
                index < widget.getRightItems().length;
                index++
              ) {
                var item = widget
                    .getRightItems()[widget.getRightItems().length - index - 1];
                if (maxHeight <
                    (item.getSize()?.height ?? 0) +
                        item.getFishboneHeight() +
                        widget.getVSpace().toDouble()) {
                  maxHeight =
                      (item.getSize()?.height ?? 0) +
                      item.getFishboneHeight() +
                      widget.getVSpace().toDouble();
                }
                c.add(item);
                if (c.length >= 2) {
                  items.add(c);
                  c = [];
                }
              }
              if (c.isNotEmpty) {
                items.add(c);
              }
              maxWidth += (widget.getSize()?.width ?? 0) + widget.getHSpace();
              for (List<IMindMapNode> item in items) {
                double d1 =
                    item[0].getFishboneWidth() +
                    (item[0].getSize()?.width ?? 0) / 2;
                double d2 = item.length <= 1
                    ? 0
                    : item[1].getFishboneWidth() +
                          (item[1].getSize()?.width ?? 0) / 2 +
                          widget.getHSpace();

                maxWidth += d1 < d2 ? d2 : d1;
                maxWidth += widget.getHSpace();
                if (item == items.last) {
                  double w1 =
                      (widget
                              .getMindMap()
                              ?.getRootNode()
                              .getFishbonePosition()
                              .dx ??
                          0) -
                      (item[0].getFishbonePosition().dx +
                          (item[0].getSize()?.width ?? 0) / 2 -
                          item[0].getFishboneWidth()) +
                      (widget.getMindMap()?.getRootNode().getSize()?.width ??
                          0);
                  maxWidth = maxWidth < w1 ? w1 : maxWidth;
                }
                if (item.length > 1) {
                  double w1 =
                      (widget
                              .getMindMap()
                              ?.getRootNode()
                              .getFishbonePosition()
                              .dx ??
                          0) -
                      (item[1].getFishbonePosition().dx +
                          (item[1].getSize()?.width ?? 0) / 2 -
                          item[1].getFishboneWidth()) +
                      (widget.getMindMap()?.getRootNode().getSize()?.width ??
                          0);
                  maxWidth = maxWidth < w1 ? w1 : maxWidth;
                }
              }
            }
          }
          List<Widget> list = [];

          widget.setFishbonePosition(
            Offset(
              widget.getMindMap()?.getFishboneMapType() ==
                      FishboneMapType.rightToLeft
                  ? maxWidth -
                        (widget.getSize()?.width ?? 0) -
                        (widget.getBorder() as Border).right.width
                  : (widget.getBorder() as Border).left.width,
              maxHeight -
                  (widget.getSize()?.height ?? 0) / 2 +
                  widget.getLinkWidth() / 2,
            ),
          );

          list.add(
            Positioned(
              left:
                  widget.getMindMap()?.getFishboneMapType() ==
                      FishboneMapType.rightToLeft
                  ? maxWidth -
                        (widget.getSize()?.width ?? 0) -
                        (widget.getBorder() as Border).right.width
                  : (widget.getBorder() as Border).left.width,
              top:
                  maxHeight -
                  (widget.getSize()?.height ?? 0) / 2 +
                  widget.getLinkWidth() / 2,
              child: MindMapNodeTitle(node: widget),
            ),
          );

          list.addAll(getFinshboneNodes(widget, maxWidth, maxHeight));

          if (widget.image2 != null) {
            list.add(
              Positioned(
                left:
                    widget.getMindMap()?.getFishboneMapType() ==
                        FishboneMapType.rightToLeft
                    ? 0
                    : maxWidth - widget.getImage2Width(),
                top:
                    maxHeight +
                    widget.getLinkWidth() / 2 -
                    widget.getImage2Height() / 2,
                child:
                    widget.getMindMap()?.getFishboneMapType() ==
                        FishboneMapType.leftToRight
                    ? Transform.flip(
                        flipX: true,
                        child: Image.memory(
                          widget.image2!,
                          width: widget.getImage2Width(),
                          height: widget.getImage2Height(),
                          fit: BoxFit.fill,
                        ),
                      )
                    : Image.memory(
                        widget.image2!,
                        width: widget.getImage2Width(),
                        height: widget.getImage2Height(),
                        fit: BoxFit.fill,
                      ),
              ),
            );
          }
          widget.getMindMap()?.setFishboneSize(Size(maxWidth, maxHeight * 2));
          if (widget.getMindMap()?.getSelectedNode() != null) {
            list.addAll(
              getSelectedNodesButtons(widget.getMindMap()!.getSelectedNode()!),
            );
          }
          return SizedBox(
            width: maxWidth,
            height: maxHeight * 2 + widget.getLinkWidth(),
            child: Stack(children: list),
          );
        } else {
          return MindMapNodeTitle(node: widget);
        }
    }
  }

  List<Widget> getFinshboneNodes(
    IMindMapNode node,
    double width,
    double height,
  ) {
    List<Widget> list = [];
    if (widget.getMindMap()?.getFishboneMapType() ==
        FishboneMapType.rightToLeft) {
      if (node.getNodeType() == NodeType.root) {
        List<IMindMapNode> items = [];
        for (var item in node.getLeftItems()) {
          items.add(item);
        }
        for (int i = 0; i < node.getRightItems().length; i++) {
          IMindMapNode item = node
              .getRightItems()[node.getRightItems().length - i - 1];
          items.add(item);
        }
        double w = 0;
        int ii = 0;
        for (IMindMapNode item in items) {
          if (ii == 0) {
            w = (item.getSize()?.width ?? 0) / 2;
          } else {
            w = w < (item.getSize()?.width ?? 0) / 2
                ? (item.getSize()?.width ?? 0) / 2
                : w;
          }
          ii++;
          if (ii > 1) {
            break;
          }
        }

        double right = width - (node.getSize()?.width ?? 0) - w;
        double dragX = right - node.getHSpace();
        double tw = 0;
        int index = 0;

        for (IMindMapNode item in items) {
          double w1 = (item.getSize()?.width ?? 0) / 2;
          double h = item.getFishboneHeight();
          if (index % 2 == 0) {
            item.setFishboneNodeMode(FishboneNodeMode.down);
            item.setFishbonePosition(
              Offset(
                right - h - w1,
                height +
                    h +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0) +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
              ),
            );
            list.add(
              Positioned(
                left: right - h - w1,
                top:
                    height +
                    h +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0) +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
                child: item as Widget,
              ),
            );
            //add drag
            if (item == items.first) {
              list.add(
                Positioned(
                  left: right,
                  top: height - node.getVSpace() / 2,
                  child: FishboneNodeDrag(
                    node: item,
                    isLast: true,
                    width: node.getFishbonePosition().dx - right,
                    height: node.getVSpace().toDouble() + node.getLinkWidth(),
                  ),
                ),
              );
            }
            list.add(
              Positioned(
                left: right - node.getHSpace(),
                top: height - node.getVSpace() / 2,
                child: FishboneNodeDrag(
                  node: item,
                  isLast: false,
                  width: node.getHSpace().toDouble(),
                  height: node.getVSpace().toDouble() + node.getLinkWidth(),
                ),
              ),
            );

            //add child
            List<IMindMapNode> children = [];
            children.addAll(item.getRightItems());
            children.addAll(item.getLeftItems());
            double ctop =
                height +
                item.getVSpace() +
                (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0);
            for (IMindMapNode child in children) {
              double cright =
                  right -
                  (ctop -
                      height -
                      (widget.getMindMap()?.getRootNode().getLinkWidth() ??
                          0)) -
                  (child.getSize()?.height ?? 0) -
                  child.getFishboneHeight() -
                  item.getHSpace();
              child.setFishbonePosition(
                Offset(cright - (child.getSize()?.width ?? 0), ctop),
              );
              list.add(
                Positioned(
                  left: cright - (child.getSize()?.width ?? 0),
                  top: ctop,
                  child: child as Widget,
                ),
              );
              //add drag
              list.add(
                Positioned(
                  left: cright - (child.getSize()?.width ?? 0),
                  top: ctop - item.getVSpace(),
                  child: FishboneNodeDrag(
                    node: child,
                    isLast: false,
                    width: child.getSize()?.width ?? 0,
                    height: item.getVSpace().toDouble(),
                  ),
                ),
              );
              if (child == children.last) {
                list.add(
                  Positioned(
                    left: cright - (child.getSize()?.width ?? 0),
                    top: ctop + (child.getSize()?.height ?? 0),
                    child: FishboneNodeDrag(
                      node: child,
                      isLast: true,
                      width: child.getSize()?.width ?? 0,
                      height: item.getVSpace().toDouble(),
                    ),
                  ),
                );
              }
              list.addAll(getFinshboneNodes(child, width, height));
              ctop =
                  ctop +
                  (child.getSize()?.height ?? 0) +
                  child.getFishboneHeight();
            }

            tw = item.getFishboneWidth() + (item.getSize()?.width ?? 0) / 2;
            right = right - node.getHSpace();

            //w = left + h + w1;
          } else {
            item.setFishboneNodeMode(FishboneNodeMode.up);
            item.setFishbonePosition(
              Offset(
                right - h - w1,
                height -
                    h -
                    (item.getSize()?.height ?? 0) -
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
              ),
            );
            list.add(
              Positioned(
                left: right - h - w1,
                top:
                    height -
                    h -
                    (item.getSize()?.height ?? 0) -
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
                child: item as Widget,
              ),
            );

            //add child
            List<IMindMapNode> children = [];
            children.addAll(item.getRightItems());
            children.addAll(item.getLeftItems());
            double ctop =
                height -
                h +
                item.getVSpace() -
                (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0);
            for (IMindMapNode child in children) {
              double cright = right - (height - ctop) - item.getHSpace();
              child.setFishbonePosition(
                Offset(cright - (child.getSize()?.width ?? 0), ctop),
              );
              list.add(
                Positioned(
                  left: cright - (child.getSize()?.width ?? 0),
                  top: ctop,
                  child: child as Widget,
                ),
              );
              //add drag
              list.add(
                Positioned(
                  left: cright - (child.getSize()?.width ?? 0),
                  top: ctop - item.getVSpace(),
                  child: FishboneNodeDrag(
                    node: child,
                    isLast: false,
                    width: child.getSize()?.width ?? 0,
                    height: item.getVSpace().toDouble(),
                  ),
                ),
              );
              if (child == children.last) {
                list.add(
                  Positioned(
                    left: cright - (child.getSize()?.width ?? 0),
                    top: ctop + (child.getSize()?.height ?? 0),
                    child: FishboneNodeDrag(
                      node: child,
                      isLast: true,
                      width: child.getSize()?.width ?? 0,
                      height: item.getVSpace().toDouble(),
                    ),
                  ),
                );
              }
              list.addAll(getFinshboneNodes(child, width, height));
              ctop =
                  ctop +
                  (child.getSize()?.height ?? 0) +
                  child.getFishboneHeight();
            }
            tw =
                tw <
                    item.getFishboneWidth() +
                        node.getHSpace() +
                        (item.getSize()?.width ?? 0) / 2
                ? item.getFishboneWidth() +
                      node.getHSpace() +
                      (item.getSize()?.width ?? 0) / 2
                : tw;
            right = right - tw;

            //add drag
            list.add(
              Positioned(
                left: right,
                top: height - node.getVSpace() / 2,
                child: FishboneNodeDrag(
                  node: item,
                  isLast: false,
                  width: dragX - right,
                  height: node.getVSpace().toDouble() + node.getLinkWidth(),
                ),
              ),
            );

            dragX = right - node.getHSpace();
          }
          index++;
          //list.addAll(getFinshboneNodes(item));
        }
      } else {
        double top =
            node.getFishbonePosition().dy +
            (node.getSize()?.height ?? 0) +
            node.getVSpace();
        double right =
            node.getFishbonePosition().dx +
            (node.getSize()?.width ?? 0) -
            node.getHSpace();
        List<IMindMapNode> items = [];
        items.addAll(node.getRightItems());
        items.addAll(node.getLeftItems());
        for (var item in items) {
          item.setFishbonePosition(
            Offset(right - (item.getSize()?.width ?? 0), top),
          );
          list.add(
            Positioned(
              left: right - (item.getSize()?.width ?? 0),
              top: top,
              child: item as Widget,
            ),
          );
          //add drag
          list.add(
            Positioned(
              left: right - (item.getSize()?.width ?? 0),
              top: top - item.getVSpace(),
              child: FishboneNodeDrag(
                node: item,
                isLast: false,
                width: item.getSize()?.width ?? 0,
                height: item.getVSpace().toDouble(),
              ),
            ),
          );
          if (item == items.last) {
            list.add(
              Positioned(
                left: right - (item.getSize()?.width ?? 0),
                top: top + (item.getSize()?.height ?? 0),
                child: FishboneNodeDrag(
                  node: item,
                  isLast: true,
                  width: item.getSize()?.width ?? 0,
                  height: item.getVSpace().toDouble(),
                ),
              ),
            );
          }
          list.addAll(getFinshboneNodes(item, width, height));
          top = top + (item.getSize()?.height ?? 0) + item.getFishboneHeight();
        }
      }
    } else {
      if (node.getNodeType() == NodeType.root) {
        List<IMindMapNode> items = [];
        for (var item in node.getRightItems()) {
          items.add(item);
        }
        for (int i = 0; i < node.getLeftItems().length; i++) {
          IMindMapNode item = node
              .getLeftItems()[node.getLeftItems().length - i - 1];
          items.add(item);
        }
        double w = 0;
        int ii = 0;
        for (IMindMapNode item in items) {
          if (ii == 0) {
            w = (item.getSize()?.width ?? 0) / 2;
          } else {
            w = w < (item.getSize()?.width ?? 0) / 2
                ? (item.getSize()?.width ?? 0) / 2
                : w;
          }
          ii++;
          if (ii > 1) {
            break;
          }
        }

        double left = (node.getSize()?.width ?? 0) + w;
        double dragX = (node.getSize()?.width ?? 0);
        double tw = 0;
        int index = 0;

        for (IMindMapNode item in items) {
          double w1 = (item.getSize()?.width ?? 0) / 2;
          double h = item.getFishboneHeight();
          if (index % 2 == 0) {
            item.setFishboneNodeMode(FishboneNodeMode.up);
            item.setFishbonePosition(
              Offset(
                left + h - w1,
                height -
                    h -
                    (item.getSize()?.height ?? 0) -
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
              ),
            );
            list.add(
              Positioned(
                left: left + h - w1,
                top:
                    height -
                    h -
                    (item.getSize()?.height ?? 0) -
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
                child: item as Widget,
              ),
            );

            //add drag
            list.add(
              Positioned(
                left: dragX,
                top: height - node.getVSpace() / 2,
                child: FishboneNodeDrag(
                  node: item,
                  isLast: false,
                  width: left - dragX,
                  height: node.getVSpace() + node.getLinkWidth(),
                ),
              ),
            );
            if (item == items.last) {
              list.add(
                Positioned(
                  left: left,
                  top: height - node.getVSpace() / 2,
                  child: FishboneNodeDrag(
                    node: item,
                    isLast: false,
                    width: width - dragX,
                    height: node.getVSpace() + node.getLinkWidth(),
                  ),
                ),
              );
            }
            dragX = left + node.getHSpace();
            //add child
            List<IMindMapNode> children = [];
            children.addAll(item.getRightItems());
            children.addAll(item.getLeftItems());
            double ctop =
                height -
                h +
                item.getVSpace() -
                (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0);
            for (IMindMapNode child in children) {
              double cleft = left + (height - ctop) + item.getHSpace();
              child.setFishbonePosition(Offset(cleft, ctop));
              list.add(
                Positioned(left: cleft, top: ctop, child: child as Widget),
              );

              //add drag
              list.add(
                Positioned(
                  left: cleft,
                  top: ctop - item.getVSpace(),
                  child: FishboneNodeDrag(
                    node: child,
                    isLast: false,
                    width: child.getSize()?.width ?? 0,
                    height: item.getVSpace().toDouble(),
                  ),
                ),
              );
              if (child == children.last) {
                list.add(
                  Positioned(
                    left: cleft,
                    top: ctop + (child.getSize()?.height ?? 0),
                    child: FishboneNodeDrag(
                      node: child,
                      isLast: true,
                      width: child.getSize()?.width ?? 0,
                      height: item.getVSpace().toDouble(),
                    ),
                  ),
                );
              }
              list.addAll(getFinshboneNodes(child, width, height));
              ctop =
                  ctop +
                  (child.getSize()?.height ?? 0) +
                  child.getFishboneHeight();
            }

            tw = item.getFishboneWidth() + (item.getSize()?.width ?? 0) / 2;
            left = left + node.getHSpace();

            //w = left + h + w1;
          } else {
            item.setFishboneNodeMode(FishboneNodeMode.down);
            item.setFishbonePosition(
              Offset(
                left + h - w1,
                height +
                    h +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0) +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
              ),
            );
            list.add(
              Positioned(
                left: left + h - w1,
                top:
                    height +
                    h +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0) +
                    (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0),
                child: item as Widget,
              ),
            );

            //add drag
            list.add(
              Positioned(
                left: left - node.getHSpace(),
                top: height - node.getVSpace() / 2,
                child: FishboneNodeDrag(
                  node: item,
                  isLast: false,
                  width: node.getHSpace().toDouble(),
                  height: node.getVSpace().toDouble() + node.getLinkWidth(),
                ),
              ),
            );
            if (item == items.last) {
              list.add(
                Positioned(
                  left: left,
                  top: height - node.getVSpace() / 2,
                  child: FishboneNodeDrag(
                    node: item,
                    isLast: false,
                    width: width - dragX - node.getHSpace(),
                    height: node.getVSpace() + node.getLinkWidth(),
                  ),
                ),
              );
            }
            //add child
            List<IMindMapNode> children = [];
            children.addAll(item.getRightItems());
            children.addAll(item.getLeftItems());
            double ctop =
                height +
                item.getVSpace() +
                (widget.getMindMap()?.getRootNode().getLinkWidth() ?? 0);
            for (IMindMapNode child in children) {
              double cleft =
                  left +
                  (ctop -
                      height -
                      (widget.getMindMap()?.getRootNode().getLinkWidth() ??
                          0)) +
                  (child.getSize()?.height ?? 0) +
                  child.getFishboneHeight() +
                  item.getHSpace();
              child.setFishbonePosition(Offset(cleft, ctop));
              list.add(
                Positioned(left: cleft, top: ctop, child: child as Widget),
              );
              list.addAll(getFinshboneNodes(child, width, height));

              //add drag
              list.add(
                Positioned(
                  left: cleft,
                  top: ctop - item.getVSpace(),
                  child: FishboneNodeDrag(
                    node: child,
                    isLast: false,
                    width: child.getSize()?.width ?? 0,
                    height: item.getVSpace().toDouble(),
                  ),
                ),
              );
              if (child == children.last) {
                list.add(
                  Positioned(
                    left: cleft,
                    top: ctop + (child.getSize()?.height ?? 0),
                    child: FishboneNodeDrag(
                      node: child,
                      isLast: true,
                      width: child.getSize()?.width ?? 0,
                      height: item.getVSpace().toDouble(),
                    ),
                  ),
                );
              }
              ctop =
                  ctop +
                  (child.getSize()?.height ?? 0) +
                  child.getFishboneHeight();
            }
            tw =
                tw <
                    item.getFishboneWidth() +
                        node.getHSpace() +
                        (item.getSize()?.width ?? 0) / 2
                ? item.getFishboneWidth() +
                      node.getHSpace() +
                      (item.getSize()?.width ?? 0) / 2
                : tw;
            left = left + tw;
          }
          index++;
          //list.addAll(getFinshboneNodes(item));
        }
      } else {
        double top =
            node.getFishbonePosition().dy +
            (node.getSize()?.height ?? 0) +
            node.getVSpace();
        double left = node.getFishbonePosition().dx + node.getHSpace();
        List<IMindMapNode> items = [];
        items.addAll(node.getRightItems());
        items.addAll(node.getLeftItems());
        for (var item in items) {
          item.setFishbonePosition(Offset(left, top));
          list.add(Positioned(left: left, top: top, child: item as Widget));
          list.addAll(getFinshboneNodes(item, width, height));

          //add drag
          list.add(
            Positioned(
              left: left,
              top: top - item.getVSpace(),
              child: FishboneNodeDrag(
                node: item,
                isLast: false,
                width: item.getSize()?.width ?? 0,
                height: item.getVSpace().toDouble(),
              ),
            ),
          );
          if (item == items.last) {
            list.add(
              Positioned(
                left: left,
                top: top + (item.getSize()?.height ?? 0),
                child: FishboneNodeDrag(
                  node: item,
                  isLast: true,
                  width: item.getSize()?.width ?? 0,
                  height: item.getVSpace().toDouble(),
                ),
              ),
            );
          }

          top = top + (item.getSize()?.height ?? 0) + item.getFishboneHeight();
        }
      }
    }
    return list;
  }

  List<Widget> getSelectedNodesButtons(IMindMapNode node) {
    List<Widget> list = [];
    if (widget.getMindMap()?.getFishboneMapType() ==
        FishboneMapType.rightToLeft) {
      if (node.getNodeType() == NodeType.root) {
        if (!(widget.getMindMap()?.getReadOnly() ?? false)) {
          list.add(
            Positioned(
              left:
                  node.getFishbonePosition().dx -
                  ((widget.getMindMap()?.getButtonWidth() ?? 24) + 12),
              top:
                  node.getFishbonePosition().dy +
                  (node.getSize()?.height ?? 0) / 2 -
                  ((widget.getMindMap()?.getButtonWidth() ?? 24) + 12) / 2,
              child: SizedBox(
                width: (widget.getMindMap()?.getButtonWidth() ?? 24) + 12,
                height: (widget.getMindMap()?.getButtonWidth() ?? 24) + 12,
                child: Center(
                  //add button
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: (widget.getMindMap()?.getButtonWidth() ?? 24)
                          .toDouble(),
                      maxHeight: (widget.getMindMap()?.getButtonWidth() ?? 24)
                          .toDouble(),
                    ),
                    decoration: BoxDecoration(
                      color:
                          (widget.getMindMap()?.getButtonBackground() ??
                          Colors.white),
                      border: Border.all(
                        color:
                            (widget.getMindMap()?.getButtonColor() ??
                            Colors.black),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        (widget.getMindMap()?.getButtonWidth() ?? 24)
                            .toDouble(),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        IMindMapNode newnode = MindMapNode()
                          ..setTitle("New Node");
                        if (node.getLeftItems().isEmpty) {
                          node.addRightItem(newnode);
                        } else {
                          node.insertLeftItem(newnode, 0);
                        }
                        widget.getMindMap()?.setSelectedNode(newnode);
                        node.refresh();
                      },
                      padding: EdgeInsets.zero,
                      hoverColor: Colors.green.shade200,
                      highlightColor: Colors.green,
                      icon: Icon(
                        Icons.add_rounded,
                        size: (widget.getMindMap()?.getButtonWidth() ?? 24) - 6,
                        color:
                            (widget.getMindMap()?.getButtonColor() ??
                            Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } else {
        if (!(widget.getMindMap()?.getReadOnly() ?? false)) {
          list.add(
            Positioned(
              left:
                  node.getFishbonePosition().dx -
                  ((widget.getMindMap()?.getButtonWidth() ?? 24) * 3 + 12 * 4),
              top:
                  node.getFishbonePosition().dy +
                  (node.getSize()?.height ?? 0) / 2 -
                  ((widget.getMindMap()?.getButtonWidth() ?? 24) + 12) / 2,
              child: SizedBox(
                width:
                    (widget.getMindMap()?.getButtonWidth() ?? 24) * 3 + 12 * 4,
                height: (widget.getMindMap()?.getButtonWidth() ?? 24) + 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///add Add Button
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: (widget.getMindMap()?.getButtonWidth() ?? 24)
                            .toDouble(),
                        maxHeight: (widget.getMindMap()?.getButtonWidth() ?? 24)
                            .toDouble(),
                      ),
                      decoration: BoxDecoration(
                        color:
                            (widget.getMindMap()?.getButtonBackground() ??
                            Colors.white),
                        border: Border.all(
                          color:
                              (widget.getMindMap()?.getButtonColor() ??
                              Colors.black),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          (widget.getMindMap()?.getButtonWidth() ?? 24)
                              .toDouble(),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          widget._focusNode.unfocus();
                          if (node.getNodeType() == NodeType.left) {
                            node.addLeftItem(
                              MindMapNode()..setTitle("New Node"),
                            );
                          } else {
                            node.addRightItem(
                              MindMapNode()..setTitle("New Node"),
                            );
                          }
                          widget.getMindMap()?.onChanged();
                        },
                        padding: EdgeInsets.zero,
                        hoverColor: Colors.green.shade200,
                        highlightColor: Colors.green,
                        icon: Icon(
                          Icons.add_rounded,
                          size:
                              (widget.getMindMap()?.getButtonWidth() ?? 24) - 6,
                          color:
                              (widget.getMindMap()?.getButtonColor() ??
                              Colors.black),
                        ),
                      ),
                    ),

                    ///Sapce
                    (widget.getMindMap()?.getShowRecycle() ?? false)
                        ? SizedBox(width: 0, height: 0)
                        : SizedBox(width: 6),

                    ///Delete Button
                    (widget.getMindMap()?.getShowRecycle() ?? false)
                        ? SizedBox(width: 0, height: 0)
                        : Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                              maxHeight:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.getMindMap()?.getButtonBackground() ??
                                  Colors.white),
                              border: Border.all(
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                (widget.getMindMap()?.getButtonWidth() ?? 24)
                                    .toDouble(),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                        widget
                                                .getMindMap()
                                                ?.getDeleteNodeString() ??
                                            "Delete this node?",
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            widget
                                                    .getMindMap()
                                                    ?.getCancelString() ??
                                                "Cancel",
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            widget
                                                    .getMindMap()
                                                    ?.getOkString() ??
                                                "OK",
                                          ),
                                          onPressed: () {
                                            node
                                                .getParentNode()
                                                ?.removeLeftItem(node);

                                            node
                                                .getParentNode()
                                                ?.removeRightItem(node);

                                            widget
                                                .getMindMap()
                                                ?.setSelectedNode(null);
                                            widget
                                                .getMindMap()
                                                ?.getRootNode()
                                                .refresh();
                                            widget.getMindMap()?.onChanged();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              hoverColor: Colors.red.shade200,
                              highlightColor: Colors.red,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.close_rounded,
                                size:
                                    (widget.getMindMap()?.getButtonWidth() ??
                                        24) -
                                    6,
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                              ),
                            ),
                          ),

                    ///Space
                    !(widget.getMindMap()?.hasTextField() ?? true) &&
                            (widget.getMindMap()?.hasEditButton() ?? false)
                        ? SizedBox(width: 6)
                        : SizedBox(width: 0),

                    ///Edit Button
                    !(widget.getMindMap()?.hasTextField() ?? true) &&
                            (widget.getMindMap()?.hasEditButton() ?? false)
                        ? Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                              maxHeight:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.getMindMap()?.getButtonBackground() ??
                                  Colors.white),
                              border: Border.all(
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                (widget.getMindMap()?.getButtonWidth() ?? 24)
                                    .toDouble(),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                widget.getMindMap()?.onEdit(node);
                              },
                              hoverColor: Colors.blue.shade200,
                              highlightColor: Colors.blue,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit_outlined,
                                size:
                                    (widget.getMindMap()?.getButtonWidth() ??
                                        24) -
                                    8,
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                              ),
                            ),
                          )
                        : SizedBox(width: 0, height: 0),

                    ///Sapce
                    SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } else {
      if (node.getNodeType() == NodeType.root) {
        if (!(widget.getMindMap()?.getReadOnly() ?? false)) {
          list.add(
            Positioned(
              left:
                  node.getFishbonePosition().dx + (node.getSize()?.width ?? 0),
              top:
                  node.getFishbonePosition().dy +
                  (node.getSize()?.height ?? 0) / 2 -
                  ((widget.getMindMap()?.getButtonWidth() ?? 24) + 12) / 2,
              child: SizedBox(
                width: (widget.getMindMap()?.getButtonWidth() ?? 24) + 12,
                height: (widget.getMindMap()?.getButtonWidth() ?? 24) + 12,
                child: Center(
                  //Add button
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: (widget.getMindMap()?.getButtonWidth() ?? 24)
                          .toDouble(),
                      maxHeight: (widget.getMindMap()?.getButtonWidth() ?? 24)
                          .toDouble(),
                    ),
                    decoration: BoxDecoration(
                      color:
                          (widget.getMindMap()?.getButtonBackground() ??
                          Colors.white),
                      border: Border.all(
                        color:
                            (widget.getMindMap()?.getButtonColor() ??
                            Colors.black),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        (widget.getMindMap()?.getButtonWidth() ?? 24)
                            .toDouble(),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        IMindMapNode newnode = MindMapNode()
                          ..setTitle("New Node");
                        if (node.getLeftItems().isEmpty) {
                          node.addRightItem(newnode);
                        } else {
                          node.insertLeftItem(newnode, 0);
                        }
                        widget.getMindMap()?.setSelectedNode(newnode);
                        node.refresh();
                      },
                      padding: EdgeInsets.zero,
                      hoverColor: Colors.green.shade200,
                      highlightColor: Colors.green,
                      icon: Icon(
                        Icons.add_rounded,
                        size: (widget.getMindMap()?.getButtonWidth() ?? 24) - 6,
                        color:
                            (widget.getMindMap()?.getButtonColor() ??
                            Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } else {
        if (!(widget.getMindMap()?.getReadOnly() ?? false)) {
          list.add(
            Positioned(
              left:
                  node.getFishbonePosition().dx + (node.getSize()?.width ?? 0),
              top:
                  node.getFishbonePosition().dy +
                  (node.getSize()?.height ?? 0) / 2 -
                  ((widget.getMindMap()?.getButtonWidth() ?? 24) + 12) / 2,
              child: SizedBox(
                width:
                    (widget.getMindMap()?.getButtonWidth() ?? 24) * 3 + 12 * 4,
                height: (widget.getMindMap()?.getButtonWidth() ?? 24) + 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///Sapce
                    SizedBox(width: 6),

                    ///Edit Button
                    !(widget.getMindMap()?.hasTextField() ?? true) &&
                            (widget.getMindMap()?.hasEditButton() ?? false)
                        ? Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                              maxHeight:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.getMindMap()?.getButtonBackground() ??
                                  Colors.white),
                              border: Border.all(
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                (widget.getMindMap()?.getButtonWidth() ?? 24)
                                    .toDouble(),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                widget.getMindMap()?.onEdit(node);
                              },
                              hoverColor: Colors.blue.shade200,
                              highlightColor: Colors.blue,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit_outlined,
                                size:
                                    (widget.getMindMap()?.getButtonWidth() ??
                                        24) -
                                    8,
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                              ),
                            ),
                          )
                        : SizedBox(width: 0, height: 0),

                    ///Space
                    !(widget.getMindMap()?.hasTextField() ?? true) &&
                            (widget.getMindMap()?.hasEditButton() ?? false)
                        ? SizedBox(width: 6)
                        : SizedBox(width: 0),

                    ///Delete Button
                    (widget.getMindMap()?.getShowRecycle() ?? false)
                        ? SizedBox(width: 0, height: 0)
                        : Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                              maxHeight:
                                  (widget.getMindMap()?.getButtonWidth() ?? 24)
                                      .toDouble(),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (widget.getMindMap()?.getButtonBackground() ??
                                  Colors.white),
                              border: Border.all(
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                (widget.getMindMap()?.getButtonWidth() ?? 24)
                                    .toDouble(),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                        widget
                                                .getMindMap()
                                                ?.getDeleteNodeString() ??
                                            "Delete this node?",
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            widget
                                                    .getMindMap()
                                                    ?.getCancelString() ??
                                                "Cancel",
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            widget
                                                    .getMindMap()
                                                    ?.getOkString() ??
                                                "OK",
                                          ),
                                          onPressed: () {
                                            node
                                                .getParentNode()
                                                ?.removeLeftItem(node);

                                            node
                                                .getParentNode()
                                                ?.removeRightItem(node);

                                            widget
                                                .getMindMap()
                                                ?.setSelectedNode(null);
                                            widget
                                                .getMindMap()
                                                ?.getRootNode()
                                                .refresh();
                                            widget.getMindMap()?.onChanged();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              hoverColor: Colors.red.shade200,
                              highlightColor: Colors.red,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.close_rounded,
                                size:
                                    (widget.getMindMap()?.getButtonWidth() ??
                                        24) -
                                    6,
                                color:
                                    (widget.getMindMap()?.getButtonColor() ??
                                    Colors.black),
                              ),
                            ),
                          ),

                    ///Sapce
                    (widget.getMindMap()?.getShowRecycle() ?? false)
                        ? SizedBox(width: 0, height: 0)
                        : SizedBox(width: 6),

                    ///add Add Button
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: (widget.getMindMap()?.getButtonWidth() ?? 24)
                            .toDouble(),
                        maxHeight: (widget.getMindMap()?.getButtonWidth() ?? 24)
                            .toDouble(),
                      ),
                      decoration: BoxDecoration(
                        color:
                            (widget.getMindMap()?.getButtonBackground() ??
                            Colors.white),
                        border: Border.all(
                          color:
                              (widget.getMindMap()?.getButtonColor() ??
                              Colors.black),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          (widget.getMindMap()?.getButtonWidth() ?? 24)
                              .toDouble(),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          widget._focusNode.unfocus();
                          if (node.getNodeType() == NodeType.left) {
                            node.addLeftItem(
                              MindMapNode()..setTitle("New Node"),
                            );
                          } else {
                            node.addRightItem(
                              MindMapNode()..setTitle("New Node"),
                            );
                          }
                          widget.getMindMap()?.onChanged();
                        },
                        padding: EdgeInsets.zero,
                        hoverColor: Colors.green.shade200,
                        highlightColor: Colors.green,
                        icon: Icon(
                          Icons.add_rounded,
                          size:
                              (widget.getMindMap()?.getButtonWidth() ?? 24) - 6,
                          color:
                              (widget.getMindMap()?.getButtonColor() ??
                              Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }
    return list;
  }

  RenderObject? getRenderObject() {
    return context.findRenderObject();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}

// ignore: must_be_immutable
class FishboneNodeDrag extends StatefulWidget {
  FishboneNodeDrag({
    super.key,
    required this.node,
    this.isLast = false,
    this.width = 0,
    this.height = 0,
  });
  IMindMapNode node;
  bool isLast = false;
  double width = 0;
  double height = 0;
  @override
  State<StatefulWidget> createState() => FishboneNodeDragState();
}

class FishboneNodeDragState extends State<FishboneNodeDrag> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isDragging = false;

  bool isParent(IMindMapNode node, IMindMapNode dragNode) {
    IMindMapNode? parent = dragNode;
    while (parent != null) {
      if (parent == node) {
        return true;
      }
      parent = parent.getParentNode();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDragging
              ? widget.node.getMindMap()?.getDragInBorderColor()
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: DragTarget(
          onWillAcceptWithDetails: (details) {
            if (details.data is IMindMapNode) {
              if (details.data == widget.node) {
                return false;
              }
              if (isParent(details.data as IMindMapNode, widget.node)) {
                return false;
              }
              setState(() {
                isDragging = true;
              });
              return true;
            }
            return false;
          },
          onAcceptWithDetails: (details) {
            setState(() {
              isDragging = false;
            });
            if (details.data is IMindMapNode) {
              IMindMapNode dragNode = details.data as IMindMapNode;
              if (widget.node.getParentNode() != null) {
                IMindMapNode dragParent = dragNode.getParentNode()!;
                dragParent.removeLeftItem(dragNode);
                dragParent.removeRightItem(dragNode);

                IMindMapNode parent = widget.node.getParentNode()!;
                switch (parent.getNodeType()) {
                  case NodeType.left:
                    if (widget.isLast) {
                      parent.addLeftItem(dragNode);
                    } else {
                      int index = parent.getLeftItems().indexOf(widget.node);
                      parent.insertLeftItem(dragNode, index);
                    }
                    break;
                  case NodeType.right:
                    if (widget.isLast) {
                      parent.addRightItem(dragNode);
                    } else {
                      int index = parent.getRightItems().indexOf(widget.node);
                      parent.insertRightItem(dragNode, index);
                    }
                    break;
                  case NodeType.root:
                    if (widget.isLast) {
                      if (parent.getLeftItems().isEmpty) {
                        parent.addRightItem(dragNode);
                      } else {
                        parent.insertLeftItem(dragNode, 0);
                      }
                    } else {
                      if (parent.getRightItems().contains(widget.node)) {
                        int index = parent.getRightItems().indexOf(widget.node);
                        parent.insertRightItem(dragNode, index);
                      }
                      if (parent.getLeftItems().contains(widget.node)) {
                        int index = parent.getLeftItems().indexOf(widget.node);
                        if (parent.getLeftItems().length > index + 1) {
                          parent.insertLeftItem(dragNode, index + 1);
                        } else {
                          parent.addLeftItem(dragNode);
                        }
                      }
                    }
                    break;
                }
                widget.node.getMindMap()?.onChanged();
                widget.node.getMindMap()?.getRootNode().refresh();
              }
            }
          },
          onLeave: (data) {
            setState(() {
              isDragging = false;
            });
          },
          builder: (context1, candidateData, rejectedData) {
            return Container();
          },
        ),
      ),
    );
  }
}

/// Title
// ignore: must_be_immutable
class MindMapNodeTitle extends StatefulWidget {
  MindMapNodeTitle({super.key, required this.node});

  MindMapNode node;
  @override
  State<StatefulWidget> createState() => MindMapNodeTitleState();
}

class MindMapNodeTitleState extends State<MindMapNodeTitle> {
  @override
  void initState() {
    super.initState();
    widget.node.getMindMap()?.addOnZoomChangedListeners(onZoomChanged);
    widget.node.getMindMap()?.addOnChangedListeners(onChanged);
    _editingController.text = widget.node.getTitle();
  }

  final TextEditingController _editingController = TextEditingController();
  @override
  void dispose() {
    widget.node.getMindMap()?.removeOnChangedListeners(onChanged);
    widget.node.getMindMap()?.removeOnZoomChangedListeners(onZoomChanged);
    super.dispose();
  }

  void onChanged() {
    if (!widget.node.getSelected() || !widget.node._focusNode.hasFocus) {
      _editingController.text = widget.node.getTitle();
    }
  }

  void onZoomChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((c) {
      if (mounted &&
          (!widget.node.getSelected() || !widget.node._focusNode.hasFocus)) {
        RenderObject? ro = context.findRenderObject();
        if (ro != null && ro is RenderBox) {
          RenderObject? parent = ro.parent;
          if (parent != null) {
            widget.node.setOffset(
              ro.localToGlobal(Offset.zero, ancestor: parent),
            );
            if (widget.node.getParentNode() != null) {
              parent = widget.node.getParentNode()!.getRenderObject();
              if (parent != null) {
                widget.node.setOffsetByParent(
                  ro.localToGlobal(Offset.zero, ancestor: parent),
                );
              }
            }
          }
          widget.node.setSize(ro.size);
        }
      }
    });
    BoxBorder border = widget.node.getBorder();

    if (widget.node.getSelected()) {
      border = BoxBorder.fromLTRB(
        left: (border as Border).left.width > 0
            ? (border).left.copyWith(width: (border).left.width + 1)
            : BorderSide.none,
        top: border.top.width > 0
            ? border.top.copyWith(width: border.top.width + 1)
            : BorderSide.none,
        right: (border).right.width > 0
            ? (border).right.copyWith(width: (border).right.width + 1)
            : BorderSide.none,
        bottom: border.bottom.width > 0
            ? border.bottom.copyWith(width: border.bottom.width + 1)
            : BorderSide.none,
      );
    }
    return GestureDetector(
      onTapDown: (details) {
        widget.node._doubleTapForTextField = false;
        widget.node.setDragOfset(details.localPosition);
      },
      onTap: () {
        widget.node._doubleTapForTextField = false;
        widget.node.getMindMap()?.setSelectedNode(widget.node);
      },
      onLongPressDown: (details) {
        widget.node._doubleTapForTextField = false;
        widget.node.getMindMap()?.setSelectedNode(widget.node);
      },
      onDoubleTap: () {
        if (!(widget.node.getMindMap()?.getReadOnly() ?? false)) {
          widget.node.getMindMap()?.setSelectedNode(widget.node);
          widget.node.getMindMap()?.onDoubleTap(widget.node);
          if (widget.node.getMindMap()?.getEnabledDoubleTapShowTextField() ??
              false) {
            setState(() {
              widget.node._doubleTapForTextField = true;
            });
          }
        }
      },
      child:
          ((Platform.isAndroid || Platform.isIOS) &&
                  widget.node.getSelected() == false &&
                  !(widget.node.getMindMap()?.hasTextField() ?? false)) ||
              widget.node.getParentNode() == null ||
              widget.node.getMindMap()?.getReadOnly() == true ||
              (widget.node.getMindMap()?.getIsScaling() ?? false)
          ? MouseRegion(
              cursor:
                  (widget.node.getMindMap()?.getReadOnly() ?? false) &&
                      (widget.node.getMindMap()?.getEnabledExtendedClick() ??
                          false) &&
                      widget.node.getExtended().isNotEmpty
                  ? SystemMouseCursors.click
                  : MouseCursor.defer,
              child: getBody(border),
            )
          : Draggable(
              data: widget.node,
              feedback: Transform.scale(
                scale: widget.node.getMindMap()?.getZoom() ?? 1.0,
                child: Opacity(opacity: 0.88, child: getBody(border)),
              ),
              child:
                  widget.node.getNodeType() == NodeType.root ||
                      Platform.isMacOS ||
                      Platform.isLinux ||
                      Platform.isWindows ||
                      widget.node.getSelected() == false
                  ? getBody(border)
                  : Stack(
                      children: [
                        getBody(border),
                        Padding(
                          padding: EdgeInsets.all(
                            widget.node.getBorder().top.width + 1,
                          ),
                          child: Icon(
                            Icons.control_camera_sharp,
                            size: 14,
                            color: widget.node
                                .getMindMap()
                                ?.getDragInBorderColor(),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Future<void> loadImage() async {
    if (widget.node.getImage() != widget.node._oldImageBase64) {
      if (widget.node.getImage().isNotEmpty) {
        if (await Base64ImageValidator.isValidImage(
          widget.node.getImage(),
          checkHeader: true,
          tryDecode: true,
        )) {
          widget.node.image = Base64Decoder().convert(widget.node.getImage());
          widget.node._oldImageBase64 = widget.node.getImage();
        } else {
          widget.node.image = null;
        }
      } else {
        widget.node.image = null;
      }
    }
    if (widget.node.getImage2() != widget.node._oldImage2Base64) {
      if (widget.node.getImage2().isNotEmpty) {
        if (await Base64ImageValidator.isValidImage(
          widget.node.getImage2(),
          checkHeader: true,
          tryDecode: true,
        )) {
          widget.node.image2 = Base64Decoder().convert(widget.node.getImage2());
          widget.node._oldImage2Base64 = widget.node.getImage2();
        } else {
          widget.node.image2 = null;
        }
      } else {
        widget.node.image2 = null;
      }
    }
  }

  Widget getBody(BoxBorder border) {
    return FutureBuilder(
      future: loadImage(),
      builder: (context, snapshot) {
        return Container(
          padding: widget.node.getPadding(),
          decoration: BoxDecoration(
            color: widget.node.getBackgroundColor(),
            border: border,
            borderRadius: widget.node.getBorderRadius(),
            boxShadow: widget.node.getShadow(),
            gradient: widget.node.getGradient(),
          ),
          constraints: BoxConstraints(minWidth: 30),
          child:
              widget.node.getChild() ??
              (!(widget.node.getMindMap()?.getReadOnly() ?? true) &&
                      ((widget.node.getMindMap()?.hasTextField() ?? false) ||
                          widget.node._doubleTapForTextField) &&
                      widget.node.getSelected() &&
                      !(widget.node.getMindMap()?.getIsScaling() ?? false)
                  ? Container(
                      constraints: BoxConstraints(
                        maxWidth: widget.node.getSize() != null
                            ? ((widget.node.getSize()!.width -
                                          (widget.node.getPadding() == null
                                              ? 0
                                              : (widget.node
                                                        .getPadding()!
                                                        .left +
                                                    widget.node
                                                        .getPadding()!
                                                        .right))) <
                                      30
                                  ? 30
                                  : widget.node.getSize()!.width -
                                        (widget.node.getPadding() == null
                                            ? 0
                                            : (widget.node.getPadding()!.left +
                                                  widget.node
                                                      .getPadding()!
                                                      .right)))
                            : 100,
                      ),
                      child: TextField(
                        autofocus: true,
                        focusNode: widget.node._focusNode,
                        controller: _editingController,
                        style: widget.node.getTextStyle(),
                        scrollPadding: EdgeInsets.zero,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          widget.node.setTitle(_editingController.text);
                        },
                      ),
                    )
                  : (widget.node.image != null
                        ? (widget.node.getImagePosition() ==
                                  MindMapNodeImagePosition.left
                              ? (Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    widget.node.getNodeType() ==
                                                NodeType.root &&
                                            widget.node
                                                    .getMindMap()
                                                    ?.getMapType() ==
                                                MapType.fishbone &&
                                            widget.node
                                                    .getMindMap()
                                                    ?.getFishboneMapType() ==
                                                FishboneMapType.leftToRight
                                        ? Transform.flip(
                                            flipX: true,
                                            child: Image.memory(
                                              widget.node.image!,
                                              width: widget.node
                                                  .getImageWidth(),
                                              height: widget.node
                                                  .getImageHeight(),
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : Image.memory(
                                            widget.node.image!,
                                            width: widget.node.getImageWidth(),
                                            height: widget.node
                                                .getImageHeight(),
                                            fit: BoxFit.fill,
                                          ),
                                    SizedBox(
                                      width: widget.node.getImageSpace(),
                                    ),
                                    Text(
                                      widget.node.getTitle(),
                                      style: widget.node.getTextStyle(),
                                    ),
                                  ],
                                ))
                              : (widget.node.getImagePosition() ==
                                        MindMapNodeImagePosition.right
                                    ? (Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.node.getTitle(),
                                            style: widget.node.getTextStyle(),
                                          ),
                                          SizedBox(
                                            width: widget.node.getImageSpace(),
                                          ),
                                          widget.node.getNodeType() ==
                                                      NodeType.root &&
                                                  widget.node
                                                          .getMindMap()
                                                          ?.getMapType() ==
                                                      MapType.fishbone &&
                                                  widget.node
                                                          .getMindMap()
                                                          ?.getFishboneMapType() ==
                                                      FishboneMapType
                                                          .leftToRight
                                              ? Transform.flip(
                                                  flipX: true,
                                                  child: Image.memory(
                                                    widget.node.image!,
                                                    width: widget.node
                                                        .getImageWidth(),
                                                    height: widget.node
                                                        .getImageHeight(),
                                                    fit: BoxFit.fill,
                                                  ),
                                                )
                                              : Image.memory(
                                                  Base64Decoder().convert(
                                                    widget.node.getImage(),
                                                  ),
                                                  width: widget.node
                                                      .getImageWidth(),
                                                  height: widget.node
                                                      .getImageHeight(),
                                                  fit: BoxFit.fill,
                                                ),
                                        ],
                                      ))
                                    : (widget.node.getImagePosition() ==
                                              MindMapNodeImagePosition.top
                                          ? (Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.memory(
                                                  Base64Decoder().convert(
                                                    widget.node.getImage(),
                                                  ),
                                                  width: widget.node
                                                      .getImageWidth(),
                                                  height: widget.node
                                                      .getImageHeight(),
                                                  fit: BoxFit.fill,
                                                ),
                                                SizedBox(
                                                  height: widget.node
                                                      .getImageSpace(),
                                                ),
                                                Text(
                                                  widget.node.getTitle(),
                                                  style: widget.node
                                                      .getTextStyle(),
                                                ),
                                              ],
                                            ))
                                          : (Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  widget.node.getTitle(),
                                                  style: widget.node
                                                      .getTextStyle(),
                                                ),
                                                SizedBox(
                                                  height: widget.node
                                                      .getImageSpace(),
                                                ),
                                                Image.memory(
                                                  Base64Decoder().convert(
                                                    widget.node.getImage(),
                                                  ),
                                                  width: widget.node
                                                      .getImageWidth(),
                                                  height: widget.node
                                                      .getImageHeight(),
                                                  fit: BoxFit.fill,
                                                ),
                                              ],
                                            )))))
                        : Text(
                            widget.node.getTitle(),
                            style: widget.node.getTextStyle(),
                          ))),
        );
      },
    );
  }
}

enum MindMapNodeLinkOffsetMode { top, center, bottom }

class MindMapNodeAdapter implements INodeAdapter {
  @override
  IMindMapNode createNode() {
    return MindMapNode();
  }

  @override
  String getName() {
    return "MindMapNode";
  }
}

enum MindMapNodeImagePosition { left, right, top, bottom }
