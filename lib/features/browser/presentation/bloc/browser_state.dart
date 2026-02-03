import 'package:equatable/equatable.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../domain/entities/browser_tab.dart';
import '../../domain/entities/history_item.dart';

class BrowserState extends Equatable {
  final List<BrowserTab> tabs;
  final int? activeTabIndex;
  final List<HistoryItem> history;
  final Map<String, InAppWebViewController?> webViewControllers;
  final Future<String?> Function()? pageContentGetter;
  final bool isLoading;
  final String? error;

  const BrowserState({
    this.tabs = const [],
    this.activeTabIndex,
    this.history = const [],
    this.webViewControllers = const {},
    this.pageContentGetter,
    this.isLoading = false,
    this.error,
  });

  BrowserTab? get activeTab {
    if (activeTabIndex != null && activeTabIndex! < tabs.length) {
      return tabs[activeTabIndex!];
    }
    return null;
  }

  BrowserState copyWith({
    List<BrowserTab>? tabs,
    int? activeTabIndex,
    bool clearActiveTabIndex = false,
    List<HistoryItem>? history,
    Map<String, InAppWebViewController?>? webViewControllers,
    Future<String?> Function()? pageContentGetter,
    bool clearPageContentGetter = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BrowserState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: clearActiveTabIndex ? null : (activeTabIndex ?? this.activeTabIndex),
      history: history ?? this.history,
      webViewControllers: webViewControllers ?? this.webViewControllers,
      pageContentGetter: clearPageContentGetter ? null : (pageContentGetter ?? this.pageContentGetter),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        tabs,
        activeTabIndex,
        history,
        webViewControllers,
        isLoading,
        error,
      ];
}
