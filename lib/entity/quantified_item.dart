import 'package:omjh/entity/item.dart';

class QuantifiedItem {
  final Item item;
  final int quantity;

  QuantifiedItem(this.item, this.quantity);

  QuantifiedItem.fromJson(Map<String, dynamic> json)
    : item = Item.fromJson(json['item']),
      quantity = json['quantity'];
}
