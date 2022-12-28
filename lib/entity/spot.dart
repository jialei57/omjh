class Spot {
  final int id;
  final int x;
  final int y;
  final String name;
  final String city;
  final String description;

  Spot(this.id, this.x, this.y, this.name, this.city, this.description);

  Spot.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        x = json['x'],
        y = json['y'],
        name = json['name'],
        city = json['city'],
        description = json['description'];
}
