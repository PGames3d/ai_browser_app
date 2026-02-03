import 'package:equatable/equatable.dart';

abstract class AiSummaryEvent extends Equatable {
  const AiSummaryEvent();

  @override
  List<Object?> get props => [];
}

// Summary Events
class GenerateSummaryEvent extends AiSummaryEvent {
  final String text;
  final String? sourceUrl;
  final String tabId;

  const GenerateSummaryEvent({
    required this.text,
    this.sourceUrl,
    required this.tabId,
  });

  @override
  List<Object?> get props => [text, sourceUrl, tabId];
}

class ClearSummaryEvent extends AiSummaryEvent {
  final String tabId;

  const ClearSummaryEvent({required this.tabId});

  @override
  List<Object?> get props => [tabId];
}

// Translation Events
class TranslateTextEvent extends AiSummaryEvent {
  final String text;
  final String targetLanguage;
  final String tabId;

  const TranslateTextEvent({
    required this.text,
    required this.targetLanguage,
    required this.tabId,
  });

  @override
  List<Object?> get props => [text, targetLanguage, tabId];
}

class ClearTranslationEvent extends AiSummaryEvent {
  final String tabId;

  const ClearTranslationEvent({required this.tabId});

  @override
  List<Object?> get props => [tabId];
}

class SelectLanguageEvent extends AiSummaryEvent {
  final String language;

  const SelectLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

// All Summaries Events
class LoadAllSummariesEvent extends AiSummaryEvent {
  const LoadAllSummariesEvent();
}

class AddSummaryToListEvent extends AiSummaryEvent {
  final dynamic summary;

  const AddSummaryToListEvent(this.summary);

  @override
  List<Object?> get props => [summary];
}

class RemoveSummaryFromListEvent extends AiSummaryEvent {
  final String id;

  const RemoveSummaryFromListEvent(this.id);

  @override
  List<Object?> get props => [id];
}
