import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main_app.dart';
import 'features/browser/data/models/browser_tab_model.dart';
import 'features/browser/data/models/history_item_model.dart';
import 'features/file_manager/data/models/file_item_model.dart';
import 'features/ai_summary/data/models/summary_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(BrowserTabModelAdapter());
  Hive.registerAdapter(HistoryItemModelAdapter());
  Hive.registerAdapter(FileItemModelAdapter());
  Hive.registerAdapter(SummaryModelAdapter());
  
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}
