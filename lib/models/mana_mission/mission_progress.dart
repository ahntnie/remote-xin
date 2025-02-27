class MissionProgress {
  MissionProgress({
    this.accomplished,
    this.total,
  });

  MissionProgress.fromJson(dynamic json) {
    accomplished = json['accomplished'];
    total = json['total'];
  }

  int? accomplished;
  int? total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accomplished'] = accomplished;
    map['total'] = total;
    return map;
  }
}
