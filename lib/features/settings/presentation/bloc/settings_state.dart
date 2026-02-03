import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final int bottomNavIndex;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.bottomNavIndex = 0,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? bottomNavIndex,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
    );
  }

  @override
  List<Object?> get props => [themeMode, bottomNavIndex];
}
