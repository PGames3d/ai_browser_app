import 'package:hive/hive.dart';
import '../models/file_item_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class FileManagerLocalDataSource {
  Future<List<FileItemModel>> getAllFiles();
  Future<FileItemModel?> getFile(String id);
  Future<void> saveFile(FileItemModel file);
  Future<void> deleteFile(String id);
}

class FileManagerLocalDataSourceImpl implements FileManagerLocalDataSource {
  Box<FileItemModel>? _filesBox;

  Future<Box<FileItemModel>> get filesBox async {
    _filesBox ??= await Hive.openBox<FileItemModel>(AppConstants.filesBoxName);
    return _filesBox!;
  }

  @override
  Future<List<FileItemModel>> getAllFiles() async {
    final box = await filesBox;
    final files = box.values.toList();
    files.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return files;
  }

  @override
  Future<FileItemModel?> getFile(String id) async {
    final box = await filesBox;
    return box.get(id);
  }

  @override
  Future<void> saveFile(FileItemModel file) async {
    final box = await filesBox;
    await box.put(file.id, file);
  }

  @override
  Future<void> deleteFile(String id) async {
    final box = await filesBox;
    await box.delete(id);
  }
}
