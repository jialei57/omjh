// ignore_for_file: avoid_print
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:omjh/common/common.dart';
import 'package:omjh/entity/subscribed.dart';
import 'package:omjh/lib/action_cable.dart';

enum ActionCableStatus { connecting, connected, disconnected }

class ActionCableHelper {
  late ActionCable cable;
  ActionCableStatus status = ActionCableStatus.disconnected;
  Map<String, Subscribed> subscribers = {};

  void dispose() {
    cable.disconnect();
  }

  void addSubscriber(
      String channel, Map<String, dynamic>? params, Function onMessage) {
    var channleId = channel;
    if (params != null) {
      channleId = '${channel}_${params['id']}';
    }
    final subscriber = Subscribed(channel, params, onMessage);
    subscribers[channleId] = subscriber;
  }

  void connectToCableAndSubscribe(
      String channel, Map<String, dynamic>? params, Function onMessage) async {
    addSubscriber(channel, params, onMessage);

    if (status == ActionCableStatus.connected) {
      subscribeToChannel(channel, params, onMessage);
      return;
    }

    if (status == ActionCableStatus.connecting) {
      return;
    }

    initConnection();
  }

  Future initConnection() async {
    status = ActionCableStatus.connecting;
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: Common.authendicationToken);
    try {
      cable = ActionCable.connect("ws://${Common.baseIP}/cable", headers: {
        "Authorization": token ?? '',
      }, onConnected: () {
        print("connected");
        status = ActionCableStatus.connected;
        subscribeAll();
      }, onConnectionLost: () {
        status = ActionCableStatus.disconnected;
        print("connection lost, retry in 5 sec");
        Future.delayed(const Duration(seconds: 5), () {
          initConnection();
        });
      }, onCannotConnect: () {
        status = ActionCableStatus.disconnected;
        print("cannot connect, retry in 5 sec");
        Future.delayed(const Duration(seconds: 5), () {
          initConnection();
        });
      });
    } catch (e) {
      print('cannot connect: $e');
    }
  }

  void subscribeAll() {
    if (subscribers.isEmpty) {
      return;
    }

    subscribers.forEach((key, value) {
      subscribeToChannel(value.channel, value.params, value.onMessage);
    });
  }

  void subscribeToChannel(
      String channel, Map<String, dynamic>? params, Function onMessage) {
    cable.subscribe(channel, channelParams: params, onSubscribed: () {
      print('subscribed to $channel: ${params?.toString()}');
    }, onDisconnected: () {
      print('cannot subscibe');
    }, onMessage: (Map message) {
      onMessage(message);
    });
  }

  void unsubscribeFromChannel(String channel, Map<String, dynamic>? params) {
    var channleId = channel;
    if (params != null) {
      channleId = '${channel}_${params['id']}';
    }
    if (subscribers.containsKey(channleId)) {
      var subscriber = subscribers[channleId];
      cable.unsubscribe(channel, channelParams: subscriber?.params);
      subscribers.removeWhere((key, value) => key == channleId);
      print('unsubscribed from $channel: ${params?.toString()}');
    }
  }

  void unsunsubscribeAllOldMapChanels(int currentMap) {
    final channleId = 'Map_$currentMap';
    subscribers.keys
        .where((key) => key.startsWith('Map') && key != channleId)
        .toList()
        .forEach((k) {
      var subscriber = subscribers[k];
      cable.unsubscribe(subscriber!.channel, channelParams: subscriber.params);
      subscribers.remove(k);
      print(
          'unsubscribed from ${subscriber.channel}: ${subscriber.params?.toString()}');
    });
  }

  void sendMessage(String charName, int mapId, String content) {
    if (status == ActionCableStatus.connected) {
      cable.performAction('Message', action: 'send_message', channelParams: {
        'id': mapId
      }, actionParams: {
        'char_name': charName,
        'map': mapId,
        'content': content
      });
    } else {
      Get.rawSnackbar(message: 'Connot send now');
    }
  }
}
