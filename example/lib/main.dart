import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map_example/custom_page.dart';
import 'package:flutter_mind_map_example/theme_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();

  CustomPage customPage = CustomPage();
  ThemePage themePage = ThemePage();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    requestPermission();
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Permission.storage.request().isDenied) {
        debugPrint("storage denied");
      } else {
        debugPrint("permission");
      }
      if (await Permission.manageExternalStorage.request().isDenied) {
        debugPrint("manageExternalStorage denied");
      } else {
        debugPrint("permission");
      }
    }
  }

  int index = 0;
  bool readOnly = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              var prefs = await SharedPreferences.getInstance();
              if (index == 0) {
                prefs.remove("Custom");
                widget.customPage.prefs = null;
                await widget.customPage.init();
              } else {
                prefs.remove("Theme");
                widget.themePage.prefs = null;
                await widget.themePage.init();
              }
              setState(() {});
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          title: Text(
            'Flutter Mind Map',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    Uint8List? image;
                    if (index == 0) {
                      image = await widget.customPage.mindMap.toPng();
                    } else {
                      image = await widget.themePage.mindMap.toPng();
                    }
                    if (image != null) {
                      String? filename = await FilePicker.platform.saveFile(
                        type: FileType.custom,
                        allowedExtensions: ["png"],
                      );
                      if (filename != null) {
                        File file = File(filename);
                        await file.writeAsBytes(image);
                      }
                    }
                  },
                  child: Text(
                    "Export Image",
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "ReadOnly:",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Switch(
                  value: readOnly,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(context).colorScheme.onPrimary,
                  onChanged: (value) {
                    setState(() {
                      readOnly = value;
                      widget.customPage.mindMap.setReadOnly(value);
                      widget.themePage.mindMap.setReadOnly(value);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        body: index == 0 ? widget.customPage : widget.themePage,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.blur_linear_rounded),
              label: "Custom",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              label: "Theme",
            ),
          ],
        ),
      ),
    );
  }
}
