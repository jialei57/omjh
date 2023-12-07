import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/quantified_item.dart';

enum ItemType { equipment, other, quest }

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final shared = Get.put(Shared());
  int _selectedIndex = 0;
  int _selectedTypeIndex = 0;
  ItemType _selectedType = ItemType.other;
  List<QuantifiedItem> items = [];

  @override
  void initState() {
    items = shared.items
        .where((element) =>
            element.item.itemType == _selectedType.name ||
            (element.item.itemType == ItemType.quest.name &&
                _selectedType == ItemType.other))
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        _buildMoneyBox(),
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
                icon: const Icon(Icons.home), label: 'other_item'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.home), label: 'equipment'.tr),
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
                  _selectedType = ItemType.other;
                  break;
                case 1:
                  _selectedType = ItemType.equipment;
                  break;
                default:
                  _selectedType = ItemType.other;
              }
              items = shared.items
                  .where(
                      (element) => element.item.getType() == _selectedType.name)
                  .toList();
              _selectedIndex = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMoneyBox() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(4.0),
        child: Text(
            '${'money'.tr}: ${shared.currentCharacter!.status!['money']}',
            style: ThemeStyle.textStyle.copyWith(fontSize: 15)));
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
            itemBuilder: ((context, index) => _buildItem(index))));
  }

  Widget _buildDescription() {
    if (_selectedIndex >= items.length) {
      return const SizedBox.shrink();
    }

    var item = items[_selectedIndex];
    var text = item.item.description;
    if (item.item.getType() == 'equipment') {
      for (String key in item.item.properties.keys) {
        text += "\n\n${key.tr} +${item.item.properties[key]}";
      }
    }

    return Text(text, style: ThemeStyle.textStyle.copyWith(fontSize: 15));
  }

  Widget _buildItem(int index) {
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
