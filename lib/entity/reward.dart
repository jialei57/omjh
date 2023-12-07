import 'package:omjh/entity/quantified_item.dart';

class Reward {
  final List<QuantifiedItem> items;
  final int money;

  Reward(this.items, this.money);

  Reward.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((e) => QuantifiedItem.fromJson(e))
            .toList(),
        money = json['money'] ?? 0;
}
