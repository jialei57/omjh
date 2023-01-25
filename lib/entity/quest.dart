import 'package:omjh/entity/quantified_item.dart';

class Quest {
  final int id;
  final String name;
  final String description;
  final bool isMain;
  final Map<String, dynamic> goals;

  Quest(this.id, this.name, this.description, this.isMain, this.goals);

  Quest.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        isMain = json['is_main'],
        goals = json['goals'];

  List<QuantifiedItem> itemsNeeded() {
    var json = goals['items'];
    if (json == null) return [];
    List<QuantifiedItem> items =
        (json as List).map((i) => QuantifiedItem.fromJson(i)).toList();
    return items;
  }
}
