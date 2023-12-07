import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:omjh/bloc/fight_bloc.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/common/loading_dialog.dart';
import 'package:omjh/common/progress_button.dart';
import 'package:omjh/common/theme_style.dart';
// import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/fighter.dart';
import 'package:omjh/entity/hit_result.dart';
import 'package:omjh/entity/npc.dart';
import 'package:omjh/entity/reward.dart';

import '../common/shared.dart';

enum FightStatus { fighting, win, lose, escaped }

class FightPage extends StatefulWidget {
  const FightPage({super.key});

  @override
  State<FightPage> createState() => _FightPageState();
}

class _FightPageState extends State<FightPage> with TickerProviderStateMixin {
  double fightBoxHeight = 0;
  double controlBoxHeight = 130;
  double controlWidth = 90;
  double controlHeight = 30;
  double paddingTop = 8;
  double fighterWidth = 0;
  double fighterHeight = 80;
  late Fighter me;
  List<Fighter> own = [];
  List<Fighter> enemies = [];
  bool _controlDisabled = true;
  Queue<Fighter> fighterQueue = Queue();
  Reward? reward;
  int _selectedSkillId = 0;
  final shared = Get.put(Shared());
  final FightBloc _bloc = FightBloc();
  FightStatus _status = FightStatus.fighting;
  late LoadingDialog _loadingDialog;
  late final AnimationController _loadingController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void initState() {
    super.initState();
    _loadingDialog = LoadingDialog(context, _loadingController);

    _bloc.infoMessages.insert(0, 'battle_start'.tr);

    dynamic argumentData = Get.arguments;
    List<Fighter> all = [];
    me = Fighter(shared.currentCharacter!, true);
    own.add(me);
    all.add(me);

    dynamic npcJson = json.decode(argumentData['npcs'].toString());
    List<Npc> npcs = (npcJson as List).map((i) => Npc.fromJson(i)).toList();
    for (var element in npcs) {
      Fighter f = Fighter(element, false);
      enemies.add(f);
      all.add(f);
    }

    all.sort(((a, b) => b.getSpeed().compareTo(a.getSpeed())));
    fighterQueue.addAll(all);

    for (var e in all) {
      initFighter(e);
    }
    nextRound();
  }

  void nextRound() {
    final fighter = fighterQueue.removeFirst();
    fighterQueue.add(fighter);
    Future.delayed(const Duration(milliseconds: 500), () {
      prepareFight(fighter);
    });
  }

  void prepareFight(Fighter fighter) {
    if (!fighter.isOwnSide) {
      fighter.actionController?.forward();
    } else {
      setState(() {
        _controlDisabled = false;
      });
    }
  }

  void initFighter(Fighter fighter) {
    Tween<Offset> offset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0.0));
    if (!fighter.isOwnSide) {
      offset.end = const Offset(-0.1, 0.0);
    }

    AnimationController actionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    actionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        actionController.reset();
        if (_status == FightStatus.fighting) {
          hit(fighter);
          // fighter.timeController?.forward();
        }
      }
    });
    actionController.addListener(() {
      if (_status != FightStatus.fighting) {
        actionController.stop();
      }
    });
    fighter.actionController = actionController;

    // AnimationController timeController = AnimationController(
    //   duration: Duration(milliseconds: fighter.getAttackTime()),
    //   vsync: this,
    // );
    // timeController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     if (_status == FightStatus.fighting) {
    //       timeController.reset();
    //       fighter.actionController?.forward();
    //     }
    //   }
    // });
    // timeController.addListener(() {
    //   if (_status != FightStatus.fighting) {
    //     timeController.stop();
    //   }
    // });
    // fighter.timeController = timeController;
    // if (fighter.isOwnSide) {
    //   timeController.forward(from: 0.5);
    // } else {
    //   timeController.forward();
    // }

    Animation<Offset> offsetAnimation = offset.animate(CurvedAnimation(
      parent: actionController,
      curve: Curves.fastOutSlowIn,
    ));
    fighter.animation = offsetAnimation;
  }

  @override
  void dispose() {
    for (var e in fighterQueue) {
      e.actionController?.dispose();
    }
    _loadingController.dispose();
    super.dispose();
  }

  void hit(Fighter from) {
    Fighter? to;
    if (from.isOwnSide) {
      to = enemies.firstWhereOrNull((e) => e.hpLeft > 0);
    } else {
      to = own[Random().nextInt(own.length)];
    }

    if (to == null) {
      return;
    }

    setState(() {
      HitResult result;
      if (from == me) {
        result = from.getHitResult(to!, skill: _selectedSkillId);
      } else {
        result = from.getHitResult(to!);
      }
      _bloc.infoMessages.insert(0, result.description);

      if (result.hitted) {
        to.hpLeft -= result.damage;
        to.hitText = '-${result.damage}';
      } else {
        to.hitText = 'miss'.tr;
      }

      if (from.isOwnSide) {
        if (enemies.firstWhereOrNull((e) => e.hpLeft > 0) == null) {
          _updateFightResult(enemies.map((e) => e.char.getId()).toList());
        }
      } else {
        if (own.firstWhereOrNull((e) => e.hpLeft > 0) == null) {
          _status = FightStatus.lose;
        }
      }
    });

    nextRound();
  }

  Future _updateFightResult(List<int> nids) async {
    _loadingDialog.show();
    reward = await _bloc.killedNpc(nids);
    _loadingDialog.dismiss();
    setState(() {
      _status = FightStatus.win;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    fightBoxHeight = screenHeight / 2.2 + MediaQuery.of(context).padding.top;
    fighterHeight = (fightBoxHeight - paddingTop * 4) / 3;
    fighterWidth = (MediaQuery.of(context).size.width - 60) / 2;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/image/ic_village.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Column(
          children: [_buildFightBox(), _buildInfoBox(), _buildControlBox()],
        ),
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
          width: 40,
        ),
        Column(children: enemyWidgets)
      ]),
    );
  }

  Widget _buildChar(Fighter? fighter) {
    if (fighter == null) {
      return SizedBox(
        height: fighterHeight,
      );
    }

    String icon = 'ic_me.png';
    if (fighter.isOwnSide) {
      icon = 'ic_me.png';
    } else if (fighter.char is Npc) {
      icon = Common.getIconForNpc((fighter.char as Npc).id!);
    }

    return Stack(
      children: [
        SizedBox(
          width: fighterWidth,
          height: fighterHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // fighter.isOwnSide
              //     ? Padding(
              //         padding:
              //             EdgeInsets.fromLTRB(0, fighterHeight / 3, 24, 10),
              //         child: _buildTimeControl(fighter),
              //       )
              //     : const SizedBox.shrink(),
              SlideTransition(
                position: fighter.animation!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   fighter.char.getName(),
                    //   style: ThemeStyle.textStyle.copyWith(fontSize: 15),
                    // ),
                    // const SizedBox(
                    //   height: 2,
                    // ),
                    Image(
                      image: AssetImage('assets/image/$icon'),
                      width: fighterHeight / 1.8,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 5),
                      width: fighterHeight / 2.2,
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
                            width: fighterHeight / 2.2,
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
                  ],
                ),
              ),
              // !fighter.isOwnSide
              //     ? Padding(
              //         padding:
              //             EdgeInsets.fromLTRB(24, fighterHeight / 3, 0, 10),
              //         child: _buildTimeControl(fighter))
              //     : const SizedBox.shrink(),
            ],
          ),
        ),
        _buildHitText(fighter)
      ],
    );
  }

  // Widget _buildTimeControl(Fighter fighter) {
  //   return Column(
  //     children: [
  //       const Spacer(),
  //       SpinKitPouringHourGlass(
  //         color: ThemeStyle.bgColor,
  //         strokeWidth: 1,
  //         size: 36,
  //         controller: fighter.timeController,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildHitText(Fighter fighter) {
    if (fighter.hitText == null) {
      return const SizedBox.shrink();
    }
    String text = fighter.hitText!;
    fighter.hitText = null;
    double fontSize = 18;
    if (!text.startsWith("-")) {
      fontSize = 15;
    }
    return Positioned(
      top: 36,
      left: fighter.isOwnSide ? fighterWidth / 5 : fighterWidth / 3 * 2,
      child: DefaultTextStyle(
        style: ThemeStyle.textStyle
            .copyWith(color: Colors.black, fontSize: fontSize),
        child: AnimatedTextKit(
          key: UniqueKey(),
          animatedTexts: [
            FadeAnimatedText(
              text,
              duration: const Duration(milliseconds: 500),
            ),
          ],
          isRepeatingAnimation: false,
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Expanded(
        child: Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Obx(() => ListView.builder(
          itemCount: _bloc.infoMessages.length,
          padding: EdgeInsets.zero,
          reverse: true,
          itemBuilder: ((context, index) {
            return Text(_bloc.infoMessages[index],
                style: ThemeStyle.textStyle.copyWith(fontSize: 16));
          }))),
    ));
  }

  Widget _buildControlBox() {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: _controlDisabled,
          child: Container(
            width: double.infinity,
            height: controlBoxHeight,
            margin: EdgeInsets.fromLTRB(
                8, 0, 8, MediaQuery.of(context).padding.bottom + 5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControl('attack'),
                      _buildControl(null),
                      _buildControl(null)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControl(null),
                      _buildControl(null),
                      _buildControl(null)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControl(null),
                      _buildControl(null),
                      // _buildControl('escape')
                      ProgressBarButton(
                          width: controlWidth,
                          height: controlHeight,
                          text: 'escape'.tr,
                          onCompleted: () => Navigator.pop(context)),
                    ],
                  )
                ]),
          ),
        ),
        if (_controlDisabled)
          Container(
            width: double.infinity,
            height: controlBoxHeight,
            margin: EdgeInsets.fromLTRB(
                8, 0, 8, MediaQuery.of(context).padding.bottom + 5),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
          ),
        _status != FightStatus.fighting
            ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    width: double.infinity,
                    height: controlBoxHeight,
                    margin: EdgeInsets.fromLTRB(
                        8, 0, 8, MediaQuery.of(context).padding.bottom + 5),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 59, 59, 59),
                        border:
                            Border.all(color: ThemeStyle.bgColor, width: 1.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      children: [
                        Text(_status.toString().split('.').last.tr,
                            style: ThemeStyle.textStyle
                                .copyWith(color: Colors.white, fontSize: 24)),
                        _buildRewards(),
                        Text('click_to_quit_fight'.tr,
                            style: ThemeStyle.textStyle
                                .copyWith(color: Colors.white, fontSize: 16)),
                      ],
                    )),
              )
            : const SizedBox.shrink()
      ],
    );
  }

  Widget _buildRewards() {
    if (reward == null) return const SizedBox.shrink();
    var items = reward!.items;
    if (reward!.items.isEmpty) return const SizedBox.shrink();

    String text = 'obtained'.tr;
    for (var item in items) {
      text += ' ${item.item.name}x${item.quantity}';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
      child: Text(text,
          style:
              ThemeStyle.textStyle.copyWith(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildControl(String? name) {
    if (name == null) {
      return SizedBox(width: controlWidth, height: controlHeight);
    }
    return GestureDetector(
      onTap: () {
        switch (name) {
          case 'attack':
            setState(() {
              _controlDisabled = true;
              _selectedSkillId = 0;
              me.actionController?.forward();
            });
            break;
        }
      },
      child: Container(
        width: controlWidth,
        height: controlHeight,
        decoration: BoxDecoration(
            color: ThemeStyle.unselectedColor,
            border: Border.all(color: ThemeStyle.bgColor, width: 2)),
        child: Center(
            child: Text(name.tr,
                style: ThemeStyle.textStyle
                    .copyWith(fontSize: 16, color: Colors.white))),
      ),
    );
  }
}
