import 'package:hive/hive.dart';
import '../models/summary_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AiSummaryLocalDataSource {
  Future<List<SummaryModel>> getAllSummaries();
  Future<SummaryModel?> getSummary(String id);
  Future<void> saveSummary(SummaryModel summary);
  Future<void> deleteSummary(String id);
}

class AiSummaryLocalDataSourceImpl implements AiSummaryLocalDataSource {
  Box<SummaryModel>? _summariesBox;

  Future<Box<SummaryModel>> get summariesBox async {
    _summariesBox ??= await Hive.openBox<SummaryModel>(AppConstants.summariesBoxName);
    return _summariesBox!;
  }

  @override
  Future<List<SummaryModel>> getAllSummaries() async {
    final box = await summariesBox;
    final summaries = box.values.toList();
    summaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return summaries;
  }

  @override
  Future<SummaryModel?> getSummary(String id) async {
    final box = await summariesBox;
    return box.get(id);
  }

  @override
  Future<void> saveSummary(SummaryModel summary) async {
    final box = await summariesBox;
    await box.put(summary.id, summary);
  }

  @override
  Future<void> deleteSummary(String id) async {
    final box = await summariesBox;
    await box.delete(id);
  }
}
