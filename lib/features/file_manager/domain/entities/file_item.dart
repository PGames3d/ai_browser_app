class FileItem {
  final String id;
  final String name;
  final String path;
  final String type;
  final int size;
  final DateTime downloadedAt;
  final String? url;
  final String? summary;
  final bool? isSummarized;

  const FileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.downloadedAt,
    this.url,
    this.summary,
    this.isSummarized,
  });

  FileItem copyWith({
    String? id,
    String? name,
    String? path,
    String? type,
    int? size,
    DateTime? downloadedAt,
    String? url,
    String? summary,
    bool? isSummarized,
  }) {
    return FileItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      size: size ?? this.size,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      url: url ?? this.url,
      summary: summary ?? this.summary,
      isSummarized: isSummarized ?? this.isSummarized,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'downloadedAt': downloadedAt.toIso8601String(),
      'url': url,
      'summary': summary,
      'isSummarized': isSummarized,
    };
  }

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      url: json['url'] as String?,
      summary: json['summary'] as String?,
      isSummarized: json['isSummarized'] as bool?,
    );
  }
}
