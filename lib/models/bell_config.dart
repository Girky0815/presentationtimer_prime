class BellConfig {
  final int id;
  int min;
  int sec;
  int count;

  BellConfig(
      {required this.id, required this.min, required this.sec, this.count = 1});

  int get totalSeconds => min * 60 + sec;

  Map<String, dynamic> toJson() => {
        'id': id,
        'min': min,
        'sec': sec,
        'count': count,
      };

  factory BellConfig.fromJson(Map<String, dynamic> json) {
    return BellConfig(
      id: json['id'],
      min: json['min'],
      sec: json['sec'],
      count: json['count'] ?? 1,
    );
  }
}
