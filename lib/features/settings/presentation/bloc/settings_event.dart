import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class SetThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  const SetThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class ToggleThemeEvent extends SettingsEvent {
  const ToggleThemeEvent();
}

class SetBottomNavIndexEvent extends SettingsEvent {
  final int index;

  const SetBottomNavIndexEvent(this.index);

  @override
  List<Object?> get props => [index];
}
