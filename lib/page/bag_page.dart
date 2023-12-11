import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/items_bloc.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/item.dart';
import 'package:omjh/entity/quantified_item.dart';

enum ItemType { equipment, other, quest }

enum EquipmentType { accessory, artifact }

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final shared = Get.put(Shared());
  final _itemHeight = 36.0;
  int _selectedIndex = 0;
  int _selectedTypeIndex = 0;
  int _selectedEquipmentTypeIndex = 0;
  bool _equippedSelected = false;
  ItemType _selectedType = ItemType.other;
  EquipmentType _selectedEquipmentType = EquipmentType.accessory;
  List<QuantifiedItem> items = [];
  final _bloc = ItemsBloc();

  @override
  void initState() {
    initItems();
    super.initState();
  }

  void initItems() {
    items = shared.items
        .where((element) => element.item.getType() == _selectedType.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        _buildMoneyBox(),
        _buildDescriptionBox(),
        Expanded(
          child: _buildItems(),
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
          selectedLabelStyle: ThemeStyle.textStyle
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
              initItems();
              _selectedIndex = 0;
              if (_selectedType == ItemType.equipment) {
                _equippedSelected = true;
              } else {
                _equippedSelected = false;
              }
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

  Widget _buildItems() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: _buildItemList());
  }

  Widget _buildItemList() {
    if (_selectedType != ItemType.equipment) {
      return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: shared.items.length,
          itemBuilder: ((context, index) => _buildItem(index)));
    } else {
      return Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedEquipmentTypeIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedEquipmentTypeIndex = index;
                _equippedSelected = true;
                switch (_selectedEquipmentTypeIndex) {
                  case 0:
                    _selectedEquipmentType = EquipmentType.accessory;
                    break;
                  case 1:
                    _selectedEquipmentType = EquipmentType.artifact;
                    break;
                  default:
                    _selectedEquipmentType = EquipmentType.accessory;
                    break;
                }
                items = shared.items
                    .where((element) =>
                        element.item.itemType == _selectedEquipmentType.name)
                    .toList();
                _selectedIndex = 0;
              });
            },
            unselectedLabelTextStyle: ThemeStyle.textStyle
                .copyWith(color: ThemeStyle.unselectedColor),
            selectedLabelTextStyle: ThemeStyle.textStyle.copyWith(
                color: ThemeStyle.selectedColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: const SizedBox.shrink(),
                label: Text('accessory'.tr),
              ),
              NavigationRailDestination(
                icon: const SizedBox.shrink(),
                label: Text('artifact'.tr),
              ),
            ],
          ),
          const VerticalDivider(
              thickness: 1, width: 1, color: ThemeStyle.bgColor),
          Expanded(
            child: Column(
              children: [
                _buildEquipped(),
                const Divider(
                    thickness: 1, height: 1, color: ThemeStyle.bgColor),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: shared.items.length,
                      itemBuilder: ((context, index) => _buildItem(index))),
                ),
              ],
            ),
          )
        ],
      );
    }
  }

  Widget _buildDescription() {
    Item? item;
    if (_equippedSelected == true) {
      item = shared.equipments
          .firstWhereOrNull((e) => e.itemType == _selectedEquipmentType.name);
      if (item == null) {
        return const SizedBox.shrink();
      }
    } else {
      if (_selectedIndex >= items.length) {
        return const SizedBox.shrink();
      }
      item = items[_selectedIndex].item;
    }

    var text = item.description;
    if (item.getType() == 'equipment') {
      for (String key in item.properties.keys) {
        text += "\n\n${key.tr} +${item.properties[key]}";
      }
    }

    return Text(text, style: ThemeStyle.textStyle.copyWith(fontSize: 15));
  }

  Widget _buildEquipped() {
    var equipped = shared.equipments
        .firstWhereOrNull((e) => e.itemType == _selectedEquipmentType.name);
    return GestureDetector(
      onTap: () {
        setState(() {
          _equippedSelected = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        height: _itemHeight,
        color: _equippedSelected ? Colors.grey : Colors.transparent,
        child: Row(children: [
          Expanded(
              flex: 4,
              child: Text(equipped != null ? equipped.name : "not_equipped".tr,
                  style: ThemeStyle.textStyle.copyWith(fontSize: 15))),
          equipped != null
              ? Container(
                  height: 26,
                  padding: const EdgeInsets.only(left: 20),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: ThemeStyle.bgColor),
                      onPressed: () {
                        takeOff(_selectedEquipmentType.name);
                      },
                      child: Text(
                        'take_off'.tr,
                        style: ThemeStyle.textStyle
                            .copyWith(color: Colors.white, fontSize: 16),
                      )))
              : const SizedBox.shrink()
        ]),
      ),
    );
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
          _equippedSelected = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        height: _itemHeight,
        color: (!_equippedSelected && _selectedIndex == index)
            ? Colors.grey
            : Colors.transparent,
        child: Row(children: [
          Expanded(
              flex: 4,
              child: Text(item.item.name,
                  style: ThemeStyle.textStyle.copyWith(fontSize: 15))),
          Expanded(
              flex: 1,
              child: Text(item.quantity.toString(),
                  textAlign: TextAlign.end,
                  style: ThemeStyle.textStyle.copyWith(fontSize: 15))),
          if (item.item.getType() == ItemType.equipment.name &&
              index == _selectedIndex &&
              !_equippedSelected)
            Container(
              height: 26,
              padding: const EdgeInsets.only(left: 20),
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: ThemeStyle.bgColor),
                  onPressed: () {
                    equip(item.item.id);
                  },
                  child: Text(
                    'equip'.tr,
                    style: ThemeStyle.textStyle
                        .copyWith(color: Colors.white, fontSize: 16),
                  )),
            )
          else
            const SizedBox.shrink()
        ]),
      ),
    );
  }

  Future equip(int iid) async {
    await _bloc.equip(iid);
    setState(() {
      _selectedIndex = 0;
      _equippedSelected = true;
      initItems();
    });
  }

  Future takeOff(String type) async {
    await _bloc.takeOff(type);
    setState(() {
      initItems();
    });
  }
}
