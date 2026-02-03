import 'package:dartz/dartz.dart';
import '../entities/file_item.dart';
import '../../../../core/errors/failures.dart';

abstract class FileManagerRepository {
  Future<Either<Failure, List<FileItem>>> getAllFiles();
  Future<Either<Failure, FileItem>> getFile(String id);
  Future<Either<Failure, FileItem>> saveFile(FileItem file);
  Future<Either<Failure, void>> deleteFile(String id);
  Future<Either<Failure, FileItem>> pickFile();
  Future<Either<Failure, String>> extractTextFromFile(String filePath);
}
