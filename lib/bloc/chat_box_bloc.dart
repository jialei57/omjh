// ignore_for_file: avoid_print

import 'package:omjh/bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:omjh/common/action_cable_helper.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/message.dart';

class ChatBoxBloc implements Bloc {
  List<Message> messages = <Message>[].obs;
  final shared = Get.put(Shared());
  final actionCableHelper = Get.put(ActionCableHelper());

  void init() {
    actionCableHelper.connectToCableAndSubscribe(
        'Message', {'id': 0}, onMessage);
  }

  void sendMessage(String msgContent) {
    final Character? currentCharacter = shared.currentCharacter;
    if (currentCharacter == null) {
      return;
    }
   
    actionCableHelper.sendMessage(
        currentCharacter.name, 0, msgContent);
  }

  void onMessage(Map message) {
    messages.add(Message.fromJson(message as Map<String, dynamic>));
  }

  @override
  void dispose() {}
}
