import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/summary.dart';
import '../../domain/entities/translation.dart';
import '../../domain/repositories/ai_summary_repository.dart';
import '../datasources/ai_summary_local_datasource.dart';
import '../datasources/ai_summary_remote_datasource.dart';
import '../models/summary_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';

class AiSummaryRepositoryImpl implements AiSummaryRepository {
  final AiSummaryLocalDataSource localDataSource;
  final AiSummaryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AiSummaryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Summary>> generateSummary(
    String text, {
    String? sourceUrl,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final summarizedText = await remoteDataSource.generateSummary(text);
      
      final summary = Summary(
        id: const Uuid().v4(),
        originalText: text,
        summarizedText: summarizedText,
        originalWordCount: text.split(' ').length,
        summarizedWordCount: summarizedText.split(' ').length,
        createdAt: DateTime.now(),
        sourceUrl: sourceUrl,
      );

      await localDataSource.saveSummary(SummaryModel.fromEntity(summary));
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Translation>> translateText(
    String text,
    String targetLanguage, {
    String sourceLanguage = 'en',
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final translatedText = await remoteDataSource.translateText(
        text,
        targetLanguage,
        sourceLanguage,
      );

      final translation = Translation(
        id: const Uuid().v4(),
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        createdAt: DateTime.now(),
      );

      return Right(translation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Summary>>> getAllSummaries() async {
    try {
      final summaries = await localDataSource.getAllSummaries();
      return Right(summaries.map((s) => s.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Summary>> getSummary(String id) async {
    try {
      final summary = await localDataSource.getSummary(id);
      if (summary != null) {
        return Right(summary.toEntity());
      }
      return const Left(CacheFailure('Summary not found'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSummary(Summary summary) async {
    try {
      await localDataSource.saveSummary(SummaryModel.fromEntity(summary));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSummary(String id) async {
    try {
      await localDataSource.deleteSummary(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
