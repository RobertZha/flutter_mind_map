import 'package:flutter/material.dart';
import 'package:flutter_mind_map_example/custom_page.dart';
import 'package:flutter_mind_map_example/theme_page.dart';

void main() {
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
  }

  int index = 0;
  bool readOnly = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
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
