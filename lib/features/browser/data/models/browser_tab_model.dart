import 'package:hive/hive.dart';
import '../../domain/entities/browser_tab.dart';

class BrowserTabModel extends HiveObject {
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

  BrowserTabModel({
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

  factory BrowserTabModel.fromEntity(BrowserTab tab) {
    return BrowserTabModel(
      id: tab.id,
      url: tab.url,
      title: tab.title,
      isActive: tab.isActive,
      progress: tab.progress,
      canGoBack: tab.canGoBack,
      canGoForward: tab.canGoForward,
      favicon: tab.favicon,
      createdAt: tab.createdAt,
      lastVisited: tab.lastVisited,
    );
  }

  BrowserTab toEntity() {
    return BrowserTab(
      id: id,
      url: url,
      title: title,
      isActive: isActive,
      progress: progress,
      canGoBack: canGoBack,
      canGoForward: canGoForward,
      favicon: favicon,
      createdAt: createdAt,
      lastVisited: lastVisited,
    );
  }
}

class BrowserTabModelAdapter extends TypeAdapter<BrowserTabModel> {
  @override
  final int typeId = 0;

  @override
  BrowserTabModel read(BinaryReader reader) {
    return BrowserTabModel(
      id: reader.readString(),
      url: reader.readString(),
      title: reader.readString(),
      isActive: reader.readBool(),
      progress: reader.readDouble(),
      canGoBack: reader.readBool(),
      canGoForward: reader.readBool(),
      favicon: reader.read() as String?,
      createdAt: reader.read() as DateTime?,
      lastVisited: reader.read() as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BrowserTabModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.url);
    writer.writeString(obj.title);
    writer.writeBool(obj.isActive);
    writer.writeDouble(obj.progress);
    writer.writeBool(obj.canGoBack);
    writer.writeBool(obj.canGoForward);
    writer.write(obj.favicon);
    writer.write(obj.createdAt);
    writer.write(obj.lastVisited);
  }
}
