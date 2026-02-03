import 'package:equatable/equatable.dart';
import '../../domain/entities/file_item.dart';

abstract class FileManagerEvent extends Equatable {
  const FileManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadFilesEvent extends FileManagerEvent {
  const LoadFilesEvent();
}

class AddFileEvent extends FileManagerEvent {
  final FileItem file;

  const AddFileEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class RemoveFileEvent extends FileManagerEvent {
  final String id;

  const RemoveFileEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateFileEvent extends FileManagerEvent {
  final FileItem file;

  const UpdateFileEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class PickFileEvent extends FileManagerEvent {
  const PickFileEvent();
}

class SelectFileEvent extends FileManagerEvent {
  final FileItem? file;

  const SelectFileEvent(this.file);

  @override
  List<Object?> get props => [file];
}

class SetLoadingEvent extends FileManagerEvent {
  final bool isLoading;

  const SetLoadingEvent(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}
