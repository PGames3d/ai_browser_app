class BrowserTab {
  final String id;
  final String url;
  final String title;
  final bool isActive;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final String? favicon;
  final DateTime? createdAt;
  final DateTime? lastVisited;

  const BrowserTab({
    required this.id,
    required this.url,
    required this.title,
    this.isActive = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.favicon,
    this.createdAt,
    this.lastVisited,
  });

  BrowserTab copyWith({
    String? id,
    String? url,
    String? title,
    bool? isActive,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    String? favicon,
    DateTime? createdAt,
    DateTime? lastVisited,
  }) {
    return BrowserTab(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      favicon: favicon ?? this.favicon,
      createdAt: createdAt ?? this.createdAt,
      lastVisited: lastVisited ?? this.lastVisited,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'isActive': isActive,
      'progress': progress,
      'canGoBack': canGoBack,
      'canGoForward': canGoForward,
      'favicon': favicon,
      'createdAt': createdAt?.toIso8601String(),
      'lastVisited': lastVisited?.toIso8601String(),
    };
  }

  factory BrowserTab.fromJson(Map<String, dynamic> json) {
    return BrowserTab(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      isActive: json['isActive'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      canGoBack: json['canGoBack'] as bool? ?? false,
      canGoForward: json['canGoForward'] as bool? ?? false,
      favicon: json['favicon'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastVisited: json['lastVisited'] != null
          ? DateTime.parse(json['lastVisited'] as String)
          : null,
    );
  }
}
