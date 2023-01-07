class Character {
  final String name;
  final String sex;
  int map;
  final Map<String, dynamic>? status;
  final int? userId;

  Character(this.name, this.sex, this.map, this.status, this.userId);

  Character.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        sex = json['sex'],
        map = json['map'],
        status = json['status'],
        userId = json['user_id'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'sex': sex,
        'map': map,
        'status': status,
        'user_id': userId
      };
}
