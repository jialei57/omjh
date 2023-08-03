import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/quantified_item.dart';

enum ItemType { equipment, other }

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final shared = Get.put(Shared());
  int _selectedIndex = 0;
  int _selectedTypeIndex = 0;
  ItemType _selectedType = ItemType.equipment;
  List<QuantifiedItem> items = [];

  @override
  void initState() {
    items = shared.items
        .where((element) => element.item.itemType == _selectedType.toString())
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        _buildDescriptionBox(),
        Expanded(
          child: _buildItemList(),
        )
      ]),
      bottomNavigationBar: SizedBox(
        height: 40,
        child: BottomNavigationBar(
          currentIndex: _selectedTypeIndex,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home), label: 'equipment'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.home), label: 'other_item'.tr),
          ],
          selectedIconTheme: const IconThemeData(opacity: 0.0, size: 0),
          unselectedIconTheme: const IconThemeData(opacity: 0.0, size: 0),
          selectedItemColor: ThemeStyle.selectedColor,
          unselectedItemColor: ThemeStyle.unselectedColor,
          selectedLabelStyle:
              // const TextStyle(fontFamily: 'AaYangGuanQu', fontSize: 22),
              ThemeStyle.textStyle
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          unselectedLabelStyle: ThemeStyle.textStyle.copyWith(fontSize: 15),
          onTap: (index) {
            setState(() {
              _selectedTypeIndex = index;
              switch (index) {
                case 0:
                  _selectedType = ItemType.equipment;
                  break;
                case 1:
                  _selectedType = ItemType.other;
                  break;
                default:
                  _selectedType = ItemType.other;
              }
              items = shared.items
                  .where((element) =>
                      element.item.itemType == _selectedType.name)
                  .toList();
              _selectedIndex = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: _buildDescription(),
    );
  }

  Widget _buildItemList() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: shared.items.length,
            itemBuilder: ((context, index) => _buidItem(index))));
  }

  Widget _buildDescription() {
    if (_selectedIndex >= items.length) {
      return const SizedBox.shrink();
    }

    return Text(items[_selectedIndex].item.description,
        style: ThemeStyle.textStyle.copyWith(fontSize: 15));
  }

  Widget _buidItem(int index) {
    if (index >= items.length) {
      return const SizedBox.shrink();
    }
    QuantifiedItem item = items[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        color: _selectedIndex == index ? Colors.grey : Colors.transparent,
        child: Row(children: [
          Expanded(
              flex: 4,
              child: Text(item.item.name,
                  style: ThemeStyle.textStyle.copyWith(fontSize: 15))),
          Expanded(
              flex: 1,
              child: Text(item.quantity.toString(),
                  style: ThemeStyle.textStyle.copyWith(fontSize: 15)))
        ]),
      ),
    );
  }
}
