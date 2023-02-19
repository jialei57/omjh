import 'package:omjh/entity/quantified_item.dart';

class Reward {
  final List<QuantifiedItem> items;

  Reward(this.items);

  Reward.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((e) => QuantifiedItem.fromJson(e))
            .toList();
}
