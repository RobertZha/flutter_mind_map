import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/line_link.dart';
import 'package:flutter_mind_map/link/oblique_broken_line.dart';
import 'package:flutter_mind_map/link/poly_line_link.dart';
import 'package:flutter_mind_map/link/arc_line_linek.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:flutter_mind_map/mind_map_node.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CustomPage extends StatefulWidget {
  CustomPage({super.key});

  SharedPreferences? prefs;
  Future<void> init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        if (prefs!.containsKey("Custom")) {
          String str = prefs!.getString("Custom")!;
          try {
            Map<String, dynamic> map = jsonDecode(str);
            mindMap.fromJson(map);
          } catch (e) {
            debugPrint(e.toString());
          }
        } else {
          mindMap.getRootNode().getLeftItems().clear();
          mindMap.getRootNode().getRightItems().clear();
          mindMap.getRootNode().setTitle("OS Types");
          (mindMap.getRootNode() as MindMapNode).setBackgroundColor(
            Colors.white,
          );
          mindMap.getRootNode().setLinkColor(Colors.blue);
          (mindMap.getRootNode() as MindMapNode).setLinkOutPadding(-50);
          // (mindMap.getRootNode() as MindMapNode).

          (mindMap.getRootNode() as MindMapNode).setBorderRadius(
            BorderRadiusGeometry.circular(100),
          );
          (mindMap.getRootNode() as MindMapNode).setPadding(
            EdgeInsets.fromLTRB(30, 6, 30, 6),
          );

          MindMapNode node1 = MindMapNode();
          node1.setTitle("By Domain");
          node1.setBackgroundColor(Colors.yellow);
          node1.setTextStyle(TextStyle(fontSize: 12.0, color: Colors.black));
          node1.setLink(ArcLineLink());
          node1.setLinkOutPadding(-15);
          mindMap.getRootNode().addLeftItem(node1);

          MindMapNode node11 = MindMapNode();
          node11.setTitle("Desktop");
          node11.setBackgroundColor(Colors.white);
          node11.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node11.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node11);

          MindMapNode node12 = MindMapNode();
          node12.setTitle("Server");
          node12.setBackgroundColor(Colors.white);
          node12.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node12.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node12);

          MindMapNode node13 = MindMapNode();
          node13.setTitle("Mobile");
          node13.setBackgroundColor(Colors.white);
          node13.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node13.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node13);

          MindMapNode node14 = MindMapNode();
          node14.setTitle("Enbedded");
          node14.setBackgroundColor(Colors.white);
          node14.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node14.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node14);

          MindMapNode node15 = MindMapNode();
          node15.setTitle("Hypervisor");
          node15.setBackgroundColor(Colors.white);
          node15.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node15.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node15);

          MindMapNode node2 = MindMapNode();
          node2.setTitle("By User");
          node2.setBackgroundColor(Colors.yellow);
          node2.setTextStyle(TextStyle(fontSize: 12.0, color: Colors.black));
          node2.setLink(LineLink());
          mindMap.getRootNode().addLeftItem(node2);

          MindMapNode node21 = MindMapNode();
          node21.setTitle("Single-User");
          node21.setBackgroundColor(Colors.white);
          node21.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node21.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node2.addLeftItem(node21);

          MindMapNode node22 = MindMapNode();
          node22.setTitle("Multi-User");
          node22.setBackgroundColor(Colors.white);
          node22.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node22.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node2.addLeftItem(node22);

          MindMapNode node3 = MindMapNode();
          node3.setTitle("By License");
          node3.setTextStyle(
            TextStyle(
              fontSize: 12.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
          node3.setBorder(
            BoxBorder.fromLTRB(
              bottom: BorderSide(
                color: Colors.black,
                width: 2.0,
                style: BorderStyle.solid,
              ),
            ),
          );
          node3.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node3.setBorderRadius(BorderRadius.circular(0));
          node3.setLinkColor(Colors.deepOrange);
          //node3.setLinkInOffsetMode(MindMapNodeLinkOffsetMode.bottom);
          //node3.setLinkOutOffsetMode(MindMapNodeLinkOffsetMode.bottom);
          mindMap.getRootNode().addLeftItem(node3);

          MindMapNode node31 = MindMapNode();
          node31.setTitle("Proprietary");
          node31.setBackgroundColor(Colors.white);
          node31.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node31.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node3.addLeftItem(node31);

          MindMapNode node32 = MindMapNode();
          node32.setTitle("Open Source");
          node32.setBackgroundColor(Colors.white);
          node32.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node32.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node3.addLeftItem(node32);

          MindMapNode node4 = MindMapNode();
          node4.setBackgroundColor(Colors.white);
          node4.setLinkColor(Colors.red);
          //node4.setLinkInOffsetMode(MindMapNodeLinkOffsetMode.top);
          //node4.setLinkOutOffsetMode(MindMapNodeLinkOffsetMode.bottom);
          node4.setBorderRadius(BorderRadiusGeometry.circular(5));
          node4.setTitle("By Kernel");
          node4.setLink(PolyLineLink());
          mindMap.getRootNode().addRightItem(node4);

          MindMapNode node41 = MindMapNode();
          node41.setTitle("Monolithic");
          node4.addRightItem(node41);
          MindMapNode node42 = MindMapNode();
          node42.setTitle("Microkernel");
          node4.addRightItem(node42);
          MindMapNode node43 = MindMapNode();
          node43.setTitle("Hybrid");
          node4.addRightItem(node43);
          MindMapNode node44 = MindMapNode();
          node44.setTitle("Exokernel");
          node4.addRightItem(node44);

          MindMapNode node5 = MindMapNode();
          node5.setTitle("By Time");
          node5.setBackgroundColor(Colors.white);
          node5.setLinkColor(Colors.cyan);
          node5.setLink(ObliqueBrokenLine());
          node5.setLinkOutOffsetMode(MindMapNodeLinkOffsetMode.center);

          node5.setBorder(
            BoxBorder.all(
              color: Colors.cyan,
              width: 2.0,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          );
          node5.setChild(
            Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 16,
                  color: Colors.cyan,
                ),
                SizedBox(width: 10),
                Text(
                  node5.getTitle(),
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          );
          mindMap.getRootNode().addRightItem(node5);

          MindMapNode node51 = MindMapNode();
          node51.setTitle("Time-Sharing");
          node51.setExtended("value");
          node51.setLinkInOffsetMode(MindMapNodeLinkOffsetMode.center);
          node5.addRightItem(node51);
          MindMapNode node52 = MindMapNode();
          node52.setTitle("Real-Time");
          node52.setExtended("value");
          node52.setLinkInOffsetMode(MindMapNodeLinkOffsetMode.center);
          node5.addRightItem(node52);

          mindMap.onChanged();
          mindMap.setZoom(0.7);
          mindMap.setMoveOffset(Offset.zero);
        }

        mindMap.addOnChangedListeners(onChanged);

        mindMap.setCanMove(true);
      }
    }
    mindMap.setHasTextField(false);
    mindMap.setHasEditButton(true);
    mindMap.setShowRecycle(false);
    mindMap.setExpandedLevel(3);
    mindMap.setEnabledExtendedClick(true);
    mindMap.setEnabledDoubleTapShowTextField(true);
    //add Json Theme
    /*
    Map<String, dynamic> json = {
      "0": {
        "BackgroundColor": "##FFFFFF",
        "TextColor": "#FF000000",
        "FontSize": 18.0,
        "Bold": true,
        "LinkColor": "#FF7C4DFF",
        "LinkWidth": 2,
        "Border": {"color": "#FF7C4DFF", "width": 2},
        "BorderRadius": 8,
        "Padding": {"left": 30, "top": 10, "right": 30, "bottom": 10},
        "Link": "BeerseLineLink",
      },
      "1": {
        "BackgroundColor": "#00000000",
        "TextColor": "#FF000000",
        "FontSize": 16.0,
        "Border": {"color": "#00000000", "width": "0,0,0,2"},
        "BorderRadius": 0,
        "Padding": {"left": 20, "top": 3, "right": 20, "bottom": 3},
        "LinkInOffsetMode": "bottom",
        "LinkOutOffsetMode": "bottom",
        "LinkWidth": 2,
        "LinkColors": [
          "#FF6A48C2",
          "#FFDA2892",
          "#FF0072BE",
          "#FF007078",
          "#FFB12BB6",
          "#FF00A2F1",
          "#FF1CB0A8",
          "#FFFD3C42",
          "#FFFA485E",
          "#FF74B633",
          "#FF1E4EBF",
          "#FFFAB02A",
          "#FFF68015",
          "#FF79B83D",
        ],
        "BorderColors": [
          "#FF6A48C2",
          "#FFDA2892",
          "#FF0072BE",
          "#FF007078",
          "#FFB12BB6",
          "#FF00A2F1",
          "#FF1CB0A8",
          "#FFFD3C42",
          "#FFFA485E",
          "#FF74B633",
          "#FF1E4EBF",
          "#FFFAB02A",
          "#FFF68015",
          "#FF79B83D",
        ],
      },
      "2": {
        "BackgroundColor": "#00000000",
        "TextColor": "#FF000000",
        "FontSize": 14.0,
        "Padding": {"left": 12, "top": 3, "right": 12, "bottom": 3},
      },
    };
    JsonTheme jsonTheme = JsonTheme("Json Theme", json);
    String s = jsonEncode(json);
    print("------------------------------------------");
    print(s);
    print("------------------------------------------");
    mindMap.setTheme(jsonTheme);
    */
  }

  void onChanged() {
    Map<String, dynamic> json = mindMap.toJson();
    String str = jsonEncode(json);
    if (prefs != null) {
      prefs!.setString("Custom", str);
    }
  }

  MindMap mindMap = MindMap();

  @override
  State<StatefulWidget> createState() => CustomPageState();
}

class CustomPageState extends State<CustomPage> {
  @override
  void initState() {
    super.initState();
    widget.init();
    widget.mindMap.addOnDoubleTapListeners(onDoubleTap);
    widget.mindMap.addOnEditListeners(onEditTap);
  }

  @override
  void dispose() {
    widget.mindMap.removeOnEditListeners(onEditTap);
    widget.mindMap.removeOnDoubleTapListeners(onDoubleTap);
    super.dispose();
  }

  TextEditingController controller = TextEditingController();
  void onEditTap(IMindMapNode node) {
    if (!widget.mindMap.getReadOnly()) {
      controller.text = node.getTitle();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Node Name:"),
            content: Container(child: TextField(controller: controller)),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  node.setTitle(controller.text);
                  node.refresh();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void onDoubleTap(IMindMapNode node) async {
    if (!widget.mindMap.getReadOnly()) {
      if (node is MindMapNode) {
        FilePickerResult? filename = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (filename != null) {
          File file = File(filename.files.single.path!);
          Uint8List bytes = await file.readAsBytes();
          String base64 = base64Encode(bytes);
          node.setImage(base64);
          print(base64);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: widget.mindMap);
  }
}
