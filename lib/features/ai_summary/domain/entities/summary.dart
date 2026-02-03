import 'package:equatable/equatable.dart';

class Summary extends Equatable {
  final String id;
  final String originalText;
  final String summarizedText;
  final int originalWordCount;
  final int summarizedWordCount;
  final DateTime createdAt;
  final String? sourceUrl;
  final String? fileId;
  final Map<String, String>? translations;

  const Summary({
    required this.id,
    required this.originalText,
    required this.summarizedText,
    required this.originalWordCount,
    required this.summarizedWordCount,
    required this.createdAt,
    this.sourceUrl,
    this.fileId,
    this.translations,
  });

  @override
  List<Object?> get props => [
        id,
        originalText,
        summarizedText,
        originalWordCount,
        summarizedWordCount,
        createdAt,
        sourceUrl,
        fileId,
        translations,
      ];

  Summary copyWith({
    String? id,
    String? originalText,
    String? summarizedText,
    int? originalWordCount,
    int? summarizedWordCount,
    DateTime? createdAt,
    String? sourceUrl,
    String? fileId,
    Map<String, String>? translations,
  }) {
    return Summary(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      summarizedText: summarizedText ?? this.summarizedText,
      originalWordCount: originalWordCount ?? this.originalWordCount,
      summarizedWordCount: summarizedWordCount ?? this.summarizedWordCount,
      createdAt: createdAt ?? this.createdAt,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      fileId: fileId ?? this.fileId,
      translations: translations ?? this.translations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalText': originalText,
      'summarizedText': summarizedText,
      'originalWordCount': originalWordCount,
      'summarizedWordCount': summarizedWordCount,
      'createdAt': createdAt.toIso8601String(),
      'sourceUrl': sourceUrl,
      'fileId': fileId,
      'translations': translations,
    };
  }

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      summarizedText: json['summarizedText'] as String,
      originalWordCount: json['originalWordCount'] as int,
      summarizedWordCount: json['summarizedWordCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sourceUrl: json['sourceUrl'] as String?,
      fileId: json['fileId'] as String?,
      translations: json['translations'] != null
          ? Map<String, String>.from(json['translations'] as Map)
          : null,
    );
  }
}
