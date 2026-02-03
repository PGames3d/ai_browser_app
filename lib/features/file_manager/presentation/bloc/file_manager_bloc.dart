import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/file_manager_repository.dart';
import 'file_manager_event.dart';
import 'file_manager_state.dart';

class FileManagerBloc extends Bloc<FileManagerEvent, FileManagerState> {
  final FileManagerRepository repository;

  FileManagerBloc({required this.repository}) : super(const FileManagerState()) {
    on<LoadFilesEvent>(_onLoadFiles);
    on<AddFileEvent>(_onAddFile);
    on<RemoveFileEvent>(_onRemoveFile);
    on<UpdateFileEvent>(_onUpdateFile);
    on<PickFileEvent>(_onPickFile);
    on<SelectFileEvent>(_onSelectFile);
    on<SetLoadingEvent>(_onSetLoading);
  }

  Future<void> _onLoadFiles(
    LoadFilesEvent event,
    Emitter<FileManagerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await repository.getAllFiles();
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (files) => emit(state.copyWith(
        files: files,
        isLoading: false,
        clearError: true,
      )),
    );
  }

  void _onAddFile(AddFileEvent event, Emitter<FileManagerState> emit) {
    emit(state.copyWith(
      files: [event.file, ...state.files],
    ));
  }

  void _onRemoveFile(RemoveFileEvent event, Emitter<FileManagerState> emit) {
    emit(state.copyWith(
      files: state.files.where((file) => file.id != event.id).toList(),
    ));
  }

  void _onUpdateFile(UpdateFileEvent event, Emitter<FileManagerState> emit) {
    emit(state.copyWith(
      files: state.files.map((file) {
        if (file.id == event.file.id) {
          return event.file;
        }
        return file;
      }).toList(),
    ));
  }

  Future<void> _onPickFile(
    PickFileEvent event,
    Emitter<FileManagerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await repository.pickFile();
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (file) => emit(state.copyWith(
        files: [file, ...state.files],
        isLoading: false,
        clearError: true,
      )),
    );
  }

  void _onSelectFile(SelectFileEvent event, Emitter<FileManagerState> emit) {
    if (event.file == null) {
      emit(state.copyWith(clearSelectedFile: true));
    } else {
      emit(state.copyWith(selectedFile: event.file));
    }
  }

  void _onSetLoading(SetLoadingEvent event, Emitter<FileManagerState> emit) {
    emit(state.copyWith(isLoading: event.isLoading));
  }
}
