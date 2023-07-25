import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/interactable.dart';
import 'package:omjh/entity/npc.dart';

import 'hit_result.dart';

class Fighter {
  final Interactable char;
  int hpLeft = 0;
  int mpLeft = 0;
  bool isOwnSide;
  Animation<Offset>? animation;
  AnimationController? actionController;
  AnimationController? timeController;
  String? hitText;

  Fighter(this.char, this.isOwnSide) {
    hpLeft = char.getMaxHp();
    mpLeft = char.getMaxMp();
  }

  int getAttackTime() {
    return (3000 / (1000 + char.getSpeed()) * 1000).round();
  }

  int getHit(Fighter to) {
    return (((char.getHit() - to.char.getDodge()) / to.char.getDodge() + 0.8) *
            100)
        .round();
  }

  int getDamage(Fighter to) {
    return (char.getAttack() * (Random().nextInt(50) + 50) / 100.0).round();
  }

  HitResult getHitResult(Fighter to) {
    HitResult result = HitResult();
    int hit = getHit(to);
    String attackLine = '';
    if (char is Character) {
      attackLine = 'uses'.tr + 'normal_attack'.tr;
    } else if (char is Npc) {
      Npc npc = char as Npc;
      attackLine = ((npc.type == 'animal') ? '' : 'uses'.tr) +
          npc.info!['normal_attack'];
    }
    result.description = char.getName() +
        'attack_on'
            .trParams({'attack': attackLine, 'target': to.char.getName()});
    if (Random().nextInt(101) > hit) {
      result.hitted = false;
      result.description += 'but_missed'.tr;
    } else {
      result.hitted = true;
      result.damage = getDamage(to);
      result.description += 'get_damage'.trParams({'target': to.char.getName(), 'damage': result.damage.toString()});
    }

    return result;
  }
}
