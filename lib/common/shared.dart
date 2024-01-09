import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:omjh/common/action_cable_helper.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/npc.dart';
import 'package:omjh/entity/quantified_item.dart';
import 'package:omjh/entity/quest.dart';
import 'package:omjh/entity/spot.dart';
import 'package:path_provider/path_provider.dart';

import '../entity/item.dart';

class Shared {
  Character? currentCharacter;
  List<Character> characters = [];
  List<Spot> maps = [];
  List<Quest> quests = [];
  List<QuantifiedItem> items = [];
  List<Item> equipments = [];
  Spot? currentMap;
  double contentHeight = 0;

  Quest? getRelatedQuest(int npcId) {
    if (quests.isEmpty) return null;
    for (var e in quests) {
      if (e.endNPC == npcId) {
        return e;
      }
    }

    return null;
  }

  Quest? getStartQuest(Npc npc) {
    if (npc.startQuests == null || npc.startQuests!.isEmpty) {
      return null;
    }
    for (var q in npc.startQuests!) {
      if (!(currentCharacter!.status!['processingQuests'] as List)
              .contains(q.id) &&
          !(currentCharacter!.status!['completedQuests'] as List)
              .contains(q.id) &&
          currentCharacter!.getLevel() >= q.levelRequired &&
          (q.preQuestRequired == 0 ||
              (currentCharacter!.status!['completedQuests'] as List)
                  .contains(q.preQuestRequired))) {
        return q;
      }
    }
    return null;
  }

  int getEquippedAttribute(String attr) {
    int result = 0;
    for (var item in equipments) {
      for (String key in item.properties.keys) {
        if (key == attr) {
          result += item.properties[key] as int;
        }
      }
    }
    return result;
  }

  Future loadMap() async {
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    final String appDocumentsPath = appDocumentsDirectory.path;
    final String filePath = '$appDocumentsPath/map.csv';

    final File file = File(filePath);
    final bool exist = await file.exists();

    if (!exist) {
      return;
    }

    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    if (fields.length < 2) {
      return;
    }

    for (var i = 2; i < fields.length; i++) {
      List<dynamic> raw = fields[i];
      Map<String, dynamic> infoJson =
          json.decode((raw[8] as String).replaceAll("'", "\""));
      Spot spot = Spot(
          raw[0] as int,
          raw[1] as String,
          raw[2] as String,
          raw[3] as String,
          raw[4] is int ? raw[4] as int? : null,
          raw[5] is int ? raw[5] as int? : null,
          raw[6] is int ? raw[6] as int? : null,
          raw[7] is int ? raw[7] as int? : null,
          infoJson);

      maps.add(spot);
    }
  }

  Future init() async {
    int currentCharIndex = 0;
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? currentCharIndexString =
        await storage.read(key: Common.currentCharacterIndex);
    if (currentCharIndexString == null) {
      await storage.write(key: Common.currentCharacterIndex, value: '0');
    } else {
      currentCharIndex = int.parse(currentCharIndexString);
    }

    currentCharacter = characters[currentCharIndex];

    currentMap =
        maps.firstWhereOrNull((element) => element.id == currentCharacter?.map);
  }

  Future setChar(int currentCharIndex) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.write(key: Common.currentCharacterIndex, value: '0');
    currentCharacter = characters[currentCharIndex];
    currentMap =
        maps.firstWhereOrNull((element) => element.id == currentCharacter?.map);
  }

  void logout() {
    currentCharacter = null;
    maps = [];
    currentMap = null;

    const FlutterSecureStorage storage = FlutterSecureStorage();
    storage.deleteAll();

    clearFileCache();
    final actionCableHelper = Get.put(ActionCableHelper());
    actionCableHelper.cable.disconnect();
  }

  Future clearFileCache() async {
    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    final String appDocumentsPath = appDocumentsDirectory.path;
    final String filePath = '$appDocumentsPath/map.csv';

    final File file = File(filePath);
    final bool exist = await File(filePath).exists();

    if (exist) {
      file.delete();
    }
  }
}
