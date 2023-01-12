import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/action_cable_helper.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/npc.dart';

class InfoBoxBloc implements Bloc {
  // final Repository _repository = Get.put(Repository());
  final shared = Get.put(Shared());
  List<Character> players = <Character>[].obs;
  List<Npc> npcs = <Npc>[].obs;
  final actionCableHelper = Get.put(ActionCableHelper());

  @override
  void dispose() {}

  Future lookAtMap() async {
    final Character char = shared.currentCharacter!;

    actionCableHelper.connectToCableAndSubscribe(
        'Map', {'id': char.map, 'charId': char.id}, onMessage);
  }

  void moveToMap(int mapId) {
    players.clear();
    npcs.clear();

    actionCableHelper
        .unsubscribeFromChannel('Map', {'id': shared.currentCharacter!.map});
    shared.currentCharacter!.map = mapId;
  }

  void onMessage(Map msg) {
    final action = msg['action'] as String;

    if (action == 'enter') {
      final allPlayers = (json.decode(msg['players']) as List)
          .map((i) => Character.fromJson(i))
          .toList();
      allPlayers
          .removeWhere((element) => element.id == shared.currentCharacter!.id);
      final allNpcs = (json.decode(msg['npcs']) as List)
          .map((i) => Npc.fromJson(i))
          .toList();
      players.replaceRange(0, players.length, allPlayers);
      npcs.replaceRange(0, npcs.length, allNpcs);
    } else if (action == 'leave') {
      final player = Character.fromJson(json.decode(msg['player']));
      players.removeWhere((element) => element.id == player.id);
    }
  }
}
