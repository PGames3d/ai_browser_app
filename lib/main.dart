import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'main_app.dart';
import 'features/browser/data/models/browser_tab_model.dart';
import 'features/browser/data/models/history_item_model.dart';
import 'features/file_manager/data/models/file_item_model.dart';
import 'features/ai_summary/data/models/summary_model.dart';
import 'features/browser/presentation/bloc/browser_bloc.dart';
import 'features/file_manager/presentation/bloc/file_manager_bloc.dart';
import 'features/file_manager/data/datasources/file_manager_local_datasource.dart';
import 'features/file_manager/data/datasources/file_manager_remote_datasource.dart';
import 'features/file_manager/data/repositories/file_manager_repository_impl.dart';
import 'features/ai_summary/presentation/bloc/ai_summary_bloc.dart';
import 'features/ai_summary/data/datasources/ai_summary_local_datasource.dart';
import 'features/ai_summary/data/datasources/ai_summary_remote_datasource.dart';
import 'features/ai_summary/data/repositories/ai_summary_repository_impl.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'core/network/network_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(BrowserTabModelAdapter());
  Hive.registerAdapter(HistoryItemModelAdapter());
  Hive.registerAdapter(FileItemModelAdapter());
  Hive.registerAdapter(SummaryModelAdapter());

  // Initialize dependencies
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final connectivity = Connectivity();
  final networkInfo = NetworkInfoImpl(connectivity);

  // Initialize repositories
  final fileManagerRepository = FileManagerRepositoryImpl(
    localDataSource: FileManagerLocalDataSourceImpl(),
    remoteDataSource: FileManagerRemoteDataSourceImpl(),
  );

  final aiSummaryRepository = AiSummaryRepositoryImpl(
    localDataSource: AiSummaryLocalDataSourceImpl(),
    remoteDataSource: AiSummaryRemoteDataSourceImpl(dio),
    networkInfo: networkInfo,
  );
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<BrowserBloc>(
          create: (_) => BrowserBloc(),
        ),
        BlocProvider<FileManagerBloc>(
          create: (_) => FileManagerBloc(repository: fileManagerRepository),
        ),
        BlocProvider<AiSummaryBloc>(
          create: (_) => AiSummaryBloc(repository: aiSummaryRepository),
        ),
      ],
      child: const MainApp(),
    ),
  );
}
