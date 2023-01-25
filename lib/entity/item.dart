class Item {
  final int id;
  final String name;
  final String itemType;
  final bool isUnique;
  final Map<String, dynamic> info;

  Item(this.id, this.name, this.itemType, this.isUnique, this.info);

  Item.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      itemType = json['item_type'],
      isUnique = json['is_unique'],
      info = json['info'];
}
