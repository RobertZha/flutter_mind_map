import 'package:flutter/material.dart';
import 'package:flutter_mind_map/adapter/i_node_adapter.dart';
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
            while (getRightItems().length < getLeftItems().length - 1) {
              IMindMapNode node = getLeftItems().last;
              removeLeftItem(node);
              insertRightItem(node, 0);
            }
          } else {
            if (getLeftItems().isEmpty && getRightItems().isNotEmpty) {
              while (getRightItems().length > getLeftItems().length) {
                IMindMapNode node = getRightItems().first;
                removeRightItem(node);
                addLeftItem(node);
              }
            }
          }
          break;
        case MindMapType.left:
          while (getRightItems().isNotEmpty) {
            IMindMapNode node = getRightItems().last;
            removeRightItem(node);
            addLeftItem(node);
          }
          break;
        case MindMapType.right:
          while (getLeftItems().isNotEmpty) {
            IMindMapNode node = getLeftItems().last;
            removeLeftItem(node);
            insertLeftItem(node, 0);
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
    properties["Expanded"] = getExpanded().toString();
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
    addLeftItem(node);
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

  bool _expanded = true;

  ///Expanded
  @override
  bool getExpanded() {
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
        if (getNodeType() == NodeType.right) {
          index = getParentNode()!.getRightItems().indexOf(this);
        } else {
          index =
              getParentNode()!.getRightItems().length +
              getParentNode()!.getLeftItems().indexOf(this);
        }
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
      if (getParentNode() != null) {
        if (getNodeType() == NodeType.right) {
          index = getParentNode()!.getRightItems().indexOf(this);
        } else {
          index =
              getParentNode()!.getRightItems().length +
              getParentNode()!.getLeftItems().indexOf(this);
        }
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
          if (getNodeType() == NodeType.right) {
            index = getParentNode()!.getRightItems().indexOf(this);
          } else {
            index =
                getParentNode()!.getRightItems().length +
                getParentNode()!.getLeftItems().indexOf(this);
          }
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
    if (_textStyle != null) {
      return _textStyle;
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
      return textColor != null || fontSize != null || bold != null
          ? TextStyle(
              color: textColor ?? Colors.black,
              fontSize: fontSize ?? 16,
              fontWeight: bold == true ? FontWeight.bold : FontWeight.normal,
            )
          : (getParentNode() != null && getParentNode() is MindMapNode
                ? (getParentNode() as MindMapNode).getTextStyle()
                : TextStyle(fontSize: 16.0, color: Colors.black));
    }
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
          getSize()!.height / 2 +
          ((getBorderRadius() as BorderRadius).topLeft.x > getSize()!.height / 2
              ? getSize()!.height / 2
              : (getBorderRadius() as BorderRadius).topLeft.x) +
          getBorder().top.width / 2;
    }
    if (getLinkInOffsetMode() == MindMapNodeLinkOffsetMode.bottom) {
      return getSize()!.height / 2 -
          ((getBorderRadius() as BorderRadius).bottomLeft.x >
                  getSize()!.height / 2
              ? getSize()!.height / 2
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
          getSize()!.height / 2 +
          ((getBorderRadius() as BorderRadius).topRight.x >
                  getSize()!.height / 2
              ? getSize()!.height / 2
              : (getBorderRadius() as BorderRadius).topRight.x) +
          getBorder().top.width / 2;
    }
    if (getLinkOutOffsetMode() == MindMapNodeLinkOffsetMode.bottom) {
      return getSize()!.height / 2 -
          ((getBorderRadius() as BorderRadius).bottomRight.x >
                  getSize()!.height / 2
              ? getSize()!.height / 2
              : (getBorderRadius() as BorderRadius).bottomRight.x) -
          getBorder().bottom.width / 2;
    }
    return 0;
  }

  final FocusNode _focusNode = FocusNode();
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
                      minHeight: (widget.getMindMap()?.getButtonWidth() ?? 24)
                          .toDouble(),
                    ),
                    padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...(widget.getSelected()
                            ? (widget.getReadOnly()
                                  ? (widget.getNodeType() == NodeType.left &&
                                            widget.canExpand() &&
                                            widget.getLeftItems().isNotEmpty
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
                                                widget.getLinkOutOffset() > 0
                                                    ? widget.getLinkOutOffset() *
                                                          2
                                                    : 0,
                                                0,
                                                widget.getLinkOutOffset() < 0
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
                                      widget.getNodeType() == NodeType.root ||
                                              (widget
                                                      .getMindMap()
                                                      ?.getShowRecycle() ??
                                                  false)
                                          ? SizedBox(width: 0, height: 0)
                                          : SizedBox(width: 6),

                                      ///left Delete Button
                                      widget.getNodeType() == NodeType.root ||
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
                                                hoverColor: Colors.red.shade200,
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
                                      !(widget.getMindMap()?.hasTextField() ??
                                                  true) &&
                                              (widget
                                                      .getMindMap()
                                                      ?.hasEditButton() ??
                                                  false)
                                          ? SizedBox(width: 6)
                                          : SizedBox(width: 0),

                                      ///Edit Button
                                      !(widget.getMindMap()?.hasTextField() ??
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
                                                  widget.getMindMap()?.onEdit(
                                                    widget,
                                                  );
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
                                  ? (widget.getNodeType() == NodeType.left &&
                                            widget.canExpand() &&
                                            !widget.getExpanded() &&
                                            widget.getLeftItems().isNotEmpty
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
                                                widget.getLinkOutOffset() > 0
                                                    ? widget.getLinkOutOffset() *
                                                          2
                                                    : 0,
                                                0,
                                                widget.getLinkOutOffset() < 0
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
                                                    widget.setExpanded(
                                                      !widget.getExpanded(),
                                                    );
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(
                                                    Icons.add_circle_outline,
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
                      minHeight: (widget.getMindMap()?.getButtonWidth() ?? 24)
                          .toDouble(),
                    ),
                    padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...(widget.getSelected()
                            ? (widget.getReadOnly()
                                  ? (widget.getNodeType() == NodeType.right &&
                                            widget.canExpand() &&
                                            widget.getRightItems().isNotEmpty
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
                                                widget.getLinkOutOffset() > 0
                                                    ? widget.getLinkOutOffset() *
                                                          2
                                                    : 0,
                                                0,
                                                widget.getLinkOutOffset() < 0
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
                                      !(widget.getMindMap()?.hasTextField() ??
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
                                                  widget.getMindMap()?.onEdit(
                                                    widget,
                                                  );
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
                                      !(widget.getMindMap()?.hasTextField() ??
                                                  true) &&
                                              (widget
                                                      .getMindMap()
                                                      ?.hasEditButton() ??
                                                  false)
                                          ? SizedBox(width: 6)
                                          : SizedBox(width: 0),

                                      ///Right Delete Button
                                      widget.getNodeType() == NodeType.root ||
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
                                                hoverColor: Colors.red.shade200,
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
                                      widget.getNodeType() == NodeType.root ||
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
                                  ? (widget.getNodeType() == NodeType.right &&
                                            widget.canExpand() &&
                                            !widget.getExpanded() &&
                                            widget.getRightItems().isNotEmpty
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
                                                widget.getLinkOutOffset() > 0
                                                    ? widget.getLinkOutOffset() *
                                                          2
                                                    : 0,
                                                0,
                                                widget.getLinkOutOffset() < 0
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
                                                    widget.setExpanded(
                                                      !widget.getExpanded(),
                                                    );
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(
                                                    Icons.add_circle_outline,
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
        widget.node.setDragOfset(details.localPosition);
      },
      onTap: () {
        widget.node.getMindMap()?.setSelectedNode(widget.node);
      },
      onLongPressDown: (details) {
        widget.node.getMindMap()?.setSelectedNode(widget.node);
      },
      onDoubleTap: () {
        if (!(widget.node.getMindMap()?.getReadOnly() ?? false)) {
          widget.node.getMindMap()?.setSelectedNode(widget.node);
          widget.node.getMindMap()?.onDoubleTap(widget.node);
        }
      },
      child:
          (widget.node.getSelected() == false &&
                  !(widget.node.getMindMap()?.hasTextField() ?? false)) ||
              widget.node.getParentNode() == null ||
              widget.node.getMindMap()?.getReadOnly() == true ||
              (widget.node.getMindMap()?.getIsScaling() ?? false)
          ? getBody(border)
          : Draggable(
              data: widget.node,
              feedback: Transform.scale(
                scale: widget.node.getMindMap()?.getZoom() ?? 1.0,
                child: Opacity(opacity: 0.88, child: getBody(border)),
              ),
              child: getBody(border),
            ),
    );
  }

  Widget getBody(BoxBorder border) {
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
                  (widget.node.getMindMap()?.hasTextField() ?? false) &&
                  widget.node.getSelected() &&
                  !(widget.node.getMindMap()?.getIsScaling() ?? false)
              ? Container(
                  constraints: BoxConstraints(
                    maxWidth: widget.node.getSize() != null
                        ? ((widget.node.getSize()!.width -
                                      (widget.node.getPadding() == null
                                          ? 0
                                          : (widget.node.getPadding()!.left +
                                                widget.node
                                                    .getPadding()!
                                                    .right))) <
                                  30
                              ? 30
                              : widget.node.getSize()!.width -
                                    (widget.node.getPadding() == null
                                        ? 0
                                        : (widget.node.getPadding()!.left +
                                              widget.node.getPadding()!.right)))
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
              : Text(
                  widget.node.getTitle(),
                  style: widget.node.getTextStyle(),
                )),
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
