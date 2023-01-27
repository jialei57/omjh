import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/fight_bloc.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/fighter.dart';
import 'package:omjh/entity/npc.dart';

import '../common/puring_hour_glass.dart';

class FightPage extends StatefulWidget {
  const FightPage({super.key});

  @override
  State<FightPage> createState() => _FightPageState();
}

class _FightPageState extends State<FightPage> with TickerProviderStateMixin {
  double fightBoxHeight = 0;
  double controlBoxHeight = 100;
  double charSize = 80;
  double paddingTop = 8;
  List<Fighter> own = [];
  List<Fighter> enemies = [];
  final FightBloc _bloc = FightBloc();

  @override
  void initState() {
    super.initState();
    dynamic argumentData = Get.arguments;
    dynamic ownJson = json.decode(argumentData['own'].toString());
    List<Character> ownChars =
        (ownJson as List).map((i) => Character.fromJson(i)).toList();
    for (var element in ownChars) {
      own.add(Fighter(element, true));
    }

    dynamic npcJson = json.decode(argumentData['npcs'].toString());
    List<Npc> npcs = (npcJson as List).map((i) => Npc.fromJson(i)).toList();
    for (var element in npcs) {
      enemies.add(Fighter(element, false));
    }

    for (var e in own) {
      initFighter(e);
    }

    for (var e in enemies) {
      initFighter(e);
    }
  }

  void initFighter(Fighter fighter) {
    Tween<Offset> offset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0.0));
    if (!fighter.isOwnSide) {
      offset.end = const Offset(-0.1, 0.0);
    }

    AnimationController actionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    actionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        actionController.reset();
        fighter.timeController?.forward();
      }
    });
    fighter.actionController = actionController;

    AnimationController timeController = AnimationController(
      duration: Duration(milliseconds: fighter.getAttackTime()),
      vsync: this,
    );
    timeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        timeController.reset();
        fighter.actionController?.forward();
      }
    });
    fighter.timeController = timeController;
    if (fighter.isOwnSide) {
      timeController.forward(from: 0.5);
    } else {
      timeController.forward();
    }

    Animation<Offset> offsetAnimation = offset.animate(CurvedAnimation(
      parent: actionController,
      curve: Curves.fastOutSlowIn,
    ));
    fighter.animation = offsetAnimation;
  }

  @override
  void dispose() {
    for (var e in own) {
      e.actionController?.dispose();
      e.timeController?.dispose();
    }
    for (var e in enemies) {
      e.actionController?.dispose();
      e.timeController?.dispose();
    }
    super.dispose();
  }

  void hit() {}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    fightBoxHeight = screenHeight / 2 + MediaQuery.of(context).padding.top;
    controlBoxHeight = 80;
    charSize = (fightBoxHeight - paddingTop * 4) / 3;
    return Scaffold(
      body: Column(
        children: [_buildFightBox(), _buildInfoBox(), _buildControlBox()],
      ),
    );
  }

  Widget _buildFightBox() {
    List<Widget> ownWidgets = [];
    if (own.length == 1) {
      ownWidgets.add(_buildChar(null));
      ownWidgets.add(SizedBox(height: paddingTop));
      ownWidgets.add(_buildChar(own.first));
      ownWidgets.add(SizedBox(height: paddingTop));
      ownWidgets.add(_buildChar(null));
    } else {
      for (var e in own) {
        ownWidgets.add(_buildChar(e));
      }
    }

    List<Widget> enemyWidgets = [];
    if (own.length == 1) {
      enemyWidgets.add(_buildChar(null));
      enemyWidgets.add(SizedBox(height: paddingTop));
      enemyWidgets.add(_buildChar(enemies.first));
      enemyWidgets.add(SizedBox(height: paddingTop));
      enemyWidgets.add(_buildChar(null));
    } else {
      for (var e in own) {
        enemyWidgets.add(_buildChar(e));
      }
    }

    return Container(
      width: double.infinity,
      height: fightBoxHeight,
      margin: EdgeInsets.fromLTRB(
          10, MediaQuery.of(context).padding.top + paddingTop, 10, 0),
      padding: EdgeInsets.only(top: paddingTop),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(children: ownWidgets),
        const SizedBox(
          width: 20,
        ),
        Column(children: enemyWidgets)
      ]),
    );
  }

  Widget _buildChar(Fighter? fighter) {
    if (fighter == null) {
      return SizedBox(
        height: charSize,
      );
    }

    String icon = 'ic_me.png';
    if (fighter.isOwnSide) {
      icon = 'ic_me.png';
    } else if (fighter.char is Npc) {
      icon = Common.getIconForNpc((fighter.char as Npc).id!);
    }

    return SizedBox(
      height: charSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          fighter.isOwnSide
              ? Padding(
                  padding: const EdgeInsets.only(right: 24, bottom: 10),
                  child: _buildTimeControl(fighter),
                )
              : const SizedBox.shrink(),
          SlideTransition(
            position: fighter.animation!,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fighter.char.getName(),
                  style: ThemeStyle.textStyle.copyWith(fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5),
                  width: charSize / 2.2,
                  child: LinearProgressIndicator(
                    //hp bar
                    minHeight: 8,
                    value: fighter.hpLeft / fighter.char.getMaxHp(),
                    valueColor:
                        const AlwaysStoppedAnimation(ThemeStyle.bgColor),
                    backgroundColor: ThemeStyle.emptyBarColor,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                fighter.char.getMaxMp() != 0
                    ? SizedBox(
                        width: charSize / 2.2,
                        child: LinearProgressIndicator(
                          //mp bar
                          minHeight: 8,
                          value: fighter.mpLeft / fighter.char.getMaxMp(),
                          valueColor: const AlwaysStoppedAnimation(
                              Color.fromARGB(137, 92, 90, 90)),
                          backgroundColor: ThemeStyle.emptyBarColor,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                Image(
                  image: AssetImage('assets/image/$icon'),
                  width: charSize / 1.8,
                ),
              ],
            ),
          ),
          !fighter.isOwnSide
              ? Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 10),
                  child: _buildTimeControl(fighter))
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildTimeControl(Fighter fighter) {
    return Column(
      children: [
        const Spacer(),
        SpinKitPouringHourGlass(
          color: ThemeStyle.bgColor,
          strokeWidth: 1,
          size: 36,
          controller: fighter.timeController,
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Expanded(
        child: Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Obx(() => ListView.builder(
          itemCount: _bloc.infoMessages.length,
          reverse: true,
          itemBuilder: ((context, index) {
            return Text(_bloc.infoMessages[index],
                style: ThemeStyle.textStyle.copyWith(fontSize: 16));
          }))),
    ));
  }

  Widget _buildControlBox() {
    return Container(
      width: double.infinity,
      height: controlBoxHeight,
      margin: EdgeInsets.fromLTRB(
          8, 0, 8, MediaQuery.of(context).padding.bottom + 5),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
    );
  }
}
