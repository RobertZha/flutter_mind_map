import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
import 'package:flutter_mind_map/theme/json_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class FishbonePage extends StatefulWidget {
  FishbonePage({super.key});

  SharedPreferences? prefs;
  Future<void> init() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        if (prefs!.containsKey("Fishbone")) {
          String str = prefs!.getString("Fishbone")!;
          try {
            Map<String, dynamic> map = jsonDecode(str);
            mindMap.fromJson(map);
          } catch (e) {
            debugPrint(e.toString());
          }
        } else {
          /*
          var json = {
            "id": "fishbone_root",
            "content": "手机电池续航时间短",
            "nodes": [
              {
                "id": "category_1",
                "content": "人员（用户习惯）",
                "nodes": [
                  {
                    "id": "person_1",
                    "content": "长时间玩大型游戏（>2小时/天）",
                    "nodes": [],
                  },
                  {"id": "person_2", "content": "频繁使用GPS导航", "nodes": []},
                  {"id": "person_3", "content": "后台同时运行10+个应用程序", "nodes": []},
                  {"id": "person_4", "content": "屏幕亮度常设为100%", "nodes": []},
                  {"id": "person_5", "content": "未启用省电模式", "nodes": []},
                ],
              },
              {
                "id": "category_2",
                "content": "方法（使用方式）",
                "nodes": [
                  {"id": "method_1", "content": "边充电边使用手机", "nodes": []},
                  {"id": "method_2", "content": "经常在信号弱区域使用", "nodes": []},
                  {
                    "id": "method_3",
                    "content": "从不重启设备（连续运行30天+）",
                    "nodes": [],
                  },
                  {"id": "method_4", "content": "使用非原装充电器充电", "nodes": []},
                  {
                    "id": "method_5",
                    "content": "充电至100%后仍长时间连接电源",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_3",
                "content": "机器（硬件相关）",
                "nodes": [
                  {
                    "id": "machine_1",
                    "content": "电池已使用2年（500次循环）",
                    "nodes": [],
                  },
                  {"id": "machine_2", "content": "电池容量衰减至原容量的75%", "nodes": []},
                  {"id": "machine_3", "content": "主板存在轻微漏电", "nodes": []},
                  {"id": "machine_4", "content": "充电接口接触不良", "nodes": []},
                  {"id": "machine_5", "content": "屏幕老化导致功耗增加20%", "nodes": []},
                ],
              },
              {
                "id": "category_4",
                "content": "材料（电池本身）",
                "nodes": [
                  {"id": "material_1", "content": "锂离子电池自然老化", "nodes": []},
                  {"id": "material_2", "content": "电池化学物质活性下降", "nodes": []},
                  {"id": "material_3", "content": "电极材料降解", "nodes": []},
                  {"id": "material_4", "content": "电解质分解", "nodes": []},
                  {"id": "material_5", "content": "隔膜性能下降", "nodes": []},
                ],
              },
              {
                "id": "category_5",
                "content": "环境因素",
                "nodes": [
                  {
                    "id": "environment_1",
                    "content": "经常在高温环境使用（>35°C）",
                    "nodes": [],
                  },
                  {
                    "id": "environment_2",
                    "content": "低温环境下频繁使用（<0°C）",
                    "nodes": [],
                  },
                  {"id": "environment_3", "content": "长期处于潮湿环境", "nodes": []},
                  {"id": "environment_4", "content": "经常暴露于阳光直射", "nodes": []},
                  {
                    "id": "environment_5",
                    "content": "使用环境灰尘多，散热不良",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_6",
                "content": "测量（评估方式）",
                "nodes": [
                  {
                    "id": "measurement_1",
                    "content": "电池健康度检测工具误差±5%",
                    "nodes": [],
                  },
                  {
                    "id": "measurement_2",
                    "content": "续航测试时网络环境不一致",
                    "nodes": [],
                  },
                  {
                    "id": "measurement_3",
                    "content": "不同应用耗电量测量标准不统一",
                    "nodes": [],
                  },
                  {"id": "measurement_4", "content": "系统电池统计延迟更新", "nodes": []},
                  {
                    "id": "measurement_5",
                    "content": "用户主观感受与实际数据偏差",
                    "nodes": [],
                  },
                ],
              },
            ],
          };
*/

          final json = {
            "id": "fishbone_root",
            "content": "Short Battery Life in Smartphones",
            "nodes": [
              {
                "id": "category_1",
                "content": "People (User Habits)",
                "nodes": [
                  {
                    "id": "person_1",
                    "content":
                        "Playing resource-intensive games for extended periods (>2 hours/day)",
                    "nodes": [],
                  },
                  {
                    "id": "person_2",
                    "content": "Frequent use of GPS navigation",
                    "nodes": [],
                  },
                  {
                    "id": "person_3",
                    "content":
                        "Running 10+ applications simultaneously in the background",
                    "nodes": [],
                  },
                  {
                    "id": "person_4",
                    "content": "Screen brightness consistently set to 100%",
                    "nodes": [],
                  },
                  {
                    "id": "person_5",
                    "content": "Power saving mode never enabled",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_2",
                "content": "Methods (Usage Patterns)",
                "nodes": [
                  {
                    "id": "method_1",
                    "content": "Using phone while charging",
                    "nodes": [],
                  },
                  {
                    "id": "method_2",
                    "content": "Regular usage in areas with weak signal",
                    "nodes": [],
                  },
                  {
                    "id": "method_3",
                    "content":
                        "Never rebooting device (running continuously for 30+ days)",
                    "nodes": [],
                  },
                  {
                    "id": "method_4",
                    "content": "Using non-OEM chargers",
                    "nodes": [],
                  },
                  {
                    "id": "method_5",
                    "content":
                        "Leaving phone plugged in after reaching 100% charge",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_3",
                "content": "Machines (Hardware Related)",
                "nodes": [
                  {
                    "id": "machine_1",
                    "content": "Battery used for 2 years (500 charge cycles)",
                    "nodes": [],
                  },
                  {
                    "id": "machine_2",
                    "content": "Battery capacity degraded to 75% of original",
                    "nodes": [],
                  },
                  {
                    "id": "machine_3",
                    "content": "Motherboard has minor power leakage",
                    "nodes": [],
                  },
                  {
                    "id": "machine_4",
                    "content": "Charging port has poor connection",
                    "nodes": [],
                  },
                  {
                    "id": "machine_5",
                    "content":
                        "Screen aging increases power consumption by 20%",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_4",
                "content": "Materials (Battery Itself)",
                "nodes": [
                  {
                    "id": "material_1",
                    "content": "Natural aging of lithium-ion battery",
                    "nodes": [],
                  },
                  {
                    "id": "material_2",
                    "content": "Degradation of battery chemical activity",
                    "nodes": [],
                  },
                  {
                    "id": "material_3",
                    "content": "Electrode material degradation",
                    "nodes": [],
                  },
                  {
                    "id": "material_4",
                    "content": "Electrolyte decomposition",
                    "nodes": [],
                  },
                  {
                    "id": "material_5",
                    "content": "Separator performance decline",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_5",
                "content": "Environment",
                "nodes": [
                  {
                    "id": "environment_1",
                    "content":
                        "Frequent use in high temperature environments (>35°C)",
                    "nodes": [],
                  },
                  {
                    "id": "environment_2",
                    "content": "Regular usage in cold conditions (<0°C)",
                    "nodes": [],
                  },
                  {
                    "id": "environment_3",
                    "content": "Prolonged exposure to humid environments",
                    "nodes": [],
                  },
                  {
                    "id": "environment_4",
                    "content": "Regular exposure to direct sunlight",
                    "nodes": [],
                  },
                  {
                    "id": "environment_5",
                    "content":
                        "Dusty usage environment causing poor heat dissipation",
                    "nodes": [],
                  },
                ],
              },
              {
                "id": "category_6",
                "content": "Measurement (Evaluation Methods)",
                "nodes": [
                  {
                    "id": "measurement_1",
                    "content": "Battery health detection tool error ±5%",
                    "nodes": [],
                  },
                  {
                    "id": "measurement_2",
                    "content":
                        "Inconsistent network conditions during battery life testing",
                    "nodes": [],
                  },
                  {
                    "id": "measurement_3",
                    "content":
                        "Non-standardized measurement of app power consumption",
                    "nodes": [],
                  },
                  {
                    "id": "measurement_4",
                    "content": "Delayed system battery statistics updates",
                    "nodes": [],
                  },
                  {
                    "id": "measurement_5",
                    "content":
                        "Discrepancy between user perception and actual data",
                    "nodes": [],
                  },
                ],
              },
            ],
          };
          mindMap.loadData(json);

          final template = {
            "0": {
              "BackgroundColor": "#FF7C4DFF",
              "TextColor": "#FFFFFFFF",
              "FontSize": 24.0,
              "Bold": true,
              "LinkColor": "#FF7C4DFF",
              "LinkWidth": 10,
              "Border": {"color": "#FF7C4DFF", "width": 2},
              "BorderRadius": 100,
              "Padding": {"left": 30, "top": 12, "right": 30, "bottom": 12},
              "VSpace": 30,
              "HSpace": 100,
            },
            "1": {
              "BackgroundColor": "#00000000",
              "HSpace": 50,
              "TextColor": "#FFFFFFFF",
              "FontSize": 18.0,
              "Border": {"color": "#00000000", "width": "0,0,0,1"},
              "BorderRadius": 8,
              "Padding": {"left": 20, "top": 8, "right": 20, "bottom": 8},
              "LinkWidth": 3,
              "LinkColors": [
                "#FF448AFF",
                "#FF4CAF50",
                "#FFFF6E40",
                "#FF00BCD4",
                "#FF795548",
                "#FFFF5252",
                "#FF7C4DFF",
              ],
              "BorderColors": [
                "#FF448AFF",
                "#FF4CAF50",
                "#FFFF6E40",
                "#FF00BCD4",
                "#FF795548",
                "#FFFF5252",
                "#FF7C4DFF",
              ],
              "BackgroundColors": [
                "#FF448AFF",
                "#FF4CAF50",
                "#FFFF6E40",
                "#FF00BCD4",
                "#FF795548",
                "#FFFF5252",
                "#FF7C4DFF",
              ],
            },
            "2": {
              "HSpace": 48,
              "BackgroundColor": "#00000000",
              "TextColor": "#FF000000",
              "FontSize": 14.0,
              "BorderRadius": 0,
              "LinkInOffsetMode": "bottom",
              "LinkWidth": 2.0,
              "VSpace": 10,
              "Padding": {"left": 12, "top": 6, "right": 12, "bottom": 6},
            },
            "3": {
              "BackgroundColor": "#00000000",
              "TextColor": "#FF000000",
              "FontSize": 11.0,
              "Border": {"color": "#00000000", "width": 0},
              "BorderRadius": 0,
              "LinkInOffsetMode": "center",
              "LinkWidth": 2.0,
              "Padding": {"left": 6, "top": 3, "right": 6, "bottom": 3},
            },
          };
          JsonTheme theme = JsonTheme("Fishbone", template);
          mindMap.setTheme(theme);
          mindMap.setMoveOffset(Offset.zero);
          mindMap.setZoom(0.2);
          mindMap.onChanged();
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
    mindMap.setMapType(MapType.fishbone);
    mindMap.setFishboneMapType(FishboneMapType.rightToLeft);
  }

  void onChanged() {
    Map<String, dynamic> json = mindMap.toJson();
    String str = jsonEncode(json);
    if (prefs != null) {
      prefs!.setString("Fishbone", str);
    }
  }

  MindMap mindMap = MindMap();

  @override
  State<StatefulWidget> createState() => FishbonePageState();
}

class FishbonePageState extends State<FishbonePage> {
  @override
  void initState() {
    super.initState();
    widget.init();
    widget.mindMap.addOnEditListeners(onEditTap);
  }

  @override
  void dispose() {
    widget.mindMap.removeOnEditListeners(onEditTap);
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

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: widget.mindMap);
  }
}
