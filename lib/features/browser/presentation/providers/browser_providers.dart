import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/browser_tab.dart';
import '../../domain/entities/history_item.dart';
import '../../data/datasources/browser_local_datasource.dart';
import '../../data/datasources/browser_remote_datasource.dart';
import '../../data/repositories/browser_repository_impl.dart';
import '../../domain/repositories/browser_repository.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/constants/app_constants.dart';

// Data Sources
final browserLocalDataSourceProvider = Provider<BrowserLocalDataSourceImpl>((ref) {
  return BrowserLocalDataSourceImpl();
});

final browserRemoteDataSourceProvider = Provider<BrowserRemoteDataSourceImpl>((ref) {
  final dio = ref.watch(dioProvider);
  return BrowserRemoteDataSourceImpl(dio);
});

// Repository
final browserRepositoryProvider = Provider<BrowserRepository>((ref) {
  final localDataSource = ref.watch(browserLocalDataSourceProvider);
  final remoteDataSource = ref.watch(browserRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  
  return BrowserRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Tab State
class BrowserTabsNotifier extends StateNotifier<List<BrowserTab>> {
  BrowserTabsNotifier() : super([]);

  int? _activeTabIndex;

  int? get activeTabIndex => _activeTabIndex;

  BrowserTab? get activeTab {
    if (_activeTabIndex != null && _activeTabIndex! < state.length) {
      return state[_activeTabIndex!];
    }
    return null;
  }

  void loadTabs(List<BrowserTab> tabs) {
    state = tabs;
    if (tabs.isNotEmpty && _activeTabIndex == null) {
      _activeTabIndex = 0;
    }
  }

  void createTab({String? url}) {
    final newTab = BrowserTab(
      id: const Uuid().v4(),
      url: url ?? AppConstants.defaultHomePage,
      title: url ?? 'New Tab',
      isActive: true,
      createdAt: DateTime.now(),
      lastVisited: DateTime.now(),
    );
    
    // Set all other tabs as inactive
    final updatedTabs = state.map((tab) => 
      tab.copyWith(isActive: false)
    ).toList();
    
    updatedTabs.add(newTab);
    state = updatedTabs;
    _activeTabIndex = updatedTabs.length - 1;
  }

  void closeTab(String id) {
    final index = state.indexWhere((tab) => tab.id == id);
    if (index == -1) return;

    final updatedTabs = List<BrowserTab>.from(state);
    updatedTabs.removeAt(index);
    
    if (updatedTabs.isEmpty) {
      // Clear state first, then create a new tab
      state = [];
      _activeTabIndex = null;
      createTab();
      return;
    }

    // Adjust active tab index
    if (_activeTabIndex != null) {
      if (index == _activeTabIndex) {
        _activeTabIndex = (index > 0) ? index - 1 : 0;
        updatedTabs[_activeTabIndex!] = 
          updatedTabs[_activeTabIndex!].copyWith(isActive: true);
      } else if (index < _activeTabIndex!) {
        _activeTabIndex = _activeTabIndex! - 1;
      }
    }

    state = updatedTabs;
  }

  void closeAllTabs() {
    state = [];
    _activeTabIndex = null;
    createTab();
  }

  void switchTab(int index) {
    if (index < 0 || index >= state.length) return;

    final updatedTabs = state.asMap().entries.map((entry) {
      return entry.value.copyWith(isActive: entry.key == index);
    }).toList();

    _activeTabIndex = index;
    state = updatedTabs;
  }

  void updateTab(String id, {
    String? url,
    String? title,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    String? favicon,
  }) {
    final index = state.indexWhere((tab) => tab.id == id);
    if (index == -1) return;

    final updatedTabs = List<BrowserTab>.from(state);
    updatedTabs[index] = updatedTabs[index].copyWith(
      url: url ?? updatedTabs[index].url,
      title: title ?? updatedTabs[index].title,
      progress: progress ?? updatedTabs[index].progress,
      canGoBack: canGoBack ?? updatedTabs[index].canGoBack,
      canGoForward: canGoForward ?? updatedTabs[index].canGoForward,
      favicon: favicon ?? updatedTabs[index].favicon,
      lastVisited: DateTime.now(),
    );

    state = updatedTabs;
  }
}

final browserTabsProvider = StateNotifierProvider<BrowserTabsNotifier, List<BrowserTab>>((ref) {
  return BrowserTabsNotifier();
});

// History State
class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  HistoryNotifier() : super([]);

  void loadHistory(List<HistoryItem> history) {
    state = history;
  }

  void addToHistory(HistoryItem item) {
    state = [item, ...state];
  }

  void clearHistory() {
    state = [];
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryItem>>((ref) {
  return HistoryNotifier();
});
