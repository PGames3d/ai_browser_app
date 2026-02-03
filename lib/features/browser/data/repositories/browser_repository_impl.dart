import 'package:dartz/dartz.dart';
import '../../domain/entities/browser_tab.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/browser_repository.dart';
import '../datasources/browser_local_datasource.dart';
import '../datasources/browser_remote_datasource.dart';
import '../models/browser_tab_model.dart';
import '../models/history_item_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import 'package:uuid/uuid.dart';

class BrowserRepositoryImpl implements BrowserRepository {
  final BrowserLocalDataSource localDataSource;
  final BrowserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BrowserRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<BrowserTab>>> getAllTabs() async {
    try {
      final tabs = await localDataSource.getAllTabs();
      return Right(tabs.map((tab) => tab.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BrowserTab>> getTab(String id) async {
    try {
      final tab = await localDataSource.getTab(id);
      if (tab != null) {
        return Right(tab.toEntity());
      }
      return const Left(CacheFailure('Tab not found'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BrowserTab>> createTab(String url) async {
    try {
      final newTab = BrowserTab(
        id: const Uuid().v4(),
        url: url,
        title: url,
        isActive: true,
        createdAt: DateTime.now(),
        lastVisited: DateTime.now(),
      );

      await localDataSource.saveTab(BrowserTabModel.fromEntity(newTab));
      return Right(newTab);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTab(BrowserTab tab) async {
    try {
      await localDataSource.saveTab(BrowserTabModel.fromEntity(tab));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> closeTab(String id) async {
    try {
      await localDataSource.deleteTab(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> closeAllTabs() async {
    try {
      await localDataSource.clearAllTabs();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistory({int limit = 50}) async {
    try {
      final history = await localDataSource.getHistory(limit: limit);
      return Right(history.map((item) => item.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToHistory(HistoryItem item) async {
    try {
      await localDataSource.addToHistory(HistoryItemModel.fromEntity(item));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadFile(String url, String fileName) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }

      final filePath = await remoteDataSource.downloadFile(url, fileName);
      return Right(filePath);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
