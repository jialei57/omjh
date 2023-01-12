import 'package:omjh/entity/interactable.dart';

class Npc implements Interactable {
  final int? id;
  final String name;
  int? map;
  final Map<String, dynamic>? status;
  final Map<String, dynamic>? info;

  Npc(this.id, this.name, this.map, this.status, this.info);

  Npc.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        map = json['map'],
        status = json['status'],
        info = json['info'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'map': map,
        'status': status,
        'info': info
      };
}
