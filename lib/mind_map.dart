import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mind_map/adapter/i_link_adapter.dart';
import 'package:flutter_mind_map/adapter/i_node_adapter.dart';
import 'package:flutter_mind_map/adapter/i_theme_adapter.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/arc_line_linek.dart';
import 'package:flutter_mind_map/link/beerse_line_link.dart';
import 'package:flutter_mind_map/link/i_link.dart';
import 'package:flutter_mind_map/link/line_link.dart';
import 'package:flutter_mind_map/link/oblique_broken_line.dart';
import 'package:flutter_mind_map/link/poly_line_link.dart';
import 'package:flutter_mind_map/mind_map_node.dart';
import 'package:flutter_mind_map/theme/i_mind_map_theme.dart';
import 'package:flutter_mind_map/theme/json_theme.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_compact.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_large.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_normal.dart';
import 'package:path_drawing/path_drawing.dart';

// ignore: must_be_immutable
class MindMap extends StatefulWidget {
  MindMap({super.key});
  final GlobalKey _key = GlobalKey();

  String deleteNodeString = "Delete this node?";

  ///Multilingual text of 'Delete this node?' string
  String getDeleteNodeString() {
    return deleteNodeString;
  }

  ///Set multilingual text of 'Delete this node?' string
  void setDeleteNodeString(String value) {
    deleteNodeString = value;
  }

  String cancelString = "Cancel";

  ///Multilingual text of  Cancel string
  String getCancelString() {
    return cancelString;
  }

  ///Multilingual text of  Cancel string
  void setCancelString(String value) {
    cancelString = cancelString;
  }

  String okString = "OK";

  /// Multilingual text of OK string
  String getOkString() {
    return okString;
  }

  /// Multilingual text of OK string
  void setOkString(String value) {
    okString = value;
  }

  MapType _mapType = MapType.mind;

  /// Map type
  MapType getMapType() {
    return _mapType;
  }

  //Change Map Type
  void setMapType(MapType value) {
    if (_mapType != value) {
      _mapType = value;
      onMapTypeChanged();
      onChanged();
    }
  }

  MindMapType _mindMapType = MindMapType.leftAndRight;

  /// Mind map type
  MindMapType getMindMapType() {
    return _mindMapType;
  }

  void setMindMapType(MindMapType value) {
    if (getMapType() == MapType.mind && _mindMapType != value) {
      _mindMapType = value;
      switch (value) {
        case MindMapType.leftAndRight:
          if (getRootNode().getLeftItems().isNotEmpty &&
              getRootNode().getRightItems().isEmpty) {
            while (getRootNode().getRightItems().length <
                getRootNode().getLeftItems().length - 1) {
              IMindMapNode node = getRootNode().getLeftItems().last;
              getRootNode().removeLeftItem(node);
              getRootNode().insertRightItem(node, 0);
            }
          } else {
            if (getRootNode().getLeftItems().isEmpty &&
                getRootNode().getRightItems().isNotEmpty) {
              while (getRootNode().getRightItems().length >
                  getRootNode().getLeftItems().length) {
                IMindMapNode node = getRootNode().getRightItems().first;
                getRootNode().removeRightItem(node);
                getRootNode().addLeftItem(node);
              }
            }
          }
          break;
        case MindMapType.left:
          while (getRootNode().getRightItems().isNotEmpty) {
            IMindMapNode node = getRootNode().getRightItems().last;
            getRootNode().removeRightItem(node);
            getRootNode().addLeftItem(node);
          }
          break;
        case MindMapType.right:
          while (getRootNode().getLeftItems().isNotEmpty) {
            IMindMapNode node = getRootNode().getLeftItems().last;
            getRootNode().removeLeftItem(node);
            getRootNode().insertLeftItem(node, 0);
          }
          break;
      }
      refresh();
      onChanged();
    }
  }

  final List<Function()> _onMapTypeChangedListeners = [];

  /// Add listener for map type change
  void addOnMapTypeChangedListener(Function() listener) {
    _onMapTypeChangedListeners.add(listener);
  }

  /// Remove listener for map type change
  void removeOnMapTypeChangedListener(Function() listener) {
    _onMapTypeChangedListeners.remove(listener);
  }

  /// Called when the map type changes.
  void onMapTypeChanged() {
    for (Function() listener in _onMapTypeChangedListeners) {
      listener();
    }
  }

  String _watermark = "";

  ///WaterMark
  String getWatermark() {
    return _watermark;
  }

  ///Set Watermark
  void setWatermark(String value) {
    _watermark = value;
  }

  Color _watermarkColor = Colors.black;

  ///WaterMark Color
  Color getWatermarkColor() {
    return _watermarkColor;
  }

  ///Set Watermark Color
  void setWatermarkColor(Color value) {
    _watermarkColor = value;
  }

  double _watermarkOpacity = 0.1;

  ///WaterMark Opacity
  double getWatermarkOpacity() {
    return _watermarkOpacity;
  }

  ///Set Watermark Opacity
  void setWatermarkOpacity(double value) {
    _watermarkOpacity = value;
  }

  double _watermarkFontSize = 15;

  ///WaterMark Font Size
  double getWatermarkFontSize() {
    return _watermarkFontSize;
  }

  ///Set Watermark Font Size
  void setWatermarkFontSize(double value) {
    _watermarkFontSize = value;
  }

  double _watermarkRotationAngle = -0.5;

  ///WaterMark Rotation Angle
  double getWatermarkRotationAngle() {
    return _watermarkRotationAngle;
  }

  ///Set Watermark Rotation Angle
  void setWatermarkRotationAngle(double value) {
    _watermarkRotationAngle = value;
  }

  double _watermarkHorizontalInterval = 100;

  ///WaterMark Horizontal Interval
  double getWatermarkHorizontalInterval() {
    return _watermarkHorizontalInterval;
  }

  ///Set Watermark Horizontal Interval
  void setWatermarkHorizontalInterval(double value) {
    _watermarkHorizontalInterval = value;
  }

  double _watermarkVerticalInterval = 50;

  ///WaterMark Vertical Interval
  double getWatermarkVerticalInterval() {
    return _watermarkVerticalInterval;
  }

  ///Set Watermark Vertical Interval
  void setWatermarkVerticalInterval(double value) {
    _watermarkVerticalInterval = value;
  }

  ///End Watermark

  ///Export to PNG
  Future<Uint8List?> toPng() async {
    _state?.refresh();
    RenderRepaintBoundary boundary =
        _key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return byteData.buffer.asUint8List();
    }
    return null;
  }

  ///Load Data from Json
  void loadData(Map<String, dynamic> json) {
    if (json.containsKey("id") &&
        json.containsKey("content") &&
        json.containsKey("nodes")) {
      MindMapNode rootNode = MindMapNode();
      setRootNode(rootNode);
      rootNode.loadData(json);
    }
  }

  ///Export Data to Json
  Map<String, dynamic> getData() {
    return getRootNode().getData();
  }

  ///Export Data&Style to Json
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "MapType": getMapType().name,
      "RootNode": getRootNode().toJson(),
      "Zoom": getZoom().toString(),
      "BackgroundColor": colorToString(getBackgroundColor()),
      "Theme": getTheme() is JsonTheme
          ? jsonEncode((getTheme() as JsonTheme).json)
          : "",
    };
    if (getOffset() != null) {
      json["x"] = getOffset()!.dx.toString();
      json["y"] = getOffset()!.dy.toString();
    }
    return json;
  }

  bool _isLoading = false;

  ///Load Data&Style from Json
  void fromJson(Map<String, dynamic> json) {
    _isLoading = true;
    if (json.containsKey("MapType")) {
      MapType mapType = MapType.mind;
      for (MapType type in MapType.values) {
        if (type.name == json["MapType"].toString()) {
          mapType = type;
          break;
        }
      }
      setMapType(mapType);
    }
    if (json.containsKey("Zoom")) {
      setZoom(double.tryParse(json["Zoom"].toString()) ?? 1.0);
    }
    if (json.containsKey("BackgroundColor")) {
      setBackgroundColor(stringToColor(json["BackgroundColor"].toString()));
    }
    if (json.containsKey("x") && json.containsKey("y")) {
      double x = double.tryParse(json["x"].toString()) ?? 0;
      double y = double.tryParse(json["y"].toString()) ?? 0;
      setOffset(Offset(x, y));
    }
    if (json.containsKey("Theme")) {
      String themeName = json["Theme"];
      if (themeName.isNotEmpty) {
        Map<String, dynamic>? themeJson = jsonDecode(themeName);
        if (themeJson != null) {
          setTheme(JsonTheme("jsonTheme", themeJson));
        }
      }
    }
    if (json.containsKey("RootNode")) {
      Map<String, dynamic> map = json["RootNode"];
      if (map.isNotEmpty) {
        IMindMapNode? node = createNode(map.keys.first);
        if (node != null) {
          setRootNode(node);
          node.fromJson(map);
        }
      }
    }
    _isLoading = false;
  }

  int _buttonWidth = 24;

  ///Button Width
  int getButtonWidth() {
    return _buttonWidth;
  }

  ///Set Button Width
  void setButtonWidth(int value) {
    if (_buttonWidth != value) {
      _buttonWidth = value;
      _state?.refresh();
    }
  }

  Color _buttonColor = Colors.black;

  ///Button Color
  Color getButtonColor() {
    return _buttonColor;
  }

  ///Set Button Color
  void setButtonColor(Color value) {
    if (_buttonColor != value) {
      _buttonColor = value;
      _state?.refresh();
    }
  }

  Color _buttonBackground = Colors.white;

  ///Button Background
  Color getButtonBackground() {
    return _buttonBackground;
  }

  ///Set Button Background
  void setButtonBackground(Color value) {
    if (_buttonBackground != value) {
      _buttonBackground = value;
      _state?.refresh();
    }
  }

  Color _dragInBorderColor = Colors.cyan;

  ///Drag In Border Color
  Color getDragInBorderColor() {
    return _dragInBorderColor;
  }

  ///Set Drag In Border Color
  void setDragInBorderColor(Color value) {
    if (_dragInBorderColor != value) {
      _dragInBorderColor = value;
      _state?.refresh();
    }
  }

  double _dragInBorderWidth = 3;

  ///Drag In Border Width
  double getDragInBorderWidth() {
    return _dragInBorderWidth;
  }

  ///Set Drag In Border Width
  void setDragInBorderWidth(double value) {
    if (_dragInBorderWidth != value) {
      _dragInBorderWidth = value;
      _state?.refresh();
    }
  }

  double _mindMapPadding = 80;

  ///MindMap Padding
  double getMindMapPadding() {
    return _mindMapPadding;
  }

  ///Set MindMap Padding
  void setMindMapPadding(double value) {
    if (_mindMapPadding != value) {
      _mindMapPadding = value;
      _state?.refresh();
    }
  }

  ///Adapter
  final List<INodeAdapter> _nodeAdapter = [MindMapNodeAdapter()];

  ///Register Node Adapter
  void registerNodeAdapter(INodeAdapter value) {
    if (!_nodeAdapter.contains(value)) {
      _nodeAdapter.add(value);
    }
  }

  ///Get Node Adapter
  List<INodeAdapter> getNodeAdapter() {
    return _nodeAdapter;
  }

  ///Create Node
  IMindMapNode? createNode(String name) {
    for (INodeAdapter na in _nodeAdapter) {
      if (na.getName() == name) {
        return na.createNode();
      }
    }
    return null;
  }

  final List<ILinkAdapter> _linkAdapter = [
    BeerseLinkLinkAdapter(),
    LineLinkAdapter(),
    PolyLineLinkAdapter(),
    ObliqueBrokenLineAdapter(),
    ArcLineLinkAdapter(),
  ];

  ///Register Link Adapter
  void registerLinkAdapter(ILinkAdapter value) {
    if (!_linkAdapter.contains(value)) {
      _linkAdapter.add(value);
    }
  }

  ///Get Link Adapter
  List<ILinkAdapter> getLinkAdapter() {
    return _linkAdapter;
  }

  ///Create Link
  ILink? createLink(String name) {
    for (ILinkAdapter na in _linkAdapter) {
      if (na.getName() == name) {
        return na.createLink();
      }
    }
    return null;
  }

  final List<IThemeAdapter> _themeAdapter = [
    MindMapThemeCompactAdapter(),
    MindMapThemeNormalAdapter(),
    MindMapThemeLargeAdapter(),
  ];

  ///Register Theme Adapter
  void registerThemeAdapter(IThemeAdapter value) {
    if (!_themeAdapter.contains(value)) {
      _themeAdapter.add(value);
    }
  }

  ///Get Theme Adapter
  List<IThemeAdapter> getThemeAdapter() {
    return _themeAdapter;
  }

  ///Create Theme
  IMindMapTheme? createTheme(String name) {
    for (IThemeAdapter na in _themeAdapter) {
      if (na.getName() == name) {
        return na.createTheme();
      }
    }
    return null;
  }

  ///End Adapter

  bool _showRecycle = true;

  ///Show Recycle
  bool getShowRecycle() {
    return _showRecycle;
  }

  ///Set Show Recycle
  void setShowRecycle(bool value) {
    if (_showRecycle != value) {
      _showRecycle = value;
      _state?.refresh();
    }
  }

  String _recycleTitle = "Drag here to delete";

  ///Recycle Title
  String getRecycleTitle() {
    return _recycleTitle;
  }

  ///Set Recycle Title
  void setRecycleTitle(String value) {
    if (_recycleTitle != value) {
      _recycleTitle = value;
      _state?.refresh();
    }
  }

  bool _canMove = true;

  ///Can Move
  bool getCanMove() {
    return _canMove;
  }

  ///  Set Can Move
  void setCanMove(bool value) {
    if (_canMove != value) {
      _canMove = value;
      _state?.refresh();
    }
  }

  bool _showZoom = true;

  ///Show Zoom
  bool getShowZoom() {
    return _showZoom;
  }

  ///Set Show Zoom
  void setShowZoom(bool value) {
    if (_showZoom != value) {
      _showZoom = value;
      _state?.refresh();
    }
  }

  ///refresh MindMap
  void refresh() {
    _state?.refresh();
  }

  double _zoom = 1;

  ///Zoom
  double getZoom() {
    return _zoom;
  }

  ///Set Zoom
  void setZoom(double value) {
    if (value > 0 && _zoom != value) {
      _zoom = value;
      List<Function()> list = [];
      list.addAll(_onZoomChangedListeners);
      for (Function() call in list) {
        call();
      }
    }
  }

  bool _isScaling = false;
  bool getIsScaling() {
    return _isScaling;
  }

  void setIsScaling(bool value) {
    if (_isScaling != value) {
      _isScaling = value;
    }
  }

  final List<Function()> _onChangedListeners = [];

  ///Add On Changed Listeners
  void addOnChangedListeners(Function() value) {
    _onChangedListeners.add(value);
  }

  ///Remove On Changed Listeners
  void removeOnChangedListeners(Function() value) {
    _onChangedListeners.remove(value);
  }

  ///On Changed
  void onChanged() {
    if (!_isLoading) {
      List<Function()> list = [];
      list.addAll(_onChangedListeners);
      for (Function() call in list) {
        call();
      }
    }
  }

  IMindMapTheme? _theme;

  ///Theme
  IMindMapTheme? getTheme() {
    return _theme;
  }

  ///Set Theme
  void setTheme(IMindMapTheme? value) {
    getRootNode().clearStyle();
    _theme = value;
    refresh();
    onChanged();
  }

  final List<Function()> _onZoomChangedListeners = [];

  ///Add On Zoom Changed Listeners
  void addOnZoomChangedListeners(Function() value) {
    _onZoomChangedListeners.add(value);
  }

  ///Remove On Zoom Changed Listeners
  void removeOnZoomChangedListeners(Function() value) {
    _onZoomChangedListeners.remove(value);
  }

  IMindMapNode? _selectedNode;

  ///Selected Node
  IMindMapNode? getSelectedNode() {
    return _selectedNode;
  }

  ///Set Selected Node
  void setSelectedNode(IMindMapNode? node) {
    _selectedNode = node;
    notifySelectedNodeChanged();
  }

  final List<Function()> _onTapListeners = [];

  ///Add On Tap Listeners
  void addOnTapListeners(Function() callback) {
    _onTapListeners.add(callback);
  }

  ///Remove On Tap Listeners
  void removeOnTapListeners(Function() callback) {
    _onTapListeners.remove(callback);
  }

  ///On Tap
  void onTap() {
    List<Function()> list = [];
    list.addAll(_onTapListeners);
    for (Function() call in list) {
      call();
    }
  }

  final List<Function()> _onSelectedNodeChangedListeners = [];

  ///Add On Selected Node Changed Listeners
  void addOnSelectedNodeChangedListeners(Function() callback) {
    _onSelectedNodeChangedListeners.add(callback);
  }

  ///Remove On Selected Node Changed Listeners
  void removeOnSelectedNodeChangedListeners(Function() callback) {
    _onSelectedNodeChangedListeners.remove(callback);
  }

  ///Notify Selected Node Changed
  void notifySelectedNodeChanged() {
    for (var listener in _onSelectedNodeChangedListeners) {
      listener();
    }
  }

  final List<Function(IMindMapNode)> _onDoubleTapListeners = [];

  ///Add On Double Tap Listeners
  void addOnDoubleTapListeners(Function(IMindMapNode) value) {
    _onDoubleTapListeners.add(value);
  }

  ///Remove On Double Tap Listeners
  void removeOnDoubleTapListeners(Function(IMindMapNode) value) {
    _onDoubleTapListeners.remove(value);
  }

  ///On Double Tap
  void onDoubleTap(IMindMapNode node) {
    List<Function(IMindMapNode)> list = [];
    list.addAll(_onDoubleTapListeners);
    for (Function(IMindMapNode) call in list) {
      call(node);
    }
  }

  final List<Function(IMindMapNode)> _onEditListeners = [];

  ///Add On Edit Listeners
  void addOnEditListeners(Function(IMindMapNode) value) {
    _onEditListeners.add(value);
  }

  ///Remove On Edit Listeners
  void removeOnEditListeners(Function(IMindMapNode) value) {
    _onEditListeners.remove(value);
  }

  ///On Edit
  void onEdit(IMindMapNode node) {
    List<Function(IMindMapNode)> list = [];
    list.addAll(_onEditListeners);
    for (Function(IMindMapNode) call in list) {
      call(node);
    }
  }

  bool _readOnly = false;

  ///Set Read Only
  void setReadOnly(bool value) {
    if (_readOnly != value) {
      _readOnly = value;
      setSelectedNode(null);
      _state?.refresh();
    }
  }

  ///Read Only
  bool getReadOnly() => _readOnly;

  bool _hasTextField = true;

  ///Has TextField
  void setHasTextField(bool value) {
    if (_hasTextField != value) {
      _hasTextField = value;
      setSelectedNode(null);
      _state?.refresh();
    }
  }

  ///Display text input box
  bool hasTextField() => _hasTextField;

  bool _hasEditButton = false;

  ///set Has Edit Button
  void setHasEditButton(bool value) {
    if (_hasEditButton != value) {
      _hasEditButton = value;
      setSelectedNode(null);
      _state?.refresh();
    }
  }

  ///Display edit button
  bool hasEditButton() => _hasEditButton;

  Color? _backgroundColor;

  ///Background Color
  Color getBackgroundColor() =>
      _backgroundColor ??
      (getTheme() != null
          ? getTheme()!.getBackgroundColor()
          : Colors.transparent);

  ///Set Background Color
  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    _state?.refresh();
    onChanged();
  }

  IMindMapNode _rootNode = MindMapNode();

  ///Root Node
  IMindMapNode getRootNode() {
    if (_rootNode.getMindMap() == null) {
      _rootNode.setMindMap(this);
    }
    return _rootNode;
  }

  ///Set Root Node
  void setRootNode(IMindMapNode rootNode) {
    _rootNode = rootNode;
    _rootNode.setMindMap(this);
    onRootNodeChanged();
  }

  final List<Function()> _onRootNodeChangeListeners = [];

  ///Add On Root Node Change Listeners
  void addOnRootNodeChangeListener(Function() listener) {
    _onRootNodeChangeListeners.add(listener);
  }

  ///Remove On Root Node Change Listeners
  void removeOnRootNodeChangeListener(Function() listener) {
    _onRootNodeChangeListeners.remove(listener);
  }

  ///Notify Root Node Changed
  void onRootNodeChanged() {
    for (var listener in _onRootNodeChangeListeners) {
      listener();
    }
  }

  final List<Function()> _onMoveListeners = [];

  ///Add On Move Listeners
  void addOnMoveListeners(Function() callback) {
    _onMoveListeners.add(callback);
  }

  ///Remove On Move Listeners
  void removeOnMoveListeners(Function() callback) {
    _onMoveListeners.remove(callback);
  }

  ///On Move
  void onMove() {
    for (var listener in _onMoveListeners) {
      listener();
    }
  }

  @override
  State<StatefulWidget> createState() => MindMapState();

  MindMapState? _state;

  Offset? _offset;

  ///Set Offset
  void setOffset(Offset? value) {
    _offset = value;
    _state?.refresh();
  }

  ///Get Offset
  Offset? getOffset() => _offset;

  ///Move Offset
  Offset moveOffset = Offset.zero;

  ///Set Move Offset
  void setMoveOffset(Offset value) {
    if (moveOffset.dx != value.dx || moveOffset.dy != value.dy) {
      moveOffset = value;
      onMove();
    }
  }

  ///Get Move Offset
  Offset getMoveOffset() => moveOffset;

  Size? _size;

  ///Set Size
  void setSize(Size? value) {
    if (_size == null ||
        (value != null &&
            (value.width != _size!.width || value.height != _size!.height))) {
      _size = value;
      _state?.refresh();
    }
  }

  ///Get Size
  Size? getSize() => _size;

  RenderObject? _renderObject;

  RenderObject? getRenderObject() {
    return _renderObject;
  }

  IMindMapNode? _dragInNode;
  IMindMapNode? _dragNode;
  Offset? _dragOffset;
  bool _leftDrag = true;
  bool _inRecycle = false;
}

class MindMapState extends State<MindMap> {
  @override
  void initState() {
    super.initState();
    widget.addOnRootNodeChangeListener(onRootNodeChanged);
    widget.addOnSelectedNodeChangedListeners(onSelectedNodeChanged);
    widget.addOnMapTypeChangedListener(onMapTypeChanged);
  }

  @override
  void dispose() {
    widget.removeOnRootNodeChangeListener(onRootNodeChanged);
    widget.removeOnSelectedNodeChangedListeners(onSelectedNodeChanged);
    widget.removeOnMapTypeChangedListener(onMapTypeChanged);
    super.dispose();
  }

  void onRootNodeChanged() {
    setState(() {});
  }

  void onSelectedNodeChanged() {
    setState(() {});
  }

  void onMapTypeChanged() {
    setState(() {});
  }

  Size s = Size.zero;

  Offset _focalPoint = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _lastScale = 1.0;

  double _oldzoom = 1.0;

  final GlobalKey _pkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    widget._state = this;
    WidgetsBinding.instance.addPostFrameCallback((c) {
      if (mounted) {
        RenderObject? ro = context.findRenderObject();
        if (ro != null && ro is RenderBox) {
          if (s.width != ro.size.width || s.height != ro.size.height) {
            setState(() {
              s = ro.size;
            });
          }
        }
      }
    });
    double x = widget.getOffset()?.dx ?? 0;
    double y = widget.getOffset()?.dy ?? 0;
    Size? size = widget.getSize();
    if (s.isEmpty) {
      s = MediaQuery.of(context).size;
    }
    if (widget.getOffset() == null &&
        size != null &&
        size.width > 0 &&
        size.height > 0) {
      x = (s.width - size.width * widget.getZoom()) / 2;
      y = (s.height - size.height * widget.getZoom()) / 2;

      ///set RooetNode Center
      Size? rs = widget.getRootNode().getSize();
      Offset? ro = widget.getRootNode().getOffset();
      if (rs != null && ro != null) {
        if (widget.getRootNode().getLeftItems().isNotEmpty &&
            widget.getRootNode().getRightItems().isNotEmpty) {
          x =
              s.width / 2 -
              ro.dx -
              rs.width / 2 +
              (ro.dx - size.width / 2 + rs.width / 2) -
              (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();
          y =
              s.height / 2 -
              ro.dy -
              rs.height / 2 +
              (ro.dy - size.height / 2 + rs.height / 2) -
              (ro.dy - size.height / 2 + rs.height / 2) * widget.getZoom();
        } else {
          if (widget.getRootNode().getLeftItems().isNotEmpty) {
            x =
                s.width / 2 -
                ro.dx -
                rs.width / 2 +
                (ro.dx - size.width / 2 + rs.width / 2) -
                (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();

            x = s.width < size.width * widget.getZoom()
                ? x +
                      s.width / 2 -
                      rs.width * widget.getZoom() / 2 -
                      widget.getMindMapPadding()
                : x + size.width * widget.getZoom() / 2;

            y =
                s.height / 2 -
                ro.dy -
                rs.height / 2 +
                (ro.dy - size.height / 2 + rs.height / 2) -
                (ro.dy - size.height / 2 + rs.height / 2) * widget.getZoom();
          } else {
            x =
                s.width / 2 -
                ro.dx -
                rs.width / 2 +
                (ro.dx - size.width / 2 + rs.width / 2) -
                (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();

            x = s.width < size.width * widget.getZoom()
                ? x -
                      (s.width / 2 -
                          rs.width * widget.getZoom() / 2 -
                          widget.getMindMapPadding())
                : x - size.width * widget.getZoom() / 2;
            y =
                s.height / 2 -
                ro.dy -
                rs.height / 2 +
                (ro.dy - size.height / 2 + rs.height / 2) -
                (ro.dy - size.height / 2 + rs.height / 2) * widget.getZoom();
          }
        }
      }
    }
    return Container(
      color: widget.getBackgroundColor(),
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onTap: () {
          widget.setIsScaling(false);
          widget.setSelectedNode(null);
          widget.onTap();
        },

        ///Scale
        onScaleStart: (details) {
          if (widget.getCanMove()) {
            widget.setIsScaling(true);
            setState(() {
              _oldzoom = widget.getZoom();
              widget._dragInNode = null;
              widget._dragNode = null;
              _focalPoint = widget.getMoveOffset();
              _lastFocalPoint = details.focalPoint;
              _lastScale = widget.getZoom();
            });
          }
        },
        onScaleUpdate: (details) {
          if (widget.getCanMove()) {
            setState(() {
              double scale = _lastScale * details.scale;
              widget.setZoom(scale < 0.1 ? 0.1 : scale);
              widget.setMoveOffset(
                Offset(
                  _focalPoint.dx + details.focalPoint.dx - _lastFocalPoint.dx,
                  _focalPoint.dy + details.focalPoint.dy - _lastFocalPoint.dy,
                ),
              );
            });
          }
        },
        onScaleEnd: (details) {
          widget.setIsScaling(false);
          if (_oldzoom != widget.getZoom()) {
            widget.onChanged();
          }
        },
        child: DragTarget(
          key: _pkey,
          builder: (context, candidateData, rejectedData) {
            return Container(
              color: widget.getBackgroundColor(),
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    left:
                        x +
                        widget.getMoveOffset().dx -
                        widget.getMindMapPadding() * widget.getZoom(),
                    top:
                        y +
                        widget.getMoveOffset().dy -
                        widget.getMindMapPadding() * widget.getZoom(),
                    child: Transform.scale(
                      scale: widget.getZoom(),
                      child: RepaintBoundary(
                        key: widget._key,
                        child: Container(
                          color: widget.getBackgroundColor(),
                          child: CustomPaint(
                            painter: MindMapPainter(mindMap: widget),
                            child: Container(
                              padding: EdgeInsets.all(
                                widget.getMindMapPadding() * widget.getZoom(),
                              ),
                              child: widget.getRootNode() as Widget,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  widget.getWatermark().isEmpty
                      ? Container()
                      : Row(
                          children: List.generate(20, (index) {
                            return Column(
                              children: List.generate(20, (index) => "Item $index")
                                  .map(
                                    (item) => Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Transform.rotate(
                                              angle: widget
                                                  .getWatermarkRotationAngle(),
                                              child: Opacity(
                                                opacity: widget
                                                    .getWatermarkOpacity(),
                                                child: Text(
                                                  widget.getWatermark(),
                                                  style: TextStyle(
                                                    color: widget
                                                        .getWatermarkColor(),
                                                    fontSize: widget
                                                        .getWatermarkFontSize(),
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.white,
                                                        offset: Offset.zero,
                                                        blurRadius: 3,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: widget
                                                  .getWatermarkHorizontalInterval(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: widget
                                              .getWatermarkVerticalInterval(),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                        ),

                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    height: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MediaQuery.of(context).size.width > 600
                            ? Container()
                            : Spacer(),

                        ///Recycle
                        widget.getReadOnly() || !widget.getShowRecycle()
                            ? Container()
                            : DragTarget(
                                onWillAcceptWithDetails: (details) {
                                  if (!widget.getIsScaling() &&
                                      details.data is IMindMapNode) {
                                    setState(() {
                                      widget._inRecycle = true;
                                      widget._dragNode =
                                          details.data as IMindMapNode;
                                    });
                                    return true;
                                  }
                                  return false;
                                },
                                onAcceptWithDetails: (details) {
                                  if (!widget.getIsScaling() &&
                                      widget._dragNode != null) {
                                    setState(() {
                                      if (widget._dragNode!.getNodeType() ==
                                          NodeType.left) {
                                        widget._dragNode!
                                            .getParentNode()
                                            ?.removeLeftItem(widget._dragNode!);
                                      } else {
                                        widget._dragNode!
                                            .getParentNode()
                                            ?.removeRightItem(
                                              widget._dragNode!,
                                            );
                                      }
                                      widget._inRecycle = false;
                                      widget._dragNode = null;
                                    });
                                  }
                                },
                                onLeave: (data) {
                                  setState(() {
                                    widget._inRecycle = false;
                                  });
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: widget._inRecycle
                                                ? Colors.red
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          8,
                                          0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_outline_outlined,
                                              size: 20,
                                              color: widget._inRecycle
                                                  ? Colors.red
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.outline,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              widget.getRecycleTitle(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: widget._inRecycle
                                                    ? Colors.red
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              ),
                        MediaQuery.of(context).size.width > 600
                            ? Container()
                            : Spacer(),
                        (widget.getShowZoom()
                            ? SizedBox(width: 20)
                            : Container()),

                        ///Zoom
                        widget.getShowZoom()
                            ? Container(
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                  maxHeight: 32,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ToggleButtons(
                                  constraints: const BoxConstraints.tightFor(
                                    height: 32,
                                    width: 32,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  borderColor: Theme.of(
                                    context,
                                  ).colorScheme.outline,
                                  isSelected: const [false, false, false],
                                  onPressed: (index) {
                                    switch (index) {
                                      case 0:
                                        if (widget.getZoom() > 0.2 && mounted) {
                                          setState(() {
                                            widget.setZoom(
                                              widget.getZoom() - 0.1,
                                            );
                                            widget.onChanged();
                                          });
                                        }
                                        break;
                                      case 1:
                                        setState(() {
                                          widget.setMoveOffset(Offset.zero);
                                          if (widget.getZoom() != 1) {
                                            widget.setZoom(1);
                                            widget.onChanged();
                                          }
                                        });
                                      case 2:
                                        if (widget.getZoom() < 2 && mounted) {
                                          setState(() {
                                            widget.setZoom(
                                              widget.getZoom() + 0.1,
                                            );
                                            widget.onChanged();
                                          });
                                        }
                                        break;
                                    }
                                  },
                                  children: [
                                    Icon(
                                      Icons.remove,
                                      size: 16,
                                      shadows: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          blurRadius: 4.0,
                                          blurStyle: BlurStyle.outer,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${(widget.getZoom() * 100).round()}%",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            fontSize: 8,
                                            shadows: [
                                              BoxShadow(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                blurRadius: 4.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                            ],
                                          ),
                                    ),
                                    Icon(
                                      Icons.add,
                                      size: 16,
                                      shadows: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          blurRadius: 4.0,
                                          blurStyle: BlurStyle.outer,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          onWillAcceptWithDetails: (details) {
            if (!widget.getIsScaling()) {
              if (details.data is IMindMapNode) {
                setState(() {
                  widget._dragNode = details.data as IMindMapNode;
                });
                return true;
              }
              setState(() {
                widget._dragNode = null;
              });
            }
            return false;
          },
          onAcceptWithDetails: (details) {
            if (!widget.getIsScaling()) {
              if (details.data is IMindMapNode) {
                setState(() {
                  if (widget._dragInNode != null) {
                    if ((details.data as IMindMapNode).getNodeType() ==
                        NodeType.left) {
                      (details.data as IMindMapNode)
                          .getParentNode()
                          ?.removeLeftItem((details.data as IMindMapNode));
                    } else {
                      (details.data as IMindMapNode)
                          .getParentNode()
                          ?.removeRightItem((details.data as IMindMapNode));
                    }
                    if (widget._leftDrag) {
                      widget._dragInNode!.insertLeftItem(
                        (details.data as IMindMapNode),
                        _dragIndex,
                      );
                    } else {
                      widget._dragInNode!.insertRightItem(
                        (details.data as IMindMapNode),
                        _dragIndex,
                      );
                    }
                    widget.getRootNode().refresh();
                    widget.onChanged();
                  }
                  widget.refresh();
                  widget._dragInNode = null;
                });
              }
              setState(() {
                widget._dragNode = null;
              });
            }
          },
          onLeave: (data) {
            setState(() {
              widget._dragInNode = null;
              widget._dragNode = null;
            });
          },
          onMove: (details) {
            if (!widget.getIsScaling()) {
              if (details.data is IMindMapNode) {
                widget._dragInNode = details.data as IMindMapNode;
                Size dataSize =
                    (details.data as IMindMapNode).getSize() ?? Size.zero;
                RenderObject? ro = widget._key.currentContext
                    ?.findRenderObject();
                widget._renderObject = ro;
                if (ro != null && ro is RenderBox) {
                  Offset r = ro.localToGlobal(Offset.zero);
                  Offset offset = Offset(
                    details.offset.dx -
                        r.dx +
                        dataSize.width +
                        (dataSize.width * widget.getZoom() / 2) -
                        dataSize.width / 2,
                    details.offset.dy - r.dy + dataSize.height / 2,
                  );

                  IMindMapNode? leftDragNode = inLeftDrag(
                    details.data as IMindMapNode,
                    offset,
                  );
                  if (leftDragNode != null &&
                      !isParent(details.data as IMindMapNode, leftDragNode)) {
                    setState(() {
                      widget._leftDrag = true;
                      widget._dragInNode = leftDragNode;
                      widget._dragOffset = offset;
                    });
                    return;
                  }

                  offset = Offset(
                    details.offset.dx -
                        r.dx -
                        (dataSize.width * widget.getZoom() / 2) +
                        dataSize.width / 2,
                    details.offset.dy - r.dy + dataSize.height / 2,
                  );

                  IMindMapNode? rightDragNode = inRightDrag(
                    details.data as IMindMapNode,
                    offset,
                  );
                  if (rightDragNode != null &&
                      !isParent(details.data as IMindMapNode, rightDragNode)) {
                    setState(() {
                      widget._leftDrag = false;
                      widget._dragInNode = rightDragNode;
                      widget._dragOffset = offset;
                    });
                    return;
                  }

                  setState(() {
                    widget._dragInNode = null;
                  });
                }
              }
            }
          },
        ),
      ),
    );
  }

  IMindMapNode? inLeftDrag(IMindMapNode node, Offset offset) {
    return inLeftDragByParentNode(node, offset, widget.getRootNode());
  }

  int _dragIndex = 0;

  IMindMapNode? inLeftDragByParentNode(
    IMindMapNode node,
    Offset offset,
    IMindMapNode parentNode,
  ) {
    Rect? rect = parentNode.getLeftArea();

    if (rect != null) {
      if (parentNode.getNodeType() == NodeType.root) {
        rect = Rect.fromLTRB(
          rect.left,
          rect.top - 200,
          rect.right,
          rect.bottom + 200,
        );
      }
      if (rect.top * widget.getZoom() <= offset.dy &&
          rect.left * widget.getZoom() <= offset.dx &&
          rect.bottom * widget.getZoom() >= offset.dy &&
          rect.right * widget.getZoom() >= offset.dx) {
        _dragIndex = 0;
        if (parentNode.getLeftItems().isNotEmpty) {
          _dragIndex = parentNode.getLeftItems().length;
          int index = 0;

          for (IMindMapNode n in parentNode.getLeftItems()) {
            Size? size = n.getSize();
            Offset o = n.getOffset() ?? Offset.zero;
            if (n.getRenderObject() is RenderBox) {
              Offset po = (n.getRenderObject() as RenderBox).localToGlobal(
                Offset.zero,
                ancestor: widget._renderObject,
              );
              o = Offset(o.dx + po.dx, o.dy + po.dy);
            }
            if (o.dy * widget.getZoom() +
                    (size?.height ?? 0) * widget.getZoom() / 2 >
                offset.dy) {
              _dragIndex = index;
              break;
            }
            index++;
          }
        }
        if (node.getParentNode() == parentNode &&
            node.getNodeType() == NodeType.left) {
          int i = parentNode.getLeftItems().indexOf(node);
          if (i < _dragIndex && _dragIndex > 0) {
            _dragIndex--;
          }
        }
        return parentNode;
      }
      for (IMindMapNode cn in parentNode.getLeftItems()) {
        IMindMapNode? n = inLeftDragByParentNode(node, offset, cn);
        if (n != null) {
          return n;
        }
      }
    }
    return null;
  }

  IMindMapNode? inRightDrag(IMindMapNode node, Offset offset) {
    return inRightDragByParentNode(node, offset, widget.getRootNode());
  }

  IMindMapNode? inRightDragByParentNode(
    IMindMapNode node,
    Offset offset,
    IMindMapNode parentNode,
  ) {
    Rect? rect = parentNode.getRightArea();

    if (rect != null) {
      if (parentNode.getNodeType() == NodeType.root) {
        rect = Rect.fromLTRB(
          rect.left,
          rect.top - 200,
          rect.right,
          rect.bottom + 200,
        );
      }
      if (rect.top * widget.getZoom() <= offset.dy &&
          rect.left * widget.getZoom() <= offset.dx &&
          rect.bottom * widget.getZoom() >= offset.dy &&
          rect.right * widget.getZoom() >= offset.dx) {
        _dragIndex = 0;
        if (parentNode.getRightItems().isNotEmpty) {
          _dragIndex = parentNode.getRightItems().length;
          int index = 0;

          for (IMindMapNode n in parentNode.getRightItems()) {
            Size? size = n.getSize();
            Offset o = n.getOffset() ?? Offset.zero;
            if (n.getRenderObject() is RenderBox) {
              Offset po = (n.getRenderObject() as RenderBox).localToGlobal(
                Offset.zero,
                ancestor: widget._renderObject,
              );
              o = Offset(o.dx + po.dx, o.dy + po.dy);
            }
            if (o.dy * widget.getZoom() +
                    (size?.height ?? 0) * widget.getZoom() / 2 >
                offset.dy) {
              _dragIndex = index;
              break;
            }
            index++;
          }
        }
        if (node.getParentNode() == parentNode &&
            node.getNodeType() == NodeType.right) {
          int i = parentNode.getRightItems().indexOf(node);
          if (i < _dragIndex && _dragIndex > 0) {
            _dragIndex--;
          }
        }
        return parentNode;
      }
      for (IMindMapNode cn in parentNode.getRightItems()) {
        IMindMapNode? n = inRightDragByParentNode(node, offset, cn);
        if (n != null) {
          return n;
        }
      }
    }
    return null;
  }

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

  void refresh() {
    if (mounted) {
      setState(() {
        widget.getRootNode().setOffset(null);
        widget.getRootNode().setSize(null);
      });
    }
  }
}

class MindMapPainter extends CustomPainter {
  MindMapPainter({required this.mindMap});

  MindMap mindMap;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = mindMap.getDragInBorderWidth()
      ..color = mindMap.getDragInBorderColor();
    if (mindMap._dragInNode != null && !mindMap.getIsScaling()) {
      ///canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
      RenderObject? ro = mindMap._dragInNode!.getRenderObject();
      if (ro != null && mindMap._renderObject != null) {
        Offset o = (ro as RenderBox).localToGlobal(
          Offset.zero,
          ancestor: mindMap._renderObject,
        );
        Path path = Path();
        path.addRRect(
          RRect.fromLTRBR(
            o.dx +
                (mindMap._dragInNode!.getOffset()?.dx ?? 0) -
                3 -
                mindMap.getDragInBorderWidth(),
            o.dy +
                (mindMap._dragInNode!.getOffset()?.dy ?? 0) -
                3 -
                mindMap.getDragInBorderWidth(),
            o.dx +
                (mindMap._dragInNode!.getOffset()?.dx ?? 0) +
                (mindMap._dragInNode!.getSize()?.width ?? 0) +
                3 +
                mindMap.getDragInBorderWidth(),
            o.dy +
                (mindMap._dragInNode!.getOffset()?.dy ?? 0) +
                (mindMap._dragInNode!.getSize()?.height ?? 0) +
                3 +
                mindMap.getDragInBorderWidth(),
            Radius.circular(6),
          ),
        );
        canvas.drawPath(
          dashPath(
            path,
            dashArray: CircularIntervalList<double>(<double>[10, 10]),
          ),
          paint,
        );
        if (mindMap._dragOffset != null) {
          Path pathline = Path();
          double x1 = mindMap._dragOffset!.dx / mindMap.getZoom();
          double y1 = mindMap._dragOffset!.dy / mindMap.getZoom();
          double x2 =
              o.dx +
              (mindMap._dragInNode!.getOffset()?.dx ?? 0) +
              (mindMap._leftDrag
                  ? 0
                  : (mindMap._dragInNode!.getSize()?.width ?? 0));
          double y2 =
              o.dy +
              (mindMap._dragInNode!.getOffset()?.dy ?? 0) +
              (mindMap._dragInNode!.getSize()?.height ?? 0) / 2 +
              (mindMap._dragInNode!.getLinkOutOffset());
          pathline.moveTo(
            mindMap._dragOffset!.dx / mindMap.getZoom(),
            mindMap._dragOffset!.dy / mindMap.getZoom(),
          );
          pathline.cubicTo(
            x1 + (x2 - x1) / 2,
            y1,
            x2 - (x2 - x1) / 2,
            y2,
            x2,
            y2,
          );
          canvas.drawPath(
            dashPath(
              pathline,
              dashArray: CircularIntervalList<double>(<double>[10, 10]),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum MapType { mind }

enum MindMapType { left, leftAndRight, right }
