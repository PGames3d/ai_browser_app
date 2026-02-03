import 'package:dartz/dartz.dart';
import '../entities/summary.dart';
import '../entities/translation.dart';
import '../../../../core/errors/failures.dart';

abstract class AiSummaryRepository {
  Future<Either<Failure, Summary>> generateSummary(String text, {String? sourceUrl});
  Future<Either<Failure, Translation>> translateText(
    String text,
    String targetLanguage, {
    String sourceLanguage = 'en',
  });
  
  Future<Either<Failure, List<Summary>>> getAllSummaries();
  Future<Either<Failure, Summary>> getSummary(String id);
  Future<Either<Failure, void>> saveSummary(Summary summary);
  Future<Either<Failure, void>> deleteSummary(String id);
}
