import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/common/theme_style.dart';

import '../common/shared.dart';

class CharacterPage extends StatelessWidget {
  CharacterPage({super.key});

  final verticallPadding = 60.0;

  final shared = Get.put(Shared());
  final textStyle = ThemeStyle.textStyle.copyWith(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    final char = shared.currentCharacter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(verticallPadding, 20, verticallPadding, 20),
          child: Wrap(
            // crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.vertical,
            spacing: 10,
            children: [
              Text('${'name'.tr}: ${char?.name}', style: textStyle),
              Text('${'age'.tr}: ${char?.getAge()}', style: textStyle),
              Text('${'rank'.tr}: ${char?.getRank()}', style: textStyle),
              Text('${'exp'.tr}: ${char?.getExp()}/${char?.getExpToLevelUp()}',
                  style: textStyle),
              Text('${'hp'.tr}: ${char?.getHP()}', style: textStyle),
              Text('${'mp'.tr}: ${char?.getMp()}', style: textStyle),
            ],
          ),
        ),
        Container(
          color: ThemeStyle.bgColor,
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(verticallPadding, 20, verticallPadding, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'str'.tr}: ${char?.getStr()}', style: textStyle),
              Text('${'attack'.tr}: ${char?.getAttack()}', style: textStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(verticallPadding, 0, verticallPadding, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'agi'.tr}: ${char?.getAgi()}', style: textStyle),
              Text('${'defense'.tr}: ${char?.getDefense()}', style: textStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(verticallPadding, 0, verticallPadding, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'con'.tr}: ${char?.getCon()}', style: textStyle),
              Text('${'hit'.tr}: ${char?.getHit()}', style: textStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(verticallPadding, 0, verticallPadding, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'spi'.tr}: ${char?.getSpi()}', style: textStyle),
              Text('${'dodge'.tr}: ${char?.getDodge()}', style: textStyle),
            ],
          ),
        ),
        Container(
          color: ThemeStyle.bgColor,
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}
