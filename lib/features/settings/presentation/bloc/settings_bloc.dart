import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _themeKey = 'theme_mode';

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<SetThemeEvent>(_onSetTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetBottomNavIndexEvent>(_onSetBottomNavIndex);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    emit(state.copyWith(themeMode: ThemeMode.values[themeIndex]));
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, event.themeMode.index);
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final newTheme = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(state.copyWith(themeMode: newTheme));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newTheme.index);
  }

  void _onSetBottomNavIndex(
    SetBottomNavIndexEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(bottomNavIndex: event.index));
  }
}
