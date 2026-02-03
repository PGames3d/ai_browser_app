import 'package:hive/hive.dart';
import '../../domain/entities/summary.dart';

class SummaryModel extends HiveObject {
  final String id;
  final String originalText;
  final String summarizedText;
  final int originalWordCount;
  final int summarizedWordCount;
  final DateTime createdAt;
  final String? sourceUrl;
  final String? fileId;
  final Map<String, String>? translations;

  SummaryModel({
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

  factory SummaryModel.fromEntity(Summary summary) {
    return SummaryModel(
      id: summary.id,
      originalText: summary.originalText,
      summarizedText: summary.summarizedText,
      originalWordCount: summary.originalWordCount,
      summarizedWordCount: summary.summarizedWordCount,
      createdAt: summary.createdAt,
      sourceUrl: summary.sourceUrl,
      fileId: summary.fileId,
      translations: summary.translations,
    );
  }

  Summary toEntity() {
    return Summary(
      id: id,
      originalText: originalText,
      summarizedText: summarizedText,
      originalWordCount: originalWordCount,
      summarizedWordCount: summarizedWordCount,
      createdAt: createdAt,
      sourceUrl: sourceUrl,
      fileId: fileId,
      translations: translations,
    );
  }
}

class SummaryModelAdapter extends TypeAdapter<SummaryModel> {
  @override
  final int typeId = 3;

  @override
  SummaryModel read(BinaryReader reader) {
    return SummaryModel(
      id: reader.readString(),
      originalText: reader.readString(),
      summarizedText: reader.readString(),
      originalWordCount: reader.readInt(),
      summarizedWordCount: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      sourceUrl: reader.read() as String?,
      fileId: reader.read() as String?,
      translations: reader.read() as Map<String, String>?,
    );
  }

  @override
  void write(BinaryWriter writer, SummaryModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.originalText);
    writer.writeString(obj.summarizedText);
    writer.writeInt(obj.originalWordCount);
    writer.writeInt(obj.summarizedWordCount);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.write(obj.sourceUrl);
    writer.write(obj.fileId);
    writer.write(obj.translations);
  }
}
