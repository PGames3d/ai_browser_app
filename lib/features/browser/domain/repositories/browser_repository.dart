import 'package:dartz/dartz.dart';
import '../entities/browser_tab.dart';
import '../entities/history_item.dart';
import '../../../../core/errors/failures.dart';

abstract class BrowserRepository {
  Future<Either<Failure, List<BrowserTab>>> getAllTabs();
  Future<Either<Failure, BrowserTab>> getTab(String id);
  Future<Either<Failure, BrowserTab>> createTab(String url);
  Future<Either<Failure, void>> updateTab(BrowserTab tab);
  Future<Either<Failure, void>> closeTab(String id);
  Future<Either<Failure, void>> closeAllTabs();
  
  Future<Either<Failure, List<HistoryItem>>> getHistory({int limit = 50});
  Future<Either<Failure, void>> addToHistory(HistoryItem item);
  Future<Either<Failure, void>> clearHistory();
  
  Future<Either<Failure, String>> downloadFile(String url, String fileName);
}
