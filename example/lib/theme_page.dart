import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:flutter_mind_map/theme/i_mind_map_theme.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_compact.dart';
import 'package:flutter_mind_map_example/my_theme.dart';
import 'package:flutter_mind_map_example/my_theme1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ThemePage extends StatefulWidget {
  ThemePage({super.key}) {
    //add MyTheme
    mindMap.registerThemeAdapter(MyThemeAdapter());
    mindMap.registerThemeAdapter(MyTheme1Adapter());
    mindMap.setTheme(MindMapThemeCompact());
  }

  SharedPreferences? prefs;
  Future<void> init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        if (prefs!.containsKey("Theme")) {
          String str = prefs!.getString("Theme")!;
          try {
            Map<String, dynamic> map = jsonDecode(str);
            mindMap.fromJson(map);
          } catch (e) {
            debugPrint(e.toString());
          }
        } else {
          Map<String, dynamic> json = {
            "id": "human_origins",
            "content": "Human Origins",
            "nodes": [
              {
                "id": "basic_concepts",
                "content": "Fundamental Concepts",
                "nodes": [
                  {
                    "id": "definition",
                    "content":
                        "Definition: Evolutionary process leading to modern humans (Homo sapiens)",
                    "nodes": [],
                  },
                  {
                    "id": "core_questions",
                    "content":
                        "Core Questions: Where did we come from? How did we evolve?",
                    "nodes": [],
                  },
                  {
                    "id": "research_fields",
                    "content": "Interdisciplinary Fields of Study",
                    "nodes": [
                      {
                        "id": "paleoanthropology",
                        "content": "Paleoanthropology",
                        "nodes": [],
                      },
                      {
                        "id": "archaeology",
                        "content": "Archaeology",
                        "nodes": [],
                      },
                      {
                        "id": "genetics",
                        "content": "Genetics (DNA Analysis)",
                        "nodes": [],
                      },
                      {"id": "geology", "content": "Geology", "nodes": []},
                    ],
                  },
                ],
              },
              {
                "id": "evolutionary_timeline",
                "content": "Evolutionary Timeline (Key Stages)",
                "nodes": [
                  {
                    "id": "primate_ancestors",
                    "content": "Primate Ancestors",
                    "nodes": [
                      {
                        "id": "primate_time",
                        "content": "Time: ~65 million years ago",
                        "nodes": [],
                      },
                      {
                        "id": "primate_event",
                        "content":
                            "Event: Demise of dinosaurs, rise of mammals",
                        "nodes": [],
                      },
                      {
                        "id": "primate_example",
                        "content":
                            "Example: Purgatorius (oldest primate-like species)",
                        "nodes": [],
                      },
                    ],
                  },
                  {
                    "id": "hominin_divergence",
                    "content": "Hominin Divergence",
                    "nodes": [
                      {
                        "id": "divergence_time",
                        "content": "Time: ~7-6 million years ago",
                        "nodes": [],
                      },
                      {
                        "id": "divergence_event",
                        "content":
                            "Event: Evolutionary split from chimpanzee lineage",
                        "nodes": [],
                      },
                      {
                        "id": "divergence_example",
                        "content": "Example: Sahelanthropus tchadensis",
                        "nodes": [],
                      },
                    ],
                  },
                  {
                    "id": "australopithecus",
                    "content": "Australopithecus",
                    "nodes": [
                      {
                        "id": "australopithecus_time",
                        "content": "Time: ~4-2 million years ago",
                        "nodes": [],
                      },
                      {
                        "id": "australopithecus_trait",
                        "content":
                            "Key Trait: Obligate Bipedalism (walking upright)",
                        "nodes": [],
                      },
                      {
                        "id": "australopithecus_fossil",
                        "content":
                            "Famous Fossil: Lucy (Australopithecus afarensis)",
                        "nodes": [],
                      },
                    ],
                  },
                  {
                    "id": "genus_homo",
                    "content": "Emergence of Genus Homo",
                    "nodes": [
                      {
                        "id": "homo_habilis",
                        "content": "Homo habilis (Handy Man)",
                        "nodes": [
                          {
                            "id": "habilis_time",
                            "content": "Time: ~2.4-1.4 million years ago",
                            "nodes": [],
                          },
                          {
                            "id": "habilis_trait",
                            "content":
                                "Key Trait: First maker of stone tools (Oldowan tools)",
                            "nodes": [],
                          },
                        ],
                      },
                      {
                        "id": "homo_erectus",
                        "content": "Homo erectus (Upright Man)",
                        "nodes": [
                          {
                            "id": "erectus_time",
                            "content": "Time: ~1.9 million - 110,000 years ago",
                            "nodes": [],
                          },
                          {
                            "id": "erectus_traits",
                            "content":
                                "Key Traits: First to leave Africa, mastered fire use",
                            "nodes": [],
                          },
                          {
                            "id": "erectus_examples",
                            "content": "Examples: Peking Man, Java Man",
                            "nodes": [],
                          },
                        ],
                      },
                      {
                        "id": "homo_heidelbergensis",
                        "content": "Homo heidelbergensis",
                        "nodes": [
                          {
                            "id": "heidelbergensis_time",
                            "content": "Time: ~700,000-200,000 years ago",
                            "nodes": [],
                          },
                          {
                            "id": "heidelbergensis_significance",
                            "content":
                                "Significance: Common ancestor of Neanderthals and modern humans",
                            "nodes": [],
                          },
                        ],
                      },
                    ],
                  },
                  {
                    "id": "homo_sapiens",
                    "content": "Rise of Homo sapiens",
                    "nodes": [
                      {
                        "id": "archaic_sapiens",
                        "content": "Early Homo sapiens",
                        "nodes": [
                          {
                            "id": "archaic_time",
                            "content": "Time: ~300,000 years ago",
                            "nodes": [],
                          },
                          {
                            "id": "archaic_location",
                            "content": "Location: Africa",
                            "nodes": [],
                          },
                          {
                            "id": "archaic_evidence",
                            "content":
                                "Evidence: Jebel Irhoud fossils (Morocco)",
                            "nodes": [],
                          },
                        ],
                      },
                      {
                        "id": "other_hominins",
                        "content": "Other Hominins",
                        "nodes": [
                          {
                            "id": "neanderthals",
                            "content":
                                "Neanderthals: Europe/W. Asia, adapted to cold",
                            "nodes": [],
                          },
                          {
                            "id": "denisovans",
                            "content":
                                "Denisovans: Asia, known from DNA evidence",
                            "nodes": [],
                          },
                        ],
                      },
                      {
                        "id": "out_of_africa",
                        "content": "Out of Africa Model",
                        "nodes": [
                          {
                            "id": "migration_time",
                            "content": "Time: ~70-50,000 years ago",
                            "nodes": [],
                          },
                          {
                            "id": "migration_path",
                            "content": "Path: Migrated from Africa globally",
                            "nodes": [],
                          },
                        ],
                      },
                      {
                        "id": "behavioral_modernity",
                        "content": "Behavioral Modernity",
                        "nodes": [
                          {
                            "id": "modernity_evidence",
                            "content":
                                "Evidence: Cave art, jewelry, complex tools, language",
                            "nodes": [],
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
              {
                "id": "key_drivers",
                "content": "Key Evolutionary Drivers",
                "nodes": [
                  {
                    "id": "environment",
                    "content":
                        "Environmental Change: Climate shifts, savanna expansion",
                    "nodes": [],
                  },
                  {
                    "id": "tools",
                    "content":
                        "Tool Technology: Stone tools to complex implements",
                    "nodes": [],
                  },
                  {
                    "id": "fire",
                    "content": "Control of Fire: Cooking, protection, warmth",
                    "nodes": [],
                  },
                  {
                    "id": "brain",
                    "content":
                        "Encephalization: Brain size increase, higher cognition",
                    "nodes": [],
                  },
                  {
                    "id": "social",
                    "content":
                        "Social Cooperation: Complex structures, language, culture",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "theories_debates",
                "content": "Major Theories & Debates",
                "nodes": [
                  {
                    "id": "origin_models",
                    "content": "Modern Human Origin Models",
                    "nodes": [
                      {
                        "id": "out_of_africa_model",
                        "content": "Out of Africa (Replacement Model)",
                        "nodes": [],
                      },
                      {
                        "id": "multiregional",
                        "content": "Multiregional Evolution Model",
                        "nodes": [],
                      },
                      {
                        "id": "assimilation",
                        "content": "Assimilation Model",
                        "nodes": [],
                      },
                    ],
                  },
                  {
                    "id": "interbreeding",
                    "content": "Interbreeding Evidence",
                    "nodes": [
                      {
                        "id": "neanderthal_dna",
                        "content": "Non-Africans: ~1-4% Neanderthal DNA",
                        "nodes": [],
                      },
                      {
                        "id": "denisovan_dna",
                        "content": "Melanesians: ~4-6% Denisovan DNA",
                        "nodes": [],
                      },
                    ],
                  },
                ],
              },
              {
                "id": "unsolved_mysteries",
                "content": "Unsolved Mysteries & Future Research",
                "nodes": [
                  {
                    "id": "common_ancestor",
                    "content": "Last common ancestor with chimps?",
                    "nodes": [],
                  },
                  {
                    "id": "language_origin",
                    "content": "When and how did language emerge?",
                    "nodes": [],
                  },
                  {
                    "id": "behavioral_leap",
                    "content": "Trigger for behavioral modernity?",
                    "nodes": [],
                  },
                  {
                    "id": "unknown_species",
                    "content": "Undiscovered hominin species?",
                    "nodes": [],
                  },
                  {
                    "id": "extinction_cause",
                    "content": "Exact cause of Neanderthal extinction?",
                    "nodes": [],
                  },
                ],
              },
            ],
          };

          mindMap.loadData(json);
          /*mindMap.getRootNode().setTitle("Root Node");

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
          node4.addRightItem(node44);*/
        }

        mindMap.addOnChangedListeners(onChanged);
      }
    }
  }

  void onChanged() {
    Map<String, dynamic> json = mindMap.toJson();
    String str = jsonEncode(json);
    if (prefs != null) {
      prefs!.setString("Theme", str);
    }
  }

  MindMap mindMap = MindMap();

  @override
  State<StatefulWidget> createState() => ThemePageState();
}

class ThemePageState extends State<ThemePage> {
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
            content: TextField(controller: controller),
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
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.cyanAccent,
          child: Wrap(
            children: widget.mindMap
                .getThemeAdapter()
                .map(
                  (value) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: value.getName(),
                        groupValue: widget.mindMap.getTheme()?.getName(),
                        onChanged: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value != widget.mindMap.getTheme()?.getName()) {
                            IMindMapTheme? theme = widget.mindMap.createTheme(
                              value,
                            );
                            if (theme != null) {
                              setState(() {
                                widget.mindMap.setTheme(theme);
                              });
                            }
                          }
                        },
                      ),
                      Text(value.getName()),
                      SizedBox(width: 16),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: Container(color: Colors.white, child: widget.mindMap),
        ),
      ],
    );
  }
}
