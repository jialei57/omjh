import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:omjh/common/api_helper.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/quantified_item.dart';
import 'package:omjh/entity/quest.dart';
import 'package:omjh/entity/reward.dart';
import 'package:path_provider/path_provider.dart';

class Repository {
  final ApiHelper _helper = ApiHelper();
  final shared = Get.put(Shared());
  final logger = Logger();
  Future<int> getVersion() async {
    try {
      final jsonData = await _helper.get('mobile-app-version');
      if (jsonData == null) {
        return 0;
      }

      return jsonData['version'];
    } on SocketException catch (e) {
      logger.d(e);
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return 0;
  }

  Future<bool> getMapFile() async {
    try {
      final Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory(); // 1
      final String appDocumentsPath = appDocumentsDirectory.path;
      final String filePath = '$appDocumentsPath/map.csv';

      final File file = File(filePath);
      final bool exist = await file.exists();

      if (exist) {
        return true;
      }

      final String content = await _helper.get('map', contentType: 'text/csv');
      File newFile = await file.create();
      await newFile.writeAsString(content);
      return true;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    } on IOException {
      Get.rawSnackbar(message: 'Failed to save map file.');
    }

    return false;
  }

  Future<List<Character>?> getCharacters() async {
    try {
      final jsonData = await _helper.get('characters');
      if (jsonData == null) {
        return null;
      }

      List<Character> characters =
          (jsonData as List).map((i) => Character.fromJson(i)).toList();

      return characters;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
  }

  Future getQuests() async {
    try {
      final jsonData =
          await _helper.get('processing-quests/${shared.currentCharacter!.id}');
      if (jsonData == null) {
        return null;
      }

      List<Quest> quests =
          (jsonData as List).map((i) => Quest.fromJson(i)).toList();

      shared.quests = quests;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
  }

  Future getItems() async {
    try {
      final jsonData =
          await _helper.get('items/${shared.currentCharacter!.id}');
      if (jsonData == null) {
        return null;
      }

      List<QuantifiedItem> items =
          (jsonData as List).map((i) => QuantifiedItem.fromJson(i)).toList();

      shared.items = items;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
  }

  // Future sendMessage(Message message) async {
  //   try {
  //     await _helper.post('messages', jsonEncode(message));
  //   } on SocketException {
  //     Get.rawSnackbar(message: 'Connection Failed');
  //   }
  //   return;
  // }

  // Future<dynamic> updateCharacter(Character char) async {
  //   try {
  //     return await _helper.put('characters/${char.id!}', jsonEncode(char));
  //   } on SocketException {
  //     Get.rawSnackbar(message: 'Connection Failed');
  //   }
  //   return null;
  // }

  Future compeleteQuest(int cid, int qid) async {
    try {
      final jsonData =
          await _helper.put('complete-quest', '{"id":"$cid","qid":"$qid"}');
      if (jsonData == null) {
        return null;
      }

      Character updated = Character.fromJson(jsonData);
      shared.currentCharacter = updated;

      await getQuests();

      return;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
  }

  Future<Reward?> killedNpc(int cid, List<int> nids) async {
    try {
      final jsonData =
          await _helper.put('killed-npc', '{"id":"$cid","nids": $nids}');
      if (jsonData == null) {
        return null;
      }

      Character updated = Character.fromJson(jsonData['char']);
      shared.currentCharacter = updated;

      if (jsonData['item_changed'] == true) {
        await getItems();
      }

      Reward reward = Reward.fromJson(jsonData['reward']);
      return reward;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
  }

  Future<bool> createCharacter(Character char) async {
    try {
      dynamic json = await _helper.post('characters', jsonEncode(char));

      if (json == null) {
        return false;
      }
      return true;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return false;
  }

  Future<String?> authenticate(String username, String password) async {
    try {
      final jsonData = await _helper.post(
          'authenticate', '{"username":"$username","password":"$password"}');
      if (jsonData == null) {
        return null;
      }

      final String token = jsonData['auth_token'];
      const storage = FlutterSecureStorage();
      await storage.write(key: Common.authendicationToken, value: token);

      return token;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
  }
}
