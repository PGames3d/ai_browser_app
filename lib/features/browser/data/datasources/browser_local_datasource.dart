import 'package:hive/hive.dart';
import '../models/browser_tab_model.dart';
import '../models/history_item_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class BrowserLocalDataSource {
  Future<List<BrowserTabModel>> getAllTabs();
  Future<BrowserTabModel?> getTab(String id);
  Future<void> saveTab(BrowserTabModel tab);
  Future<void> deleteTab(String id);
  Future<void> clearAllTabs();
  
  Future<List<HistoryItemModel>> getHistory({int limit = 50});
  Future<void> addToHistory(HistoryItemModel item);
  Future<void> clearHistory();
}

class BrowserLocalDataSourceImpl implements BrowserLocalDataSource {
  Box<BrowserTabModel>? _tabsBox;
  Box<HistoryItemModel>? _historyBox;

  Future<Box<BrowserTabModel>> get tabsBox async {
    _tabsBox ??= await Hive.openBox<BrowserTabModel>(AppConstants.tabsBoxName);
    return _tabsBox!;
  }

  Future<Box<HistoryItemModel>> get historyBox async {
    _historyBox ??= await Hive.openBox<HistoryItemModel>(AppConstants.historyBoxName);
    return _historyBox!;
  }

  @override
  Future<List<BrowserTabModel>> getAllTabs() async {
    final box = await tabsBox;
    return box.values.toList();
  }

  @override
  Future<BrowserTabModel?> getTab(String id) async {
    final box = await tabsBox;
    return box.get(id);
  }

  @override
  Future<void> saveTab(BrowserTabModel tab) async {
    final box = await tabsBox;
    await box.put(tab.id, tab);
  }

  @override
  Future<void> deleteTab(String id) async {
    final box = await tabsBox;
    await box.delete(id);
  }

  @override
  Future<void> clearAllTabs() async {
    final box = await tabsBox;
    await box.clear();
  }

  @override
  Future<List<HistoryItemModel>> getHistory({int limit = 50}) async {
    final box = await historyBox;
    final items = box.values.toList();
    items.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    return items.take(limit).toList();
  }

  @override
  Future<void> addToHistory(HistoryItemModel item) async {
    final box = await historyBox;
    await box.put(item.id, item);
  }

  @override
  Future<void> clearHistory() async {
    final box = await historyBox;
    await box.clear();
  }
}
