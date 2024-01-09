import 'package:get/get.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/quantified_item.dart';
import 'package:omjh/entity/quantified_mob.dart';

class Quest {
  final int id;
  final String name;
  final String description;
  final String questType;
  final int levelRequired;
  final int preQuestRequired;
  final int startNPC;
  final int endNPC;
  final String startLine;
  final String endLine;
  final String midLine;
  final Map<String, dynamic> goals;
  final Map<String, dynamic> rewards;

  Quest(
      this.id,
      this.name,
      this.description,
      this.questType,
      this.levelRequired,
      this.preQuestRequired,
      this.startNPC,
      this.endNPC,
      this.startLine,
      this.midLine,
      this.endLine,
      this.goals,
      this.rewards);

  Quest.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        questType = json['quest_type'],
        levelRequired = json['level_required'],
        preQuestRequired = json['pre_required'] ?? 0,
        startNPC = json['start_npc'],
        endNPC = json['end_npc'],
        startLine = json['start_line'],
        midLine = json['mid_line'],
        endLine = json['end_line'],
        goals = json['goals'],
        rewards = json['rewards'];

  List<QuantifiedItem> itemsNeeded() {
    var json = goals['items'];
    if (json == null) return [];
    List<QuantifiedItem> items =
        (json as List).map((i) => QuantifiedItem.fromJson(i)).toList();
    return items;
  }

  List<QuantifiedMob> mobsNeeded() {
    var json = goals['kills'];
    if (json == null) return [];
    List<QuantifiedMob> mobs =
        (json as List).map((i) => QuantifiedMob.fromJson(i)).toList();
    return mobs;
  }

  bool canComplete() {
    bool itemCompleted = true;
    bool killCompleted = true;
    final shared = Get.put(Shared());
    if (goals['items'] != null) {
      var items = itemsNeeded();
      for (var item in items) {
        var bagItem = shared.items
            .firstWhereOrNull((element) => element.item.id == item.item.id);
        var quantity = 0;
        if (bagItem != null) {
          quantity = bagItem.quantity;
        }

        if (quantity < item.quantity) {
          itemCompleted = false;
          break;
        }
      }
    }
    if (goals['kills'] != null) {
      var processingQuest =
          (shared.currentCharacter!.status!['processingQuests'] as List)
              .firstWhere((e) => e['id'] == id);
      var mobs = mobsNeeded();
      for (var mob in mobs) {
        var alreadyKill = (processingQuest['kills'] as List)
            .firstWhere((e) => e['name'] == mob.name)['quantity'];
        if (alreadyKill < mob.quantity) {
          itemCompleted = false;
          break;
        }
      }
    }

    return itemCompleted & killCompleted;
  }
}
