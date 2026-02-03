import 'package:hive/hive.dart';
import '../../domain/entities/file_item.dart';

class FileItemModel extends HiveObject {
  final String id;
  final String name;
  final String path;
  final String type;
  final int size;
  final DateTime downloadedAt;
  final String? url;
  final String? summary;
  final bool? isSummarized;

  FileItemModel({
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

  factory FileItemModel.fromEntity(FileItem file) {
    return FileItemModel(
      id: file.id,
      name: file.name,
      path: file.path,
      type: file.type,
      size: file.size,
      downloadedAt: file.downloadedAt,
      url: file.url,
      summary: file.summary,
      isSummarized: file.isSummarized,
    );
  }

  FileItem toEntity() {
    return FileItem(
      id: id,
      name: name,
      path: path,
      type: type,
      size: size,
      downloadedAt: downloadedAt,
      url: url,
      summary: summary,
      isSummarized: isSummarized,
    );
  }
}

class FileItemModelAdapter extends TypeAdapter<FileItemModel> {
  @override
  final int typeId = 2;

  @override
  FileItemModel read(BinaryReader reader) {
    return FileItemModel(
      id: reader.readString(),
      name: reader.readString(),
      path: reader.readString(),
      type: reader.readString(),
      size: reader.readInt(),
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      url: reader.read() as String?,
      summary: reader.read() as String?,
      isSummarized: reader.read() as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, FileItemModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.path);
    writer.writeString(obj.type);
    writer.writeInt(obj.size);
    writer.writeInt(obj.downloadedAt.millisecondsSinceEpoch);
    writer.write(obj.url);
    writer.write(obj.summary);
    writer.write(obj.isSummarized);
  }
}
