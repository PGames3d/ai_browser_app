import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/browser_tab.dart';
import '../../domain/entities/history_item.dart';
import '../../../../core/constants/app_constants.dart';
import 'browser_event.dart';
import 'browser_state.dart';

class BrowserBloc extends Bloc<BrowserEvent, BrowserState> {
  BrowserBloc() : super(const BrowserState()) {
    on<LoadTabsEvent>(_onLoadTabs);
    on<CreateTabEvent>(_onCreateTab);
    on<CloseTabEvent>(_onCloseTab);
    on<CloseAllTabsEvent>(_onCloseAllTabs);
    on<SwitchTabEvent>(_onSwitchTab);
    on<UpdateTabEvent>(_onUpdateTab);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<AddToHistoryEvent>(_onAddToHistory);
    on<ClearHistoryEvent>(_onClearHistory);
    on<SetWebViewControllerEvent>(_onSetWebViewController);
    on<SetPageContentGetterEvent>(_onSetPageContentGetter);
  }

  void _onLoadTabs(LoadTabsEvent event, Emitter<BrowserState> emit) {
    // Tabs are loaded from local storage if needed
    if (state.tabs.isEmpty) {
      add(const CreateTabEvent());
    }
  }

  void _onCreateTab(CreateTabEvent event, Emitter<BrowserState> emit) {
    final newTab = BrowserTab(
      id: const Uuid().v4(),
      url: event.url ?? AppConstants.defaultHomePage,
      title: event.url ?? 'New Tab',
      isActive: true,
      createdAt: DateTime.now(),
      lastVisited: DateTime.now(),
    );

    // Set all other tabs as inactive
    final updatedTabs = state.tabs
        .map((tab) => tab.copyWith(isActive: false))
        .toList();
    
    updatedTabs.add(newTab);
    
    emit(state.copyWith(
      tabs: updatedTabs,
      activeTabIndex: updatedTabs.length - 1,
    ));
  }

  void _onCloseTab(CloseTabEvent event, Emitter<BrowserState> emit) {
    final index = state.tabs.indexWhere((tab) => tab.id == event.id);
    if (index == -1) return;

    final updatedTabs = List<BrowserTab>.from(state.tabs);
    updatedTabs.removeAt(index);

    if (updatedTabs.isEmpty) {
      // Clear state first, then create a new tab
      emit(state.copyWith(tabs: [], clearActiveTabIndex: true));
      add(const CreateTabEvent());
      return;
    }

    // Adjust active tab index
    int? newActiveIndex = state.activeTabIndex;
    if (state.activeTabIndex != null) {
      if (index == state.activeTabIndex) {
        newActiveIndex = (index > 0) ? index - 1 : 0;
        updatedTabs[newActiveIndex] = updatedTabs[newActiveIndex].copyWith(isActive: true);
      } else if (index < state.activeTabIndex!) {
        newActiveIndex = state.activeTabIndex! - 1;
      }
    }

    emit(state.copyWith(
      tabs: updatedTabs,
      activeTabIndex: newActiveIndex,
    ));
  }

  void _onCloseAllTabs(CloseAllTabsEvent event, Emitter<BrowserState> emit) {
    emit(state.copyWith(tabs: [], clearActiveTabIndex: true));
    add(const CreateTabEvent());
  }

  void _onSwitchTab(SwitchTabEvent event, Emitter<BrowserState> emit) {
    if (event.index < 0 || event.index >= state.tabs.length) return;

    final updatedTabs = state.tabs.asMap().entries.map((entry) {
      return entry.value.copyWith(isActive: entry.key == event.index);
    }).toList();

    emit(state.copyWith(
      tabs: updatedTabs,
      activeTabIndex: event.index,
    ));
  }

  void _onUpdateTab(UpdateTabEvent event, Emitter<BrowserState> emit) {
    final index = state.tabs.indexWhere((tab) => tab.id == event.id);
    if (index == -1) return;

    final updatedTabs = List<BrowserTab>.from(state.tabs);
    updatedTabs[index] = updatedTabs[index].copyWith(
      url: event.url ?? updatedTabs[index].url,
      title: event.title ?? updatedTabs[index].title,
      progress: event.progress ?? updatedTabs[index].progress,
      canGoBack: event.canGoBack ?? updatedTabs[index].canGoBack,
      canGoForward: event.canGoForward ?? updatedTabs[index].canGoForward,
      favicon: event.favicon ?? updatedTabs[index].favicon,
      lastVisited: DateTime.now(),
    );

    emit(state.copyWith(tabs: updatedTabs));
  }

  void _onLoadHistory(LoadHistoryEvent event, Emitter<BrowserState> emit) {
    // History can be loaded from local storage if needed
  }

  void _onAddToHistory(AddToHistoryEvent event, Emitter<BrowserState> emit) {
    final historyItem = HistoryItem(
      id: event.id,
      url: event.url,
      title: event.title,
      visitedAt: DateTime.now(),
      favicon: event.favicon,
    );

    emit(state.copyWith(history: [historyItem, ...state.history]));
  }

  void _onClearHistory(ClearHistoryEvent event, Emitter<BrowserState> emit) {
    emit(state.copyWith(history: []));
  }

  void _onSetWebViewController(
    SetWebViewControllerEvent event,
    Emitter<BrowserState> emit,
  ) {
    final updatedControllers = Map<String, InAppWebViewController?>.from(
      state.webViewControllers,
    );
    updatedControllers[event.tabId] = event.controller as InAppWebViewController?;
    emit(state.copyWith(webViewControllers: updatedControllers));
  }

  void _onSetPageContentGetter(
    SetPageContentGetterEvent event,
    Emitter<BrowserState> emit,
  ) {
    if (event.getter == null) {
      emit(state.copyWith(clearPageContentGetter: true));
    } else {
      emit(state.copyWith(pageContentGetter: event.getter));
    }
  }
}
