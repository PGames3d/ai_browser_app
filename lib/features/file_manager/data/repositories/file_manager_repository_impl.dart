import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/file_item.dart';
import '../../domain/repositories/file_manager_repository.dart';
import '../datasources/file_manager_local_datasource.dart';
import '../datasources/file_manager_remote_datasource.dart';
import '../models/file_item_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

class FileManagerRepositoryImpl implements FileManagerRepository {
  final FileManagerLocalDataSource localDataSource;
  final FileManagerRemoteDataSource remoteDataSource;

  FileManagerRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<FileItem>>> getAllFiles() async {
    try {
      final files = await localDataSource.getAllFiles();
      return Right(files.map((file) => file.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileItem>> getFile(String id) async {
    try {
      final file = await localDataSource.getFile(id);
      if (file != null) {
        return Right(file.toEntity());
      }
      return const Left(CacheFailure('File not found'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileItem>> saveFile(FileItem file) async {
    try {
      await localDataSource.saveFile(FileItemModel.fromEntity(file));
      return Right(file);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String id) async {
    try {
      await localDataSource.deleteFile(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileItem>> pickFile() async {
    try {
      final result = await remoteDataSource.pickFile();
      
      if (result == null || result.files.isEmpty) {
        return const Left(FileNotFoundFailure('No file selected'));
      }

      final pickedFile = result.files.first;
      final fileItem = FileItem(
        id: const Uuid().v4(),
        name: pickedFile.name,
        path: pickedFile.path ?? '',
        type: pickedFile.extension ?? '',
        size: pickedFile.size,
        downloadedAt: DateTime.now(),
        isSummarized: false,
      );

      await localDataSource.saveFile(FileItemModel.fromEntity(fileItem));
      return Right(fileItem);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> extractTextFromFile(String filePath) async {
    try {
      final extension = filePath.split('.').last.toLowerCase();
      
      String text;
      switch (extension) {
        case 'txt':
          text = await remoteDataSource.extractTextFromTxt(filePath);
          break;
        case 'pdf':
          text = await remoteDataSource.extractTextFromPdf(filePath);
          break;
        case 'docx':
          text = await remoteDataSource.extractTextFromDocx(filePath);
          break;
        default:
          return Left(FileNotFoundFailure('Unsupported file type: $extension'));
      }

      return Right(text);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
