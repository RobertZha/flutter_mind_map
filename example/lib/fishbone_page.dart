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

          mindMap.setMoveOffset(Offset.zero);
          mindMap.setZoom(0.2);
          mindMap.onChanged();
        }

        mindMap.addOnChangedListeners(onChanged);

        mindMap.setCanMove(true);
      }
    }

    final template = {
      "0": {
        "BackgroundColor": "#00000000",
        "TextColor": "#FF000000",
        "FontSize": 24.0,
        "Bold": true,
        "LinkColor": "#FF000000",
        "LinkWidth": 10,
        "Border": {"color": "#00000000", "width": 0},
        "BorderRadius": 0,
        "Padding": {"left": 0, "top": 0, "right": 0, "bottom": 0},
        "VSpace": 30,
        "HSpace": 100,
        "Image":
            "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",
        "ImageWidth": 92,
        "ImageHeight": 122,
        "ImageSpace": 20,
        "Image2":
            "iVBORw0KGgoAAAANSUhEUgAAAEAAAABmCAYAAAB7nJf1AAAABGdBTUEAALGPC/xhBQAACklpQ0NQc1JHQiBJRUM2MTk2Ni0yLjEAAEiJnVN3WJP3Fj7f92UPVkLY8LGXbIEAIiOsCMgQWaIQkgBhhBASQMWFiApWFBURnEhVxILVCkidiOKgKLhnQYqIWotVXDjuH9yntX167+3t+9f7vOec5/zOec8PgBESJpHmomoAOVKFPDrYH49PSMTJvYACFUjgBCAQ5svCZwXFAADwA3l4fnSwP/wBr28AAgBw1S4kEsfh/4O6UCZXACCRAOAiEucLAZBSAMguVMgUAMgYALBTs2QKAJQAAGx5fEIiAKoNAOz0ST4FANipk9wXANiiHKkIAI0BAJkoRyQCQLsAYFWBUiwCwMIAoKxAIi4EwK4BgFm2MkcCgL0FAHaOWJAPQGAAgJlCLMwAIDgCAEMeE80DIEwDoDDSv+CpX3CFuEgBAMDLlc2XS9IzFLiV0Bp38vDg4iHiwmyxQmEXKRBmCeQinJebIxNI5wNMzgwAABr50cH+OD+Q5+bk4eZm52zv9MWi/mvwbyI+IfHf/ryMAgQAEE7P79pf5eXWA3DHAbB1v2upWwDaVgBo3/ldM9sJoFoK0Hr5i3k4/EAenqFQyDwdHAoLC+0lYqG9MOOLPv8z4W/gi372/EAe/tt68ABxmkCZrcCjg/1xYW52rlKO58sEQjFu9+cj/seFf/2OKdHiNLFcLBWK8ViJuFAiTcd5uVKRRCHJleIS6X8y8R+W/QmTdw0ArIZPwE62B7XLbMB+7gECiw5Y0nYAQH7zLYwaC5EAEGc0Mnn3AACTv/mPQCsBAM2XpOMAALzoGFyolBdMxggAAESggSqwQQcMwRSswA6cwR28wBcCYQZEQAwkwDwQQgbkgBwKoRiWQRlUwDrYBLWwAxqgEZrhELTBMTgN5+ASXIHrcBcGYBiewhi8hgkEQcgIE2EhOogRYo7YIs4IF5mOBCJhSDSSgKQg6YgUUSLFyHKkAqlCapFdSCPyLXIUOY1cQPqQ28ggMor8irxHMZSBslED1AJ1QLmoHxqKxqBz0XQ0D12AlqJr0Rq0Hj2AtqKn0UvodXQAfYqOY4DRMQ5mjNlhXIyHRWCJWBomxxZj5Vg1Vo81Yx1YN3YVG8CeYe8IJAKLgBPsCF6EEMJsgpCQR1hMWEOoJewjtBK6CFcJg4Qxwicik6hPtCV6EvnEeGI6sZBYRqwm7iEeIZ4lXicOE1+TSCQOyZLkTgohJZAySQtJa0jbSC2kU6Q+0hBpnEwm65Btyd7kCLKArCCXkbeQD5BPkvvJw+S3FDrFiOJMCaIkUqSUEko1ZT/lBKWfMkKZoKpRzame1AiqiDqfWkltoHZQL1OHqRM0dZolzZsWQ8ukLaPV0JppZ2n3aC/pdLoJ3YMeRZfQl9Jr6Afp5+mD9HcMDYYNg8dIYigZaxl7GacYtxkvmUymBdOXmchUMNcyG5lnmA+Yb1VYKvYqfBWRyhKVOpVWlX6V56pUVXNVP9V5qgtUq1UPq15WfaZGVbNQ46kJ1Bar1akdVbupNq7OUndSj1DPUV+jvl/9gvpjDbKGhUaghkijVGO3xhmNIRbGMmXxWELWclYD6yxrmE1iW7L57Ex2Bfsbdi97TFNDc6pmrGaRZp3mcc0BDsax4PA52ZxKziHODc57LQMtPy2x1mqtZq1+rTfaetq+2mLtcu0W7eva73VwnUCdLJ31Om0693UJuja6UbqFutt1z+o+02PreekJ9cr1Dund0Uf1bfSj9Rfq79bv0R83MDQINpAZbDE4Y/DMkGPoa5hpuNHwhOGoEctoupHEaKPRSaMnuCbuh2fjNXgXPmasbxxirDTeZdxrPGFiaTLbpMSkxeS+Kc2Ua5pmutG003TMzMgs3KzYrMnsjjnVnGueYb7ZvNv8jYWlRZzFSos2i8eW2pZ8ywWWTZb3rJhWPlZ5VvVW16xJ1lzrLOtt1ldsUBtXmwybOpvLtqitm63Edptt3xTiFI8p0in1U27aMez87ArsmuwG7Tn2YfYl9m32zx3MHBId1jt0O3xydHXMdmxwvOuk4TTDqcSpw+lXZxtnoXOd8zUXpkuQyxKXdpcXU22niqdun3rLleUa7rrStdP1o5u7m9yt2W3U3cw9xX2r+00umxvJXcM970H08PdY4nHM452nm6fC85DnL152Xlle+70eT7OcJp7WMG3I28Rb4L3Le2A6Pj1l+s7pAz7GPgKfep+Hvqa+It89viN+1n6Zfgf8nvs7+sv9j/i/4XnyFvFOBWABwQHlAb2BGoGzA2sDHwSZBKUHNQWNBbsGLww+FUIMCQ1ZH3KTb8AX8hv5YzPcZyya0RXKCJ0VWhv6MMwmTB7WEY6GzwjfEH5vpvlM6cy2CIjgR2yIuB9pGZkX+X0UKSoyqi7qUbRTdHF09yzWrORZ+2e9jvGPqYy5O9tqtnJ2Z6xqbFJsY+ybuIC4qriBeIf4RfGXEnQTJAntieTE2MQ9ieNzAudsmjOc5JpUlnRjruXcorkX5unOy553PFk1WZB8OIWYEpeyP+WDIEJQLxhP5aduTR0T8oSbhU9FvqKNolGxt7hKPJLmnVaV9jjdO31D+miGT0Z1xjMJT1IreZEZkrkj801WRNberM/ZcdktOZSclJyjUg1plrQr1zC3KLdPZisrkw3keeZtyhuTh8r35CP5c/PbFWyFTNGjtFKuUA4WTC+oK3hbGFt4uEi9SFrUM99m/ur5IwuCFny9kLBQuLCz2Lh4WfHgIr9FuxYji1MXdy4xXVK6ZHhp8NJ9y2jLspb9UOJYUlXyannc8o5Sg9KlpUMrglc0lamUycturvRauWMVYZVkVe9ql9VbVn8qF5VfrHCsqK74sEa45uJXTl/VfPV5bdra3kq3yu3rSOuk626s91m/r0q9akHV0IbwDa0b8Y3lG19tSt50oXpq9Y7NtM3KzQM1YTXtW8y2rNvyoTaj9nqdf13LVv2tq7e+2Sba1r/dd3vzDoMdFTve75TsvLUreFdrvUV99W7S7oLdjxpiG7q/5n7duEd3T8Wej3ulewf2Re/ranRvbNyvv7+yCW1SNo0eSDpw5ZuAb9qb7Zp3tXBaKg7CQeXBJ9+mfHvjUOihzsPcw83fmX+39QjrSHkr0jq/dawto22gPaG97+iMo50dXh1Hvrf/fu8x42N1xzWPV56gnSg98fnkgpPjp2Snnp1OPz3Umdx590z8mWtdUV29Z0PPnj8XdO5Mt1/3yfPe549d8Lxw9CL3Ytslt0utPa49R35w/eFIr1tv62X3y+1XPK509E3rO9Hv03/6asDVc9f41y5dn3m978bsG7duJt0cuCW69fh29u0XdwruTNxdeo94r/y+2v3qB/oP6n+0/rFlwG3g+GDAYM/DWQ/vDgmHnv6U/9OH4dJHzEfVI0YjjY+dHx8bDRq98mTOk+GnsqcTz8p+Vv9563Or59/94vtLz1j82PAL+YvPv655qfNy76uprzrHI8cfvM55PfGm/K3O233vuO+638e9H5ko/ED+UPPR+mPHp9BP9z7nfP78L/eE8/stRzjPAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAJcEhZcwAACxMAAAsTAQCanBgAAAdTSURBVHic3ZxpjFRFEMd/O+xBWGFdQQ4BDSqgkKgEEY0CghciXuCKGo0mYkgwSAQjRjkkJh4xBEkMIh9ExWBUCCgoSLwwBkIURUSQcKwgKngBhmuB3fFD7wuzjzczVd393sz6T+rbvPrXv2amX3d1dUNTjAJWAduBr4DpwLk0E6TTabVlYhaQjrB6YCHQPWE9argkYAzR4jPtGCZJbZMWJoVLAmrJn4DA9gETgNJk5eWHbQLOQC4+09YDlyesMSdsE9AJuwQE48Ns4PRElWaBbQI6YJ+AwH4H7kpUbQRsE9AK9wQEthzomqDmJnAZBI/jLwkHgNFASTKyT8IlAX8JhGltBQn/GlwSsMlSZFH9GlwS8HkM4sNjQ6diTECq8dm9Mcc2FNgA3BozjxpBAn5LgKsdsASYg3nzFAWCBGwXfv4XYI8j5xjgW6Cvox8vCBKwTfj5DUBvYL4jb09gDfAYBXhdRuE8ZIPZxoxnhgG7hM/lsveBah8iXN4CpZjlbr5gDwMtMjjbYP7TDY5JqAX6FTIBYH7ekmAvieAejBlHXJJQB4wrZALeEgb6cBb+1sDrjklIN8bR0iURtnhcGOCCPH5GAn8LfWWzNUBHb8qEuEEY3M8CX11xn13uAi7yIUwKTV2gi8BfCpgMnFD4Ddt+4Gp3aXLUCgMbpfB5DWaqbZuEo0CNmyw53hYGNUvp9yzgS6HvKKsHxtrLkmO8MKANFr5LgRexnzM0ABPtZMnRXxHQ2ZYcNcBBBU/YplnyilCOme1JAhntwNMH2CnkibLpDtx58akwiEWOPO1xGxeed+TPiinCAPYDZY5c5cBcIV+UzSSG1eQARQADPXGOx4z0Nkl4lZPLei8oBw4JyZ/zyFsDHBHyhm0Onn8JK4XE3/kkBa7EvkT/gs9AHhWSNmAmOT7RA1OhsknCk76CuEBB+qAv0gx0Ql6fCFu25boaO4SEH/oiDKEasyzWJqAeuNdHALOFhEeBKh+EEajEbLFpk3ACuMOVfJiC8G5XshyoABYrYgnsCDAkl+NwSSyK+ICQ7D0LYRqUYTZVtEnYD/QKO8tWE4zCAiHRIUxNME6UAx8I48m0HcCZgZNcRdEojFQQ3e9BZD5UYAZdbRJmSKrCUahEvjpc6U9nTlQAnwljOmWc0iYA4F0hwQkS2AJvRBX6eUI9cL5NAm5WkEzwo0+EzuhrCpuAEm0CypAXNdf50SZGL8xIr0nCPdoEQPY+4ig75bUTM0agqzPWAVXaBPRVEDzrQZQWMxTxpYG1QIUmAQA/CJ3vxHOBQoAyYLUwvsDGahMwUeF8kKMgG/RA/spOA5tputWfFx2RN1S+7KrGEhOE8QV2p5ZgqdDxbgrT+nIa8nJeGlil/a+uFX6uM3Cx0rcPPIOuA+1SLcF6ZJk9TvIt9Feg34mepyHop3D8iasaJVoDWxXxpTENX5UakjkK54ltZzdiviK2NGZvcp7mNdgK+ZRzN+47RhqMFsYVWB2N374mAfcpCKa4axJjAEaQ9tvvrZ0KS9ffx0huSdwN+EMYV6apl8PdkC82FnqRlh/tsDvjUAn6BDytILjWg7h8aAN8rYgp+GVeFjjQJCCFvHFqG/HP/lph11NwSmuNNAFDFCTTXJQJUIZdQXQJWb4YSQLmKYjiPFzdArP3oBW/CYdyfTnwj5BIukawQQnwmjCOTDuA2eS1xo0KskdciHIghekA0YpvAG5zJZdmvR7/PQJg+gqlHex5Bz0typB3fK92JYtAOaYLzUa8l5rkdQrCJ3wQZqASeYtO2Obi6VU8U0HqNNCEUIW5u8RG/EKUNb5c2CIk3eyLEDO9XSfkDdvHmD1DL+iuIPbVJncO8KOCN9OW4fmIzXgFeX8PfP0xFzDYiF+Kx28+wEdC8l9x3wAZhX1z5DvEUHgpBf4VBvCKA08JMBX7swPz8TjgZUJzXmCoJUdL7Cc4aUxtMratt0nCIOqwOwHeFnNVl6342FrkA0j//19Y+O6HOXJnI/w48XSkNkEKeVvcVKXvceiLl4EdAobby5KjlyKoq4Q+22C3jg/sT/y8akV4QBjUQcxiJR/6oN+tybQtJHyDnbQ3eEUePynMcvSo0F+UrcTTnQIafCMMblIOH10w+4K2wtOYfqTEb6orRf6NZbvooAa3U+N1wEPelQnRUxBgGlNfD08/q4E3hc/nGuwGxSVOgtsjgoqyjaHnRmC/kAlsHWb3qaCYjCzYoC2+A/IW2lw2lwLdFhGGdG6+DHP1zT7h57PZYcxrt2hgW4aysa0Upn8oJ2pJRvxi4jtfZI0UsjuEXOwIptJUFLdGheFyqarEvsdcv1W00ByS1FgDprxeFKN8Lmg6waW2F7gpSREuGIhf8YvIOKXVHHA9foTvwcNpzUJgMO7i38Bc0d0soakEh20Xpo+gWaM9euHHgJcwJa//BdYjF78cuLAgUcaI4eTfpfkJc6L8f4uniBa+HXOPV5IN0IkhPDe/BdN9XY2pyi7GFEHrE44rMfwH3o6HsL8WT78AAAAASUVORK5CYII=",
        "Image2Width": 64,
        "Image2Height": 102,
      },
      "1": {
        "BackgroundColor": "#00000000",
        "HSpace": 30,
        "VSpace": 20,
        "TextColor": "#FFFFFFFF",
        "FontSize": 18.0,
        "Border": {"color": "#00000000", "width": "0,0,0,1"},
        "BorderRadius": 8,
        "Padding": {"left": 20, "top": 8, "right": 20, "bottom": 8},
        "LinkWidth": 6,
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
        "LinkWidth": 3,
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
        "LinkWidth": 1,
        "Padding": {"left": 6, "top": 3, "right": 6, "bottom": 3},
      },
    };

    JsonTheme theme = JsonTheme("Fishbone", template);
    mindMap.setTheme(theme);
    mindMap.setHasTextField(false);
    mindMap.setHasEditButton(true);
    mindMap.setShowRecycle(false);
    mindMap.setExpandedLevel(3);
    mindMap.setEnabledExtendedClick(true);
    mindMap.setEnabledDoubleTapShowTextField(true);
    mindMap.setMapType(MapType.fishbone);
    mindMap.setFishboneMapType(FishboneMapType.leftToRight);
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
