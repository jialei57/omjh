import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:omjh/bloc/info_box_bloc.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/interactable.dart';
import 'package:omjh/entity/npc.dart';
import 'package:omjh/entity/quest.dart';
import 'package:omjh/entity/reward.dart';
import 'package:omjh/entity/spot.dart';
import 'package:omjh/page/fight_page.dart';
import 'package:omjh/page/map_page.dart';

enum MoveDirection { up, down, left, right, none }

class InfoBox extends StatefulWidget {
  const InfoBox({super.key});

  @override
  State<InfoBox> createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> with TickerProviderStateMixin {
  final InfoBoxBloc _bloc = InfoBoxBloc();
  final spotWidth = 90.0;
  final npcWidth = 80.0;
  final spotHeight = 30.0;
  final spotVerticalPadding = 10;
  final spotHorizontalPadding = 20;
  final boxHeight = 130.0;
  var controlLeftPadding = 0.0;
  final controlTopPadding = 12.0;
  final infoHeight = 100.0;
  final shared = Get.put(Shared());
  late final AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  var moveDirection = MoveDirection.none;
  // late LoadingDialog _loadingDialog;
  Spot? nextSpot;
  Interactable? _selectedObject;
  Tween<Offset> offset =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 0.0));
  late final AnimationController _dialogController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();
  @override
  void initState() {
    super.initState();
    _bloc.lookAtMap();
    // _loadingDialog = LoadingDialog(context, _dialogController);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        setState(() {
          shared.currentMap = nextSpot;
        });
      }
    });

    _offsetAnimation = offset.animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    if ((shared.currentCharacter!.status!['processingQuests'] as List)
            .isEmpty &&
        (shared.currentCharacter!.status!['completedQuests'] as List).isEmpty) {
      _bloc.addInfoMessage('you_are_hungry'.tr);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dialogController.dispose();
    super.dispose();
  }

  void setAnimation() {
    switch (moveDirection) {
      case MoveDirection.up:
        offset.begin = Offset.zero;
        offset.end = const Offset(0.0, -0.5);
        break;
      case MoveDirection.down:
        offset.begin = Offset.zero;
        offset.end = const Offset(0.0, 0.5);
        break;
      case MoveDirection.left:
        offset.begin = Offset.zero;
        offset.end = const Offset(-1.0, 0.0);
        break;
      case MoveDirection.right:
        offset.begin = Offset.zero;
        offset.end = const Offset(1.0, 0.0);
        break;
      case MoveDirection.none:
        offset = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 0.0),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    controlLeftPadding =
        (screenWidth - 3 * spotWidth - 2 * spotHorizontalPadding) / 2;
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: Stack(
              children: [
                Column(
                  children: [_buildInfo(), _buildInfoMesages()],
                ),
                _selectedObject != null
                    ? _buildInteractionBox()
                    : const SizedBox.shrink()
              ],
            )),
            _buildPlayers()
          ],
        )),
        Column(children: [_buildControlBox(), _buildNPCRow()])
      ],
    );
  }

  Widget _buildInfoMesages() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        height: double.infinity,
        child: Obx(() => ListView.builder(
            itemCount: _bloc.infoMessages.length,
            reverse: true,
            itemBuilder: ((context, index) {
              return Text(_bloc.infoMessages[index],
                  style: ThemeStyle.textStyle.copyWith(fontSize: 16));
            }))),
      ),
    );
  }

  Widget _buildInteractionBox() {
    if (_selectedObject == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: ThemeStyle.npcColor,
          border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: double.infinity,
            child: Text((_selectedObject as Npc).name,
                textAlign: TextAlign.center,
                style: ThemeStyle.textStyle
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 5),
          Text(_selectedObject!.getDescription(),
              // textAlign: TextAlign.start,
              style: ThemeStyle.textStyle.copyWith(fontSize: 16)),
          const Spacer(),
          Row(
            children: _buildActionButtons(),
          )
        ]),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    var buttons = <Widget>[];
    buttons.add(const Spacer());
    for (var action in _selectedObject!.getActions()) {
      buttons.add(_buildActionButton(action));
      buttons.add(const SizedBox(width: 4));
    }
    buttons.add(_buildActionButton('leave'));
    return buttons;
  }

  Future _checkNPCQuests(Npc npc) async {
    Quest? quest = shared.getRelatedQuest(npc.id ?? -1);
    if (quest != null) {
      if (quest.canComplete()) {
        _bloc.addInfoMessage('${npc.name}: ${quest.endLine}');
        var rewards =
            await _bloc.completeQuest(shared.currentCharacter!.id!, quest.id);
        if (rewards == null) return;
        if (rewards.money != 0) {
          _bloc.addInfoMessage(
              '${'obtained'.tr} ${'money'.tr}x${quest.rewards['money']}');
        }
        if (rewards.items.isNotEmpty) {
          String text = 'obtained'.tr;
          for (var item in rewards.items) {
            text += ' ${item.item.name}x${item.quantity}';
          }
          _bloc.addInfoMessage(text);
        }
      } else {
        _bloc.addInfoMessage('${npc.name}: ${quest.midLine}');
      }
    } else {
      Quest? quest = shared.getStartQuest(npc);
      if (quest != null) {
        _bloc.addInfoMessage('${npc.name}: ${quest.startLine}');
        _bloc.acceptQuest(shared.currentCharacter!.id!, quest.id);
      } else {
        _bloc.addInfoMessage('${npc.name}: ${npc.getNextDialog()}');
      }
    }
  }

  Widget _buildActionButton(String action) {
    return GestureDetector(
      onTap: () {
        switch (action) {
          case 'leave':
            setState(() {
              _selectedObject = null;
            });
            break;
          case 'talk':
            setState(() {
              Npc? npc = _selectedObject as Npc?;
              if (npc == null) return;

              _selectedObject = null;

              _checkNPCQuests(npc);
            });
            break;
          case 'kill':
            Npc? npc = _selectedObject as Npc?;
            if (npc == null) return;
            prepareFight(npc);
            break;
          case 'collect':
          case 'chop':
            Npc? npc = _selectedObject as Npc?;
            if (npc == null) return;
            setState(() {
              _selectedObject = null;
            });
            killNpc(npc.id!);
            break;
          default:
            setState(() {
              _selectedObject = null;
            });
        }
      },
      child: SizedBox(
        height: 40,
        width: 60,
        child: Stack(
          children: [
            ClipPath(
                clipper: ParallelogramClipper(),
                child: Container(color: ThemeStyle.bgColor)),
            Center(
              child: ClipPath(
                  clipper: ParallelogramClipper(),
                  child: Container(
                      height: 36,
                      width: 55,
                      color: Colors.white,
                      child: Center(
                          child: Text(action.tr,
                              style: ThemeStyle.textStyle
                                  .copyWith(fontSize: 15))))),
            )
          ],
        ),
      ),
    );
  }

  prepareFight(Npc npc) async {
    setState(() {
      _selectedObject = null;
    });
    Get.to(() => const FightPage(),
        arguments: {
          'npcs': [json.encode(npc)]
        },
        fullscreenDialog: true);
    return;
  }

  killNpc(int nid) async {
    List<int> nids = [];
    nids.add(nid);
    Reward? reward = await _bloc.killedNpc(nids);
    if (reward == null) return;
    var items = reward.items;
    String text = 'obtained'.tr;
    for (var item in items) {
      text += ' ${item.item.name}x${item.quantity}';
    }
    setState(() {
      _bloc.addInfoMessage(text);
    });
  }

  Widget _buildInfo() {
    return Container(
        height: infoHeight,
        width: double.infinity,
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(color: ThemeStyle.bgColor, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Text(
            (shared.currentMap?.description ?? '').replaceAll("\\n", "\n"),
            style: ThemeStyle.textStyle.copyWith(fontSize: 16)));
  }

  Widget _buildPlayers() {
    return Container(
      width: spotWidth + 8,
      height: double.infinity,
      decoration: const BoxDecoration(
          border:
              Border(left: BorderSide(width: 1.5, color: ThemeStyle.bgColor))),
      child: Obx(() => ListView.builder(
          itemCount: _bloc.players.length,
          itemBuilder: ((context, index) {
            return _buildPlayer(index);
          }))),
    );
  }

  Widget _buildPlayer(int index) {
    final Character player = _bloc.players[index];
    return Container(
        width: double.infinity,
        height: spotHeight,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 218, 215, 215),
            border: Border.all(color: ThemeStyle.bgColor, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Center(
          child: Text(player.name,
              style: ThemeStyle.textStyle
                  .copyWith(fontSize: 16, color: Colors.black)),
        ));
  }

  Widget _buildNpc(Npc npc) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedObject = npc;
        });
      },
      child: Container(
          width: npcWidth,
          height: spotHeight,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: ThemeStyle.npcColor,
              border: Border.all(color: ThemeStyle.bgColor, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          child: Center(
            child: Text(npc.name,
                style: ThemeStyle.textStyle
                    .copyWith(fontSize: 16, color: Colors.black)),
          )),
    );
  }

  Widget _buildNPCRow() {
    return Obx(() => SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 10, 4),
            child: Row(children: _buildNPCs()),
          ),
        ));
  }

  List<Widget> _buildNPCs() {
    List<Widget> npcs = <Widget>[];
    npcs.add(Text('there_are'.tr,
        style: ThemeStyle.textStyle.copyWith(fontSize: 16)));
    for (var element in _bloc.npcs) {
      npcs.add(_buildNpc(element));
    }
    return npcs;
  }

  Widget _buildSpot(Spot? spot, MoveDirection direction,
      {bool isCurrent = false}) {
    if (spot == null) {
      return const SizedBox.shrink();
    }
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onTap: () {
          if (!isCurrent) {
            if (_selectedObject != null) {
              setState(() {
                _selectedObject = null;
              });
            }
            _bloc.moveToMap(spot.id);

            Future.delayed(const Duration(milliseconds: 2000), () {
              if (shared.currentCharacter!.map == spot.id) {
                _bloc.lookAtMap();
              }
            });

            nextSpot = spot;
            moveDirection = direction;
            setAnimation();
            _animationController.forward();
          }
        },
        child: Container(
          width: spotWidth,
          height: spotHeight,
          decoration: BoxDecoration(
              color: isCurrent ? Colors.grey : Colors.white,
              border: Border.all(color: ThemeStyle.bgColor, width: 2)),
          child: Center(
              child: Text(spot.name,
                  style: isCurrent
                      ? ThemeStyle.textStyle
                          .copyWith(fontSize: 16, color: Colors.white)
                      : ThemeStyle.textStyle.copyWith(fontSize: 16))),
        ),
      ),
    );
  }

  Spot? findLeftSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.left == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.left! - 1];
  }

  Spot? findRightSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.right == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.right! - 1];
  }

  Spot? findTopSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.top == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.top! - 1];
  }

  Spot? findBottomSpot() {
    if (shared.maps.isEmpty) {
      return null;
    }

    if (shared.currentMap?.bottom == null) {
      return null;
    }

    return shared.maps[shared.currentMap!.bottom! - 1];
  }

  Widget _buildControlBox() {
    return Container(
        height: boxHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
            border:
                Border(top: BorderSide(width: 1.5, color: ThemeStyle.bgColor))),
        child: Stack(
          children: [
            Positioned(
                top: controlTopPadding,
                left: 10,
                child: Text(shared.currentMap?.city ?? '',
                    style: ThemeStyle.textStyle.copyWith(fontSize: 18))),
            Positioned(
                top: controlTopPadding,
                right: 10,
                child: GestureDetector(
                  onTap: () => showMap(context),
                  child: Text('map'.tr,
                      style: ThemeStyle.textStyle.copyWith(
                          fontSize: 18, decoration: TextDecoration.underline)),
                )),
            Positioned(
              //left
              top: controlTopPadding + spotHeight + spotVerticalPadding,
              left: controlLeftPadding,
              child: _buildSpot(findLeftSpot(), MoveDirection.right),
            ),
            Positioned(
              //top
              top: controlTopPadding,
              left: controlLeftPadding + spotHorizontalPadding + spotWidth,
              child: _buildSpot(findTopSpot(), MoveDirection.down),
            ),
            Positioned(
              //middle
              top: controlTopPadding + spotHeight + spotVerticalPadding,
              left: controlLeftPadding + spotHorizontalPadding + spotWidth,
              child: _buildSpot(shared.currentMap, MoveDirection.none,
                  isCurrent: true),
            ),
            Positioned(
              //right
              top: controlTopPadding + spotHeight + spotVerticalPadding,
              left: controlLeftPadding +
                  spotHorizontalPadding * 2 +
                  spotWidth * 2,
              child: _buildSpot(findRightSpot(), MoveDirection.left),
            ),
            Positioned(
              //bottom
              top: controlTopPadding + spotHeight * 2 + spotVerticalPadding * 2,
              left: controlLeftPadding + spotHorizontalPadding + spotWidth,
              child: _buildSpot(findBottomSpot(), MoveDirection.up),
            )
          ],
        ));
  }

  void showMap(BuildContext context) {
    MapDialog(context).showCurrentMap();
  }
}
