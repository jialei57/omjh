import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/quest.dart';

import '../common/shared.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsState();
}

class _QuestsState extends State<QuestsPage> {
  final shared = Get.put(Shared());
  final double verticalPadding = 12;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shared.quests.length,
      itemBuilder: (context, index) => _buildQuest(shared.quests[index]),
    );
  }

  Widget _buildQuest(Quest quest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(verticalPadding, 20, verticalPadding, 0),
          child: Row(
            children: [
              Text('${quest.name}(${'main'.tr})',
                  style: ThemeStyle.textStyle
                      .copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
              Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      color: ThemeStyle.bgColor,
                      height: 2))
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              verticalPadding + 8, 5, verticalPadding + 8, 0),
          child: Text(quest.description.replaceAll("\\n", "\n"),
              style: ThemeStyle.textStyle.copyWith(fontSize: 16)),
        ),
        _buildCollection(quest),
      ],
    );
  }

  Widget _buildCollection(Quest quest) {
    if (quest.goals['type'] == 'collect') {
      var items = quest.itemsNeeded();
      var itemTexts = <Widget>[];
      for (var item in items) {
        var bagItem = shared.items
            .firstWhereOrNull((element) => element.item.id == item.item.id);
        var quantity = 0;
        if (bagItem != null) {
          quantity = bagItem.quantity;
        }

        itemTexts.add(
          Text('- $quantity/${item.quantity} ${item.item.name}',
              style: ThemeStyle.textStyle.copyWith(fontSize: 16)),
        );
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(
            verticalPadding + 8, 5, verticalPadding + 8, 20),
        child: Column(
          children: itemTexts,
        ),
      );
    }

    return const SizedBox(
      height: 20,
    );
  }
}
