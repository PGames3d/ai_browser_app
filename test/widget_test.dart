// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'package:ai_browser_app/main_app.dart';
import 'package:ai_browser_app/core/network/network_info.dart';
import 'package:ai_browser_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ai_browser_app/features/browser/presentation/bloc/browser_bloc.dart';
import 'package:ai_browser_app/features/file_manager/presentation/bloc/file_manager_bloc.dart';
import 'package:ai_browser_app/features/file_manager/data/datasources/file_manager_local_datasource.dart';
import 'package:ai_browser_app/features/file_manager/data/datasources/file_manager_remote_datasource.dart';
import 'package:ai_browser_app/features/file_manager/data/repositories/file_manager_repository_impl.dart';
import 'package:ai_browser_app/features/ai_summary/presentation/bloc/ai_summary_bloc.dart';
import 'package:ai_browser_app/features/ai_summary/data/datasources/ai_summary_local_datasource.dart';
import 'package:ai_browser_app/features/ai_summary/data/datasources/ai_summary_remote_datasource.dart';
import 'package:ai_browser_app/features/ai_summary/data/repositories/ai_summary_repository_impl.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Set up dependencies
    final dio = Dio();
    final connectivity = Connectivity();
    final networkInfo = NetworkInfoImpl(connectivity);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(),
          ),
          BlocProvider<BrowserBloc>(
            create: (context) => BrowserBloc(),
          ),
          BlocProvider<FileManagerBloc>(
            create: (context) => FileManagerBloc(
              repository: FileManagerRepositoryImpl(
                localDataSource: FileManagerLocalDataSourceImpl(),
                remoteDataSource: FileManagerRemoteDataSourceImpl(),
              ),
            ),
          ),
          BlocProvider<AiSummaryBloc>(
            create: (context) => AiSummaryBloc(
              repository: AiSummaryRepositoryImpl(
                localDataSource: AiSummaryLocalDataSourceImpl(),
                remoteDataSource: AiSummaryRemoteDataSourceImpl(dio),
                networkInfo: networkInfo,
              ),
            ),
          ),
        ],
        child: const MainApp(),
      ),
    );

    // Verify that the app loads with bottom navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify that Home tab is present
    expect(find.text('Home'), findsOneWidget);
  });
}
