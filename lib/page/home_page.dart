import 'package:flutter/material.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';
import 'package:omjh/page/jianghu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeStyle.bgColor,
      ),
      body: getBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'jianghu'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'character'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'bag'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'skill'.tr),
        ],
        selectedIconTheme: const IconThemeData(opacity: 0.0, size: 0),
        unselectedIconTheme: const IconThemeData(opacity: 0.0, size: 0),
        selectedItemColor: ThemeStyle.selectedColor,
        unselectedItemColor: ThemeStyle.unselectedColor,
        selectedLabelStyle:
            const TextStyle(fontFamily: 'NanFengXingShu', fontSize: 22),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'NanFengXingShu', fontSize: 18),
        onTap: (index) => {
          setState(
            () => {_selectedIndex = index},
          )
        },
      ),
    );
  }

  Widget getBody(int index) {
    switch (index) {
      case 0:
        return const JiangHuPage();
      default:
        return const Text('Test');
    }
  }
}
