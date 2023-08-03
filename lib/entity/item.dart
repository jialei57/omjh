class Item {
  final int id;
  final String name;
  final String itemType;
  final String description;
  final int price;

  Item(this.id, this.name, this.itemType, this.description, this.price);

  Item.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        itemType = json['item_type'],
        description = json['description'],
        price = json['price'];
}
