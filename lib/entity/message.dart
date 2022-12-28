class Message {
  final String content;
  final String charName;
  final int map;

  Message(this.content, this.charName, this.map);

  Message.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        charName = json['char_name'],
        map = json['map'];

  Map<String, dynamic> toJson() => {
        'content': content,
        'char_name': charName,
        'map': map
      };
}
