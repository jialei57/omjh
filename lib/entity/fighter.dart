import 'package:flutter/material.dart';
import 'package:omjh/entity/interactable.dart';

class Fighter {
  final Interactable char;
  int hpLeft = 0;
  int mpLeft = 0;
  bool isOwnSide;
  Animation<Offset>? animation;
  AnimationController? actionController;
  AnimationController? timeController;

  Fighter(this.char, this.isOwnSide) {
    hpLeft = char.getMaxHp();
    mpLeft = char.getMaxMp();
  }

  int getAttackTime() {
    return (3000 / (1000 + char.getSpeed()) * 1000).round();
  }
}
