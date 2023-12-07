import 'package:omjh/entity/interactable.dart';
import 'package:omjh/entity/quest.dart';
import 'package:omjh/entity/skill.dart';

class Npc implements Interactable {
  final int? id;
  final String name;
  int? map;
  final String? type;
  final Map<String, dynamic>? status;
  final Map<String, dynamic>? info;
  List<Skill>? skills;
  List<Quest>? startQuests;
  List<Quest>? endQuests;

  int _dialogIndex = 0;

  Npc(this.id, this.name, this.map, this.type, this.status, this.info,
      this.skills);

  Npc.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        map = json['map'],
        type = json['npc_type'],
        status = json['status'],
        info = json['info'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'map': map,
        'npc_type': type,
        'status': status,
        'info': info
      };

  @override
  String getName() {
    return name;
  }

  @override
  int getId() {
    return id!;
  }

  @override
  int getMaxHp() {
    return status?['hp'] ?? 0;
  }

  @override
  int getSpeed() {
    return status?['speed'] ?? 0;
  }

  @override
  int getMaxMp() {
    return status?['fmp'] ?? 0;
  }

  @override
  int getAttack() {
    return status?['attack'] ?? 0;
  }

  @override
  int getDefense() {
    return status?['defense'] ?? 0;
  }

  @override
  int getHit() {
    return status?['hit'] ?? 0;
  }

  @override
  int getDodge() {
    return status?['dodge'] ?? 0;
  }

  @override
  String getDescription() {
    if (info == null) {
      return '';
    }

    return info!['description'];
  }

  @override
  List<String> getActions() {
    if (info == null) {
      return [];
    }
    return (info?['actions'] as List?)?.map((e) => e as String).toList() ?? [];
  }

  String getNextDialog() {
    if (info == null || info?['dialogs'] == null) {
      return '';
    }

    List<String> dialogs =
        (info?['dialogs'] as List?)?.map((e) => e as String).toList() ?? [];
    if (dialogs.isEmpty) {
      return '';
    }

    String dialog = dialogs[_dialogIndex];
    _dialogIndex++;
    if (_dialogIndex >= dialogs.length) {
      _dialogIndex = 0;
    }

    return dialog;
  }
}
