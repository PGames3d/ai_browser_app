import 'package:equatable/equatable.dart';

class Translation extends Equatable {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;

  const Translation({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        createdAt,
      ];

  Translation copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
  }) {
    return Translation(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
