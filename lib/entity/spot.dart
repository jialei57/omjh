class Spot {
  final int id;
  final String name;
  final String city;
  final String description;
  final int? left;
  final int? top;
  final int? right;
  final int? bottom;
  final Map<String, dynamic>? info;

  Spot(this.id, this.name, this.city, this.description, this.left, this.top,
      this.right, this.bottom, this.info);

  int getX() {
    return info?['x'];
  }

  int getY() {
    return info?['y'];
  }

  String? getType() {
    return info?['type'];
  }
}
