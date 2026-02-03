import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/ai_summary_repository.dart';
import 'ai_summary_event.dart';
import 'ai_summary_state.dart';

class AiSummaryBloc extends Bloc<AiSummaryEvent, AiSummaryState> {
  final AiSummaryRepository repository;

  AiSummaryBloc({required this.repository}) : super(const AiSummaryState()) {
    on<GenerateSummaryEvent>(_onGenerateSummary);
    on<ClearSummaryEvent>(_onClearSummary);
    on<TranslateTextEvent>(_onTranslateText);
    on<ClearTranslationEvent>(_onClearTranslation);
    on<SelectLanguageEvent>(_onSelectLanguage);
    on<LoadAllSummariesEvent>(_onLoadAllSummaries);
    on<AddSummaryToListEvent>(_onAddSummaryToList);
    on<RemoveSummaryFromListEvent>(_onRemoveSummaryFromList);
  }

  Future<void> _onGenerateSummary(
    GenerateSummaryEvent event,
    Emitter<AiSummaryState> emit,
  ) async {
    // Set loading state for this tab
    final updatedSummaries = Map<String, SummaryResult>.from(state.tabSummaries);
    updatedSummaries[event.tabId] = const SummaryResult.loading();
    emit(state.copyWith(tabSummaries: updatedSummaries, isSummarizing: true));

    final result = await repository.generateSummary(
      event.text,
      sourceUrl: event.sourceUrl,
    );

    result.fold(
      (failure) {
        final updated = Map<String, SummaryResult>.from(state.tabSummaries);
        updated[event.tabId] = SummaryResult.failure(failure.message);
        emit(state.copyWith(tabSummaries: updated, isSummarizing: false));
      },
      (summary) {
        final updated = Map<String, SummaryResult>.from(state.tabSummaries);
        updated[event.tabId] = SummaryResult.success(summary);
        emit(state.copyWith(
          tabSummaries: updated,
          isSummarizing: false,
          allSummaries: [summary, ...state.allSummaries],
        ));
      },
    );
  }

  void _onClearSummary(
    ClearSummaryEvent event,
    Emitter<AiSummaryState> emit,
  ) {
    final updatedSummaries = Map<String, SummaryResult>.from(state.tabSummaries);
    updatedSummaries[event.tabId] = const SummaryResult.initial();
    emit(state.copyWith(tabSummaries: updatedSummaries));
  }

  Future<void> _onTranslateText(
    TranslateTextEvent event,
    Emitter<AiSummaryState> emit,
  ) async {
    // Set loading state for this tab
    final updatedTranslations = Map<String, TranslationResult>.from(state.tabTranslations);
    updatedTranslations[event.tabId] = const TranslationResult.loading();
    emit(state.copyWith(tabTranslations: updatedTranslations, isTranslating: true));

    final result = await repository.translateText(
      event.text,
      event.targetLanguage,
    );

    result.fold(
      (failure) {
        final updated = Map<String, TranslationResult>.from(state.tabTranslations);
        updated[event.tabId] = TranslationResult.failure(failure.message);
        emit(state.copyWith(tabTranslations: updated, isTranslating: false));
      },
      (translation) {
        final updated = Map<String, TranslationResult>.from(state.tabTranslations);
        updated[event.tabId] = TranslationResult.success(translation);
        emit(state.copyWith(tabTranslations: updated, isTranslating: false));
      },
    );
  }

  void _onClearTranslation(
    ClearTranslationEvent event,
    Emitter<AiSummaryState> emit,
  ) {
    final updatedTranslations = Map<String, TranslationResult>.from(state.tabTranslations);
    updatedTranslations[event.tabId] = const TranslationResult.initial();
    emit(state.copyWith(tabTranslations: updatedTranslations));
  }

  void _onSelectLanguage(
    SelectLanguageEvent event,
    Emitter<AiSummaryState> emit,
  ) {
    emit(state.copyWith(selectedLanguage: event.language));
  }

  Future<void> _onLoadAllSummaries(
    LoadAllSummariesEvent event,
    Emitter<AiSummaryState> emit,
  ) async {
    final result = await repository.getAllSummaries();
    result.fold(
      (failure) {
        // Handle error silently for now
      },
      (summaries) {
        emit(state.copyWith(allSummaries: summaries));
      },
    );
  }

  void _onAddSummaryToList(
    AddSummaryToListEvent event,
    Emitter<AiSummaryState> emit,
  ) {
    emit(state.copyWith(allSummaries: [event.summary, ...state.allSummaries]));
  }

  void _onRemoveSummaryFromList(
    RemoveSummaryFromListEvent event,
    Emitter<AiSummaryState> emit,
  ) {
    emit(state.copyWith(
      allSummaries: state.allSummaries.where((s) => s.id != event.id).toList(),
    ));
  }
}
