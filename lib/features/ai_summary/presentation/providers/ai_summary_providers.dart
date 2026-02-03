import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/summary.dart';
import '../../domain/entities/translation.dart';
import '../../data/datasources/ai_summary_local_datasource.dart';
import '../../data/datasources/ai_summary_remote_datasource.dart';
import '../../data/repositories/ai_summary_repository_impl.dart';
import '../../domain/repositories/ai_summary_repository.dart';
import '../../../../core/providers/core_providers.dart';

// Data Sources
final aiSummaryLocalDataSourceProvider =
    Provider<AiSummaryLocalDataSourceImpl>((ref) {
  return AiSummaryLocalDataSourceImpl();
});

final aiSummaryRemoteDataSourceProvider =
    Provider<AiSummaryRemoteDataSourceImpl>((ref) {
  final dio = ref.watch(dioProvider);
  return AiSummaryRemoteDataSourceImpl(dio);
});

// Repository
final aiSummaryRepositoryProvider = Provider<AiSummaryRepository>((ref) {
  final localDataSource = ref.watch(aiSummaryLocalDataSourceProvider);
  final remoteDataSource = ref.watch(aiSummaryRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return AiSummaryRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Summary State
class SummaryNotifier extends StateNotifier<AsyncValue<Summary?>> {
  final AiSummaryRepository repository;

  SummaryNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> generateSummary(String text, {String? sourceUrl}) async {
    state = const AsyncValue.loading();

    final result = await repository.generateSummary(text, sourceUrl: sourceUrl);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (summary) => state = AsyncValue.data(summary),
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

// Global summary provider (for backward compatibility)
final summaryProvider =
    StateNotifierProvider<SummaryNotifier, AsyncValue<Summary?>>((ref) {
  final repository = ref.watch(aiSummaryRepositoryProvider);
  return SummaryNotifier(repository);
});

// Per-tab summary provider - each tab has its own summary
final tabSummaryProvider =
    StateNotifierProvider.family<SummaryNotifier, AsyncValue<Summary?>, String>(
        (ref, tabId) {
  final repository = ref.watch(aiSummaryRepositoryProvider);
  return SummaryNotifier(repository);
});

// Translation State
class TranslationNotifier extends StateNotifier<AsyncValue<Translation?>> {
  final AiSummaryRepository repository;

  TranslationNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> translate(String text, String targetLanguage) async {
    state = const AsyncValue.loading();

    final result = await repository.translateText(text, targetLanguage);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (translation) => state = AsyncValue.data(translation),
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final translationProvider =
    StateNotifierProvider<TranslationNotifier, AsyncValue<Translation?>>((ref) {
  final repository = ref.watch(aiSummaryRepositoryProvider);
  return TranslationNotifier(repository);
});

// Per-tab translation provider
final tabTranslationProvider = StateNotifierProvider.family<TranslationNotifier,
    AsyncValue<Translation?>, String>((ref, tabId) {
  final repository = ref.watch(aiSummaryRepositoryProvider);
  return TranslationNotifier(repository);
});

// All Summaries Provider
class AllSummariesNotifier extends StateNotifier<List<Summary>> {
  AllSummariesNotifier() : super([]);

  void loadSummaries(List<Summary> summaries) {
    state = summaries;
  }

  void addSummary(Summary summary) {
    state = [summary, ...state];
  }

  void removeSummary(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final allSummariesProvider =
    StateNotifierProvider<AllSummariesNotifier, List<Summary>>((ref) {
  return AllSummariesNotifier();
});

// Selected Language Provider
final selectedLanguageProvider = StateProvider<String>((ref) => 'es');

// Is Summarizing Provider
final isSummarizingProvider = StateProvider<bool>((ref) => false);

// Is Translating Provider
final isTranslatingProvider = StateProvider<bool>((ref) => false);
