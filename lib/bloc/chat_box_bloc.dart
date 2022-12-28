// ignore_for_file: avoid_print

import 'package:action_cable/action_cable.dart';
import 'package:omjh/bloc/bloc.dart';
import 'package:get/get.dart';
import 'package:omjh/common/repository.dart';
import 'package:omjh/common/shared.dart';
import 'package:omjh/entity/character.dart';
import 'package:omjh/entity/message.dart';

class ChatBoxBloc implements Bloc {
  late ActionCable cable;
  List<Message> messages = <Message>[].obs;
  final Repository _repository = Get.put(Repository());
  final shared = Get.put(Shared());

  void init() {
    connectToCable();
  }

  void sendMessage(String msgContent) {
    final Character? currentCharacter = shared.currentCharacter;
    if (currentCharacter == null) {
      return;
    }
    Message message = Message(msgContent, shared.currentCharacter!.name, 0);
    _repository.sendMessage(message);
  }

  void connectToCable() {
    cable = ActionCable.Connect("ws://127.0.0.1:3000/cable", headers: {
      "Authorization": "Some Token",
    }, onConnected: () {
      print("connected");
      subscribe();
    }, onConnectionLost: () {
      print("connection lost");
    }, onCannotConnect: () {
      print("cannot connect");
    });
  }

  void subscribe() {
    cable.subscribe("Messages",
        // channelParams: {"room": "private"},
        onSubscribed: () {
          print('subscribed');
        }, // `confirm_subscription` received
        onDisconnected: () {}, // `disconnect` received
        onMessage: (Map message) {
          print('msg => $message');
          messages.add(Message.fromJson(message as Map<String, dynamic>));
        });
  }

  @override
  void dispose() {}
}
