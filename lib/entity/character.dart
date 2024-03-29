import 'package:omjh/common/common.dart';
import 'package:omjh/entity/interactable.dart';
import 'package:get/get.dart';
import 'package:omjh/entity/quest.dart';

import '../common/shared.dart';

class Character implements Interactable {
  final int? id;
  final String name;
  final String sex;
  int map;
  final Map<String, dynamic>? status;
  final int? userId;
  DateTime? createdAt;

  final shared = Get.put(Shared());
  Character(this.id, this.name, this.sex, this.map, this.status, this.userId);

  Character.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        sex = json['sex'],
        map = json['map'],
        status = json['status'],
        userId = json['user_id'],
        createdAt = DateTime.parse(json['created_at']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sex': sex,
        'map': map,
        'status': status,
        'user_id': userId,
        'created_at': createdAt.toString()
      };

  num getAge() {
    if (createdAt == null) {
      return Common.initAge;
    }
    Duration diff = DateTime.now().difference(createdAt!);
    return Common.initAge + diff.inDays ~/ 3;
  }

  @override
  String getName() {
    return name;
  }

  @override
  int getId() {
    return id!;
  }

  String getRank() {
    int level = getLevel();
    if (level == 0) {
      return 'mortal'.tr;
    }

    return 'unkonwn_rank'.tr;
  }

  int getLevel() {
    return status?['level'] ?? 0;
  }

  int getExp() {
    int exp = status?['exp'] ?? 0;
    return exp;
  }

  @override
  int getMaxHp() {
    return getCon() * 10;
  }

  @override
  int getSpeed() {
    return getAgi();
  }

  @override
  int getAttack() {
    return getStr();
  }

  @override
  int getDefense() {
    return (getCon() * 0.2).round();
  }

  @override
  int getHit() {
    return getAgi();
  }

  @override
  int getDodge() {
    return getAgi();
  }

  @override
  int getMaxMp() {
    if (getLevel() == 0) return 0;
    return getSpi() * 10;
  }

  int getStr() {
    return Common.initStr + shared.getEquippedAttribute('str');
  }

  int getCon() {
    return Common.initCon + shared.getEquippedAttribute('con');
  }

  int getAgi() {
    return Common.initAgi + shared.getEquippedAttribute('agi');
  }

  int getSpi() {
    return Common.initSpi + shared.getEquippedAttribute('spi');
  }

  int getExpToLevelUp() {
    int expToLevelUp = status?['expToLevelUp'] ?? 0;
    return expToLevelUp;
  }

  List<Quest> getProcessingQuests() {
    var result = (status?['processingQuests'] as List?)
        ?.map((e) => Quest.fromJson(e as Map<String, dynamic>))
        .toList();

    return result ?? [];
  }

  @override
  String getDescription() {
    return '';
  }

  @override
  List<String> getActions() {
    return [];
  }
}
