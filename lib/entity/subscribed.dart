class Subscribed {
  final String channel;
  final Map<String, dynamic>? params;
  final Function onMessage;

  Subscribed(this.channel, this.params, this.onMessage);
}
