class HistoryItem {
  final String id;
  final String url;
  final String title;
  final DateTime visitedAt;
  final String? favicon;
  final int? visitCount;

  const HistoryItem({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
    this.favicon,
    this.visitCount,
  });

  HistoryItem copyWith({
    String? id,
    String? url,
    String? title,
    DateTime? visitedAt,
    String? favicon,
    int? visitCount,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      visitedAt: visitedAt ?? this.visitedAt,
      favicon: favicon ?? this.favicon,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'visitedAt': visitedAt.toIso8601String(),
      'favicon': favicon,
      'visitCount': visitCount,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      visitedAt: DateTime.parse(json['visitedAt'] as String),
      favicon: json['favicon'] as String?,
      visitCount: json['visitCount'] as int?,
    );
  }
}
