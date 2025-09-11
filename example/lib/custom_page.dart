import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/poly_line_link.dart';
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
          mindMap.getRootNode().setTitle("Root Node");
          mindMap.getRootNode().setLinkColor(Colors.blue);

          (mindMap.getRootNode() as MindMapNode).setBorderRadius(
            BorderRadiusGeometry.circular(100),
          );
          (mindMap.getRootNode() as MindMapNode).setPadding(
            EdgeInsets.fromLTRB(30, 6, 30, 6),
          );

          MindMapNode node1 = MindMapNode();
          node1.setTitle("Node 1");
          node1.setBackgroundColor(Colors.yellow);
          node1.setTextStyle(TextStyle(fontSize: 12.0, color: Colors.black));
          mindMap.getRootNode().addLeftItem(node1);

          MindMapNode node11 = MindMapNode();
          node11.setTitle("Node 11");
          node11.setBackgroundColor(Colors.white);
          node11.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node11.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node11);

          MindMapNode node12 = MindMapNode();
          node12.setTitle("Node 12");
          node12.setBackgroundColor(Colors.white);
          node12.setTextStyle(TextStyle(fontSize: 10.0, color: Colors.black));
          node12.setPadding(EdgeInsets.fromLTRB(20, 2, 20, 2));
          node1.addLeftItem(node12);

          MindMapNode node2 = MindMapNode();
          node2.setTitle("Node 2");
          node2.setBackgroundColor(Colors.yellow);
          node2.setTextStyle(TextStyle(fontSize: 12.0, color: Colors.black));
          mindMap.getRootNode().addLeftItem(node2);

          MindMapNode node3 = MindMapNode();
          node3.setTitle("Node 3");
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
          node3.setLinkInOffsetMode(MindMapNodeLinkOffsetMode.bottom);
          node3.setLinkOutOffsetMode(MindMapNodeLinkOffsetMode.bottom);
          mindMap.getRootNode().addLeftItem(node3);

          MindMapNode node4 = MindMapNode();
          node4.setLinkColor(Colors.red);
          node4.setLinkInOffsetMode(MindMapNodeLinkOffsetMode.top);
          node4.setLinkOutOffsetMode(MindMapNodeLinkOffsetMode.bottom);
          node4.setBorderRadius(BorderRadiusGeometry.circular(5));
          node4.setTitle("Node 4");
          node4.setLink(PolyLineLink());
          mindMap.getRootNode().addRightItem(node4);

          MindMapNode node5 = MindMapNode();
          node5.setTitle("Node 5");
          node5.setLinkColor(Colors.cyan);
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

          MindMapNode node41 = MindMapNode();
          node41.setTitle("Node 41");
          node4.addRightItem(node41);
          MindMapNode node42 = MindMapNode();
          node42.setTitle("Node 42");
          node4.addRightItem(node42);
          MindMapNode node43 = MindMapNode();
          node43.setTitle("Node 43");
          node4.addRightItem(node43);
          MindMapNode node44 = MindMapNode();
          node44.setTitle("Node 44");
          node4.addRightItem(node44);
        }

        mindMap.addOnChangedListeners(onChanged);
      }
    }
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
  }

  @override
  void dispose() {
    widget.mindMap.removeOnDoubleTapListeners(onDoubleTap);
    super.dispose();
  }

  TextEditingController controller = TextEditingController();
  void onDoubleTap(IMindMapNode node) {
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

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: widget.mindMap);
  }
}
