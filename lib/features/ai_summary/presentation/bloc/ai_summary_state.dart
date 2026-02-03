import 'package:equatable/equatable.dart';
import '../../domain/entities/summary.dart';
import '../../domain/entities/translation.dart';

class AiSummaryState extends Equatable {
  // Per-tab summaries: Map<tabId, SummaryResult>
  final Map<String, SummaryResult> tabSummaries;
  // Per-tab translations: Map<tabId, TranslationResult>
  final Map<String, TranslationResult> tabTranslations;
  // All summaries list
  final List<Summary> allSummaries;
  // Selected language
  final String selectedLanguage;
  // Loading states
  final bool isSummarizing;
  final bool isTranslating;

  const AiSummaryState({
    this.tabSummaries = const {},
    this.tabTranslations = const {},
    this.allSummaries = const [],
    this.selectedLanguage = 'es',
    this.isSummarizing = false,
    this.isTranslating = false,
  });

  AiSummaryState copyWith({
    Map<String, SummaryResult>? tabSummaries,
    Map<String, TranslationResult>? tabTranslations,
    List<Summary>? allSummaries,
    String? selectedLanguage,
    bool? isSummarizing,
    bool? isTranslating,
  }) {
    return AiSummaryState(
      tabSummaries: tabSummaries ?? this.tabSummaries,
      tabTranslations: tabTranslations ?? this.tabTranslations,
      allSummaries: allSummaries ?? this.allSummaries,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      isTranslating: isTranslating ?? this.isTranslating,
    );
  }

  @override
  List<Object?> get props => [
        tabSummaries,
        tabTranslations,
        allSummaries,
        selectedLanguage,
        isSummarizing,
        isTranslating,
      ];
}

// Helper classes for per-tab results
class SummaryResult extends Equatable {
  final Summary? summary;
  final bool isLoading;
  final String? error;

  const SummaryResult({
    this.summary,
    this.isLoading = false,
    this.error,
  });

  const SummaryResult.initial() : summary = null, isLoading = false, error = null;
  const SummaryResult.loading() : summary = null, isLoading = true, error = null;
  SummaryResult.success(Summary this.summary) : isLoading = false, error = null;
  SummaryResult.failure(String this.error) : summary = null, isLoading = false;

  @override
  List<Object?> get props => [summary, isLoading, error];
}

class TranslationResult extends Equatable {
  final Translation? translation;
  final bool isLoading;
  final String? error;

  const TranslationResult({
    this.translation,
    this.isLoading = false,
    this.error,
  });

  const TranslationResult.initial() : translation = null, isLoading = false, error = null;
  const TranslationResult.loading() : translation = null, isLoading = true, error = null;
  TranslationResult.success(Translation this.translation) : isLoading = false, error = null;
  TranslationResult.failure(String this.error) : translation = null, isLoading = false;

  @override
  List<Object?> get props => [translation, isLoading, error];
}
