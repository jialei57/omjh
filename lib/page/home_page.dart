import 'package:flutter/material.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';
import 'package:omjh/page/jianghu_page.dart';
import 'package:omjh/page/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final menuItemHeight = 36.0;
  final menuItemWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeStyle.bgColor,
        toolbarHeight: 36,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        Dialog(child: _buildMenu()));
              },
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, foregroundColor: Colors.white),
              child: Text(
                'menu'.tr,
                style: ThemeStyle.textStyle.copyWith(fontSize: 16),
              ),
            ),
          )
        ],
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
            // const TextStyle(fontFamily: 'AaYangGuanQu', fontSize: 22),
            ThemeStyle.textStyle
                .copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        unselectedLabelStyle: ThemeStyle.textStyle.copyWith(fontSize: 18),
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

  Widget _buildMenu() {
    return Container(
        decoration: BoxDecoration(
            color: ThemeStyle.menuColor,
            border: Border.all(color: Colors.black, width: 2)),
        padding: const EdgeInsets.all(20),
        height: menuItemHeight * 4,
        child: Column(
          children: [
            Container(
              width: menuItemWidth,
              height: menuItemHeight,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ThemeStyle.bgColor, width: 2)),
              child: Center(
                  child: TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, foregroundColor: Colors.black),
                onPressed: () {
                  _logout();
                },
                child: Text('logout'.tr,
                    style: ThemeStyle.textStyle
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
              )),
            )
          ],
        ));
  }

  void _logout() {
    Get.put(Shared()).logout();
    Get.offAll(const LoginPage());
  }
}
