class Skill {
  final int id;
  final String name;
  final String description;
  final String actionDesc;

  Skill(this.id, this.name, this.description, this.actionDesc);

  Skill.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        actionDesc = json['action_desc'];
}
