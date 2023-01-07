import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:omjh/common/api_helper.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/message.dart';
import 'package:path_provider/path_provider.dart';

class Repository {
  final ApiHelper _helper = ApiHelper();
  final shared = Get.put(Shared());
  Future<int> getVersion() async {
    try {
      final jsonData = await _helper.get('mobile-app-version');
      if (jsonData == null) {
        return 0;
      }

      return jsonData['version'];
    } on SocketException {
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

  Future sendMessage(Message message) async {
    try {
      await _helper.post('messages', jsonEncode(message));
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
