class CommandModel {
  List<SlashCommands>? slashCommands;

  CommandModel({this.slashCommands});

  CommandModel.fromJson(Map<String, dynamic> json) {
    if (json['slash_commands'] != null) {
      slashCommands = <SlashCommands>[];
      json['slash_commands'].forEach((v) {
        slashCommands!.add(SlashCommands.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (slashCommands != null) {
      data['slash_commands'] = slashCommands!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SlashCommands {
  int? id;
  String? name;
  String? description;
  int? botId;
  String? createdAt;

  SlashCommands(
      {this.id, this.name, this.description, this.botId, this.createdAt});

  SlashCommands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    botId = json['bot_id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['bot_id'] = botId;
    data['created_at'] = createdAt;
    return data;
  }
}
