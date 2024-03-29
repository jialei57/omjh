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
              Text(quest.name,
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
    var items = quest.itemsNeeded();
    var mobs = quest.mobsNeeded();
    if (items.isEmpty && mobs.isEmpty) {
      return const SizedBox(
        height: 20,
      );
    }

    var itemTexts = <Widget>[];
    for (var item in items) {
      var bagItem = shared.items
          .firstWhereOrNull((element) => element.item.id == item.item.id);
      var quantity = 0;
      if (bagItem != null) {
        quantity = bagItem.quantity;
      }

      String completed =
          quantity >= item.quantity ? ' (${'completed'.tr})' : '';
      itemTexts.add(
        Text('- $quantity/${item.quantity} ${item.item.name} $completed',
            style: ThemeStyle.textStyle.copyWith(fontSize: 16)),
      );
    }

    var processingQuest =
        (shared.currentCharacter!.status!['processingQuests'] as List)
            .firstWhere((e) => e['id'] == quest.id);

    for (var mob in mobs) {
      var alreadyKill = (processingQuest['kills'] as List).firstWhere((e) => e['name'] == mob.name)['quantity'];
      String completed =
          alreadyKill >= mob.quantity ? ' (${'completed'.tr})' : '';
      itemTexts.add(
        Text('- $alreadyKill/${mob.quantity} ${mob.name} $completed',
            style: ThemeStyle.textStyle.copyWith(fontSize: 16)),
      );
    }
    return Padding(
      padding:
          EdgeInsets.fromLTRB(verticalPadding + 16, 5, verticalPadding + 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: itemTexts,
      ),
    );
  }
}
