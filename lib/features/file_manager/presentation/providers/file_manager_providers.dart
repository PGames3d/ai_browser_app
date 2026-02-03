import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/file_item.dart';
import '../../data/datasources/file_manager_local_datasource.dart';
import '../../data/datasources/file_manager_remote_datasource.dart';
import '../../data/repositories/file_manager_repository_impl.dart';
import '../../domain/repositories/file_manager_repository.dart';

// Data Sources
final fileManagerLocalDataSourceProvider = Provider<FileManagerLocalDataSourceImpl>((ref) {
  return FileManagerLocalDataSourceImpl();
});

final fileManagerRemoteDataSourceProvider = Provider<FileManagerRemoteDataSourceImpl>((ref) {
  return FileManagerRemoteDataSourceImpl();
});

// Repository
final fileManagerRepositoryProvider = Provider<FileManagerRepository>((ref) {
  final localDataSource = ref.watch(fileManagerLocalDataSourceProvider);
  final remoteDataSource = ref.watch(fileManagerRemoteDataSourceProvider);
  
  return FileManagerRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// File Manager State
class FileManagerNotifier extends StateNotifier<List<FileItem>> {
  FileManagerNotifier() : super([]);

  void loadFiles(List<FileItem> files) {
    state = files;
  }

  void addFile(FileItem file) {
    state = [file, ...state];
  }

  void removeFile(String id) {
    state = state.where((file) => file.id != id).toList();
  }

  void updateFile(FileItem updatedFile) {
    state = state.map((file) {
      if (file.id == updatedFile.id) {
        return updatedFile;
      }
      return file;
    }).toList();
  }
}

final fileManagerProvider = StateNotifierProvider<FileManagerNotifier, List<FileItem>>((ref) {
  return FileManagerNotifier();
});

// Selected File Provider
final selectedFileProvider = StateProvider<FileItem?>((ref) => null);

// File Loading State
final isLoadingFilesProvider = StateProvider<bool>((ref) => false);
