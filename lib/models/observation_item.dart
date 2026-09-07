class ObservationItem {
  final String title;
  final String description;
  final String location; // e.g. "画面左下角", "中央主体区域", "背景右上侧"

  const ObservationItem({
    required this.title,
    required this.description,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
    };
  }

  factory ObservationItem.fromJson(Map<String, dynamic> json) {
    return ObservationItem(
      title: json['title'] as String? ?? '关键特征',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '全局区域',
    );
  }
}
