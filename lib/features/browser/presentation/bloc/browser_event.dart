import 'package:equatable/equatable.dart';

abstract class BrowserEvent extends Equatable {
  const BrowserEvent();

  @override
  List<Object?> get props => [];
}

// Tab Events
class LoadTabsEvent extends BrowserEvent {
  const LoadTabsEvent();
}

class CreateTabEvent extends BrowserEvent {
  final String? url;

  const CreateTabEvent({this.url});

  @override
  List<Object?> get props => [url];
}

class CloseTabEvent extends BrowserEvent {
  final String id;

  const CloseTabEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CloseAllTabsEvent extends BrowserEvent {
  const CloseAllTabsEvent();
}

class SwitchTabEvent extends BrowserEvent {
  final int index;

  const SwitchTabEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateTabEvent extends BrowserEvent {
  final String id;
  final String? url;
  final String? title;
  final double? progress;
  final bool? canGoBack;
  final bool? canGoForward;
  final String? favicon;

  const UpdateTabEvent({
    required this.id,
    this.url,
    this.title,
    this.progress,
    this.canGoBack,
    this.canGoForward,
    this.favicon,
  });

  @override
  List<Object?> get props => [id, url, title, progress, canGoBack, canGoForward, favicon];
}

// History Events
class LoadHistoryEvent extends BrowserEvent {
  const LoadHistoryEvent();
}

class AddToHistoryEvent extends BrowserEvent {
  final String id;
  final String url;
  final String title;
  final String? favicon;

  const AddToHistoryEvent({
    required this.id,
    required this.url,
    required this.title,
    this.favicon,
  });

  @override
  List<Object?> get props => [id, url, title, favicon];
}

class ClearHistoryEvent extends BrowserEvent {
  const ClearHistoryEvent();
}

// WebView Controller Events
class SetWebViewControllerEvent extends BrowserEvent {
  final String tabId;
  final dynamic controller;

  const SetWebViewControllerEvent({
    required this.tabId,
    required this.controller,
  });

  @override
  List<Object?> get props => [tabId, controller];
}

// Page Content Getter Event
class SetPageContentGetterEvent extends BrowserEvent {
  final Future<String?> Function()? getter;

  const SetPageContentGetterEvent(this.getter);

  @override
  List<Object?> get props => [getter];
}
