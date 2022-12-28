import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:omjh/common/api_helper.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/message.dart';
import 'package:omjh/entity/spot.dart';

class Repository {
  final ApiHelper _helper = ApiHelper();
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

    Future<List<Spot>?> getMaps() async {
    try {
      final jsonData = await _helper.get('maps');
      if (jsonData == null) {
        return null;
      }

      List<Spot> maps =
          (jsonData as List).map((i) => Spot.fromJson(i)).toList();

      return maps;
    } on SocketException {
      Get.rawSnackbar(message: 'Connection Failed');
    }
    return null;
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
