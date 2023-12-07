class Item {
  final int id;
  final String name;
  final String itemType;
  final String description;
  final int price;
  final Map<String, dynamic> properties;

  Item(this.id, this.name, this.itemType, this.description, this.price,
      this.properties);

  Item.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        itemType = json['item_type'],
        description = json['description'],
        price = json['price'],
        properties = json['properties'];

  String getType() {
    if (itemType == 'other' || itemType == 'quest') {
      return 'other';
    } else if (itemType == 'accessory') {
      return 'equipment';
    }
    return 'other';
  }
}
