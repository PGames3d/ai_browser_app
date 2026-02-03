import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/browser/presentation/screens/browser_screen.dart';
import 'features/browser/presentation/screens/tabs_screen.dart';
import 'features/file_manager/presentation/screens/files_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'core/theme/app_theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return MaterialApp(
          title: 'AI Browser',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsState.themeMode,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: IndexedStack(
              index: settingsState.bottomNavIndex,
              children: const [
                BrowserScreen(),
                FilesScreen(),
                TabsScreen(),
                SettingsScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: settingsState.bottomNavIndex,
              onDestinationSelected: (index) {
                context.read<SettingsBloc>().add(SetBottomNavIndexEvent(index));
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.public_outlined),
                  selectedIcon: Icon(Icons.public),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: 'Files',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tab_outlined),
                  selectedIcon: Icon(Icons.tab),
                  label: 'Tabs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
