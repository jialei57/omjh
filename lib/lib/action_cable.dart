import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

import 'channel_id.dart';

typedef OnConnectedFunction = void Function();
typedef OnConnectionLostFunction = void Function();
typedef OnCannotConnectFunction = void Function();
typedef OnChannelSubscribedFunction = void Function();
typedef OnChannelDisconnectedFunction = void Function();
typedef OnChannelMessageFunction = void Function(Map message);

class ActionCable {
  DateTime? _lastPing;
  late Timer _timer;
  late IOWebSocketChannel _socketChannel;
  late StreamSubscription _listener;
  OnConnectedFunction? onConnected;
  OnCannotConnectFunction? onCannotConnect;
  OnConnectionLostFunction? onConnectionLost;
  final Map<String, OnChannelSubscribedFunction?>
      _onChannelSubscribedCallbacks = {};
  final Map<String, OnChannelDisconnectedFunction?>
      _onChannelDisconnectedCallbacks = {};
  final Map<String, OnChannelMessageFunction?> _onChannelMessageCallbacks = {};

  ActionCable.connect(
    String url, {
    Map<String, String> headers = const {},
    this.onConnected,
    this.onConnectionLost,
    this.onCannotConnect,
  }) {
    // rails gets a ping every 3 seconds
    _socketChannel = IOWebSocketChannel.connect(url,
        headers: headers, pingInterval: const Duration(seconds: 3));
    handleSocketError();
    _listener = _socketChannel.stream.listen(_onData, onError: (_) {
      disconnect(); // close a socket and the timer
      if (onCannotConnect != null) onCannotConnect!();
    });
    _timer = Timer.periodic(const Duration(seconds: 3), healthCheck);
  }

  handleSocketError() async {
    try {
      await _socketChannel.ready;
    } catch (e) {
      Get.rawSnackbar(message: 'Server connection lost. Retry connect...');
    }
  }

  void disconnect() {
    _timer.cancel();
    _socketChannel.sink.close();
    _listener.cancel();
  }

  // check if there is no ping for 3 seconds and signal a [onConnectionLost] if
  // there is no ping for more than 6 seconds
  void healthCheck(_) {
    if (_lastPing == null) {
      return;
    }
    if (DateTime.now().difference(_lastPing!) > const Duration(seconds: 6)) {
      disconnect();
      if (onConnectionLost != null) onConnectionLost!();
    }
  }

  // channelName being 'Chat' will be considered as 'ChatChannel',
  // 'Chat', { id: 1 } => { channel: 'ChatChannel', id: 1 }
  void subscribe(String channelName,
      {Map? channelParams,
      OnChannelSubscribedFunction? onSubscribed,
      OnChannelDisconnectedFunction? onDisconnected,
      OnChannelMessageFunction? onMessage}) {
    final channelId = encodeChannelId(channelName, channelParams);

    _onChannelSubscribedCallbacks[channelId] = onSubscribed;
    _onChannelDisconnectedCallbacks[channelId] = onDisconnected;
    _onChannelMessageCallbacks[channelId] = onMessage;

    _send({'identifier': channelId, 'command': 'subscribe'});
  }

  void unsubscribe(String channelName, {Map? channelParams}) {
    final channelId = encodeChannelId(channelName, channelParams);

    _onChannelSubscribedCallbacks[channelId] = null;
    _onChannelDisconnectedCallbacks[channelId] = null;
    _onChannelMessageCallbacks[channelId] = null;

    _socketChannel.sink
        .add(jsonEncode({'identifier': channelId, 'command': 'unsubscribe'}));
  }

  void performAction(String channelName,
      {String? action, Map? channelParams, Map? actionParams}) {
    final channelId = encodeChannelId(channelName, channelParams);

    actionParams ??= {};
    actionParams['action'] = action;

    _send({
      'identifier': channelId,
      'command': 'message',
      'data': jsonEncode(actionParams)
    });
  }

  void _onData(dynamic payload) {
    payload = jsonDecode(payload);

    if (payload['type'] != null) {
      _handleProtocolMessage(payload);
    } else {
      _handleDataMessage(payload);
    }
  }

  void _handleProtocolMessage(Map payload) {
    switch (payload['type']) {
      case 'ping':
        // rails sends epoch as seconds not miliseconds
        _lastPing =
            DateTime.fromMillisecondsSinceEpoch(payload['message'] * 1000);
        break;
      case 'welcome':
        if (onConnected != null) {
          onConnected!();
        }
        break;
      case 'disconnect':
        if (payload['identifier'] == null) {
          break;
        }
        final channelId = parseChannelId(payload['identifier']);
        final onDisconnected = _onChannelDisconnectedCallbacks[channelId];
        if (onDisconnected != null) {
          onDisconnected();
        }
        break;
      case 'confirm_subscription':
        final channelId = parseChannelId(payload['identifier']);
        final onSubscribed = _onChannelSubscribedCallbacks[channelId];
        if (onSubscribed != null) {
          onSubscribed();
        }
        break;
      case 'reject_subscription':
        // throw 'Unimplemented';
        break;
      default:
        throw 'InvalidMessage';
    }
  }

  void _handleDataMessage(Map payload) {
    final channelId = parseChannelId(payload['identifier']);
    final onMessage = _onChannelMessageCallbacks[channelId];
    if (onMessage != null) {
      onMessage(payload['message']);
    }
  }

  void _send(Map payload) {
    _socketChannel.sink.add(jsonEncode(payload));
  }
}
