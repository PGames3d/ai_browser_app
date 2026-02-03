import 'package:hive/hive.dart';
import '../../domain/entities/history_item.dart';

class HistoryItemModel extends HiveObject {
  final String id;
  final String url;
  final String title;
  final DateTime visitedAt;
  final String? favicon;
  final int? visitCount;

  HistoryItemModel({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
    this.favicon,
    this.visitCount,
  });

  factory HistoryItemModel.fromEntity(HistoryItem item) {
    return HistoryItemModel(
      id: item.id,
      url: item.url,
      title: item.title,
      visitedAt: item.visitedAt,
      favicon: item.favicon,
      visitCount: item.visitCount,
    );
  }

  HistoryItem toEntity() {
    return HistoryItem(
      id: id,
      url: url,
      title: title,
      visitedAt: visitedAt,
      favicon: favicon,
      visitCount: visitCount,
    );
  }
}

class HistoryItemModelAdapter extends TypeAdapter<HistoryItemModel> {
  @override
  final int typeId = 1;

  @override
  HistoryItemModel read(BinaryReader reader) {
    return HistoryItemModel(
      id: reader.readString(),
      url: reader.readString(),
      title: reader.readString(),
      visitedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      favicon: reader.read() as String?,
      visitCount: reader.read() as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItemModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.url);
    writer.writeString(obj.title);
    writer.writeInt(obj.visitedAt.millisecondsSinceEpoch);
    writer.write(obj.favicon);
    writer.write(obj.visitCount);
  }
}
