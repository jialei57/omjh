import 'dart:convert';

import 'package:get/get.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:omjh/common/action_cable_helper.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/npc.dart';
import 'package:omjh/entity/reward.dart';

import '../entity/quest.dart';
import '../entity/skill.dart';

class InfoBoxBloc implements Bloc {
  final Repository _repository = Get.put(Repository());
  final shared = Get.put(Shared());
  List<Character> players = <Character>[].obs;
  List<Npc> npcs = <Npc>[].obs;
  final actionCableHelper = Get.put(ActionCableHelper());
  List<String> infoMessages = <String>[].obs;
  final infoMessageCount = 30;

  @override
  void dispose() {}

  Future lookAtMap() async {
    final Character char = shared.currentCharacter!;

    actionCableHelper.connectToCableAndSubscribe(
        'Map', {'id': char.map, 'charId': char.id}, onMessage);
  }

  Future<Reward?> completeQuest(int cid, int qid) async {
    return await  _repository.compeleteQuest(cid, qid);
  }

  Future acceptQuest(int cid, int qid) async {
    await _repository.acceptQuest(cid, qid);
  }

  Future<Reward?> killedNpc(List<int> nids) async {
    return await _repository.killedNpc(shared.currentCharacter!.id!, nids);
  }

  Future getNpcRelated(Npc npc) async {
    return await _repository.getNpcRelated(npc);
  }

  void addInfoMessage(String msg) {
    if (msg.isEmpty) {
      return;
    }
    infoMessages.insert(0, msg);
    if (infoMessages.length > infoMessageCount) {
      infoMessages.removeRange(infoMessageCount, infoMessages.length);
    }
  }

  void moveToMap(int mapId) {
    players.clear();
    npcs.clear();
    shared.currentCharacter!.map = mapId;
    Future.delayed(const Duration(milliseconds: 500), () {
      actionCableHelper.unsunsubscribeAllOldMapChanels(mapId);
    });
  }

  void onMessage(Map msg) {
    final action = msg['action'] as String?;
    final map = msg['map'] as int?;

    if (action == 'npc_die') {
      npcs.removeWhere((element) => element.id == msg['npc']);
      return;
    }

    if (map != shared.currentCharacter!.map) {
      return;
    }

    if (action == 'enter') {
      final allPlayers = (json.decode(msg['players']) as List)
          .map((i) => Character.fromJson(i))
          .toList();
      allPlayers
          .removeWhere((element) => element.id == shared.currentCharacter!.id);
      final allNpcs = (json.decode(msg['npcs_with_related']) as List)
          .map((i) {
            Npc npc = Npc.fromJson(i['npc']);
            npc.startQuests = (i['start_quests'] as List).map((questJson) => Quest.fromJson(questJson)).toList();
            npc.endQuests = (i['end_quests'] as List).map((questJson) => Quest.fromJson(questJson)).toList();
            npc.skills = (i['skills'] as List).map((skillJson) => Skill.fromJson(skillJson)).toList();
            return npc;
          })
          .toList();

      players.replaceRange(0, players.length, allPlayers);
      npcs.replaceRange(0, npcs.length, allNpcs);
      return;
    }

    if (action == 'leave') {
      final player = Character.fromJson(json.decode(msg['player']));
      players.removeWhere((element) => element.id == player.id);
      return;
    }
  }
}
