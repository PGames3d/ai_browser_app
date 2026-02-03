import 'package:equatable/equatable.dart';
import '../../domain/entities/file_item.dart';

class FileManagerState extends Equatable {
  final List<FileItem> files;
  final FileItem? selectedFile;
  final bool isLoading;
  final String? error;

  const FileManagerState({
    this.files = const [],
    this.selectedFile,
    this.isLoading = false,
    this.error,
  });

  FileManagerState copyWith({
    List<FileItem>? files,
    FileItem? selectedFile,
    bool clearSelectedFile = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FileManagerState(
      files: files ?? this.files,
      selectedFile: clearSelectedFile ? null : (selectedFile ?? this.selectedFile),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [files, selectedFile, isLoading, error];
}
