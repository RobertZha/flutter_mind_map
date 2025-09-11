import 'package:flutter/material.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:flutter_mind_map/mind_map_node.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_compact.dart';

// ignore: must_be_immutable
class ThemePage extends StatefulWidget {
  ThemePage({super.key}) {
    //mindMap.setReadOnly(true);

    mindMap.setTheme(MindMapThemeCompact());
    mindMap.getRootNode().setTitle("Root Node");

    MindMapNode node1 = MindMapNode();
    node1.setTitle("Node 1");
    mindMap.getRootNode().addLeftItem(node1);

    MindMapNode node11 = MindMapNode();
    node11.setTitle("Node 11");
    node1.addLeftItem(node11);

    MindMapNode node111 = MindMapNode();
    node111.setTitle("Node 111");
    node11.addLeftItem(node111);

    MindMapNode node112 = MindMapNode();
    node112.setTitle("Node 112");
    node11.addLeftItem(node112);

    MindMapNode node12 = MindMapNode();
    node12.setTitle("Node 12");
    node1.addLeftItem(node12);

    MindMapNode node2 = MindMapNode();
    node2.setTitle("Node 2");
    mindMap.getRootNode().addLeftItem(node2);
    MindMapNode node3 = MindMapNode();
    node3.setTitle("Node 3");
    mindMap.getRootNode().addLeftItem(node3);

    MindMapNode node4 = MindMapNode();
    node4.setTitle("Node 4");
    mindMap.getRootNode().addRightItem(node4);

    MindMapNode node5 = MindMapNode();
    node5.setTitle("Node 5");
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

  MindMap mindMap = MindMap();

  @override
  State<StatefulWidget> createState() => ThemePageState();
}

class ThemePageState extends State<ThemePage> {
  @override
  void initState() {
    super.initState();
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
