// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:app_finance/_classes/herald/app_palette.dart';
import 'package:app_finance/_configs/custom_text_theme.dart';
import 'package:flutter/material.dart';

class AppColors {
  late AppDefaultColors palette;

  static const String colorApp = '0';
  static const String colorSystem = '1';
  static const String colorUser = '2';

  AppColors(String paletteType, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    if (paletteType == colorUser) {
      palette = AppDefaultColors.fromString(isDark ? AppPalette.dark : AppPalette.light);
    } else if (isDark) {
      palette = AppDarkColors();
    } else {
      palette = AppDefaultColors();
    }
  }
}

class AppDefaultColors {
  Color background = Colors.white;
  Color primary = const Color(0xff912391);
  Color inversePrimary = const Color(0xffdca3bc);
  Color inverseSurface = Colors.black;
  Color onSecondary = Colors.white;
  Color onInverseSurface = Colors.white;
  Color onSecondaryContainer = Colors.grey.withValues(alpha: 0.7);
  Color secondary = Colors.black;

  AppDefaultColors();

  @override
  String toString() {
    return json.encode(toJson());
  }

  Map<String, dynamic> toJson() => {
        'background': background.toARGB32(),
        'primary': primary.toARGB32(),
        'inversePrimary': inversePrimary.toARGB32(),
        'inverseSurface': inversePrimary.toARGB32(),
        'onSecondary': onSecondary.toARGB32(),
        'onInverseSurface': onInverseSurface.toARGB32(),
        'onSecondaryContainer': onSecondaryContainer.toARGB32(),
        'secondary': secondary.toARGB32(),
      };

  factory AppDefaultColors.fromString(String data) {
    return AppDefaultColors.fromJson(json.decode(data));
  }

  factory AppDefaultColors.fromJson(Map<String, dynamic> json) {
    return AppDefaultColors()
      ..background = Color(json['background'] ?? 0)
      ..primary = Color(json['primary'] ?? 0)
      ..inversePrimary = Color(json['inversePrimary'] ?? 0)
      ..inverseSurface = Color(json['inverseSurface'] ?? 0)
      ..onInverseSurface = Color(json['onInverseSurface'] ?? 0)
      ..onSecondary = Color(json['onSecondary'] ?? 0)
      ..onSecondaryContainer = Color(json['onSecondaryContainer'] ?? 0)
      ..secondary = Color(json['secondary'] ?? 0);
  }
}

class AppDarkColors extends AppDefaultColors {
  @override
  Color get background => Colors.black;
  @override
  Color get primary => const Color(0xff912391);
  @override
  Color get inversePrimary => const Color(0xff5d233c);
  @override
  Color get inverseSurface => Colors.grey;
  @override
  Color get onSecondary => Colors.grey;
  @override
  Color get onInverseSurface => Colors.white;
  @override
  Color get onSecondaryContainer => Colors.grey;
  @override
  Color get secondary => Colors.grey;
}

extension CustomColorScheme on ColorScheme {
  Color get fieldBackground => inversePrimary.withValues(alpha: 0.3);

  ColorScheme? withCustom(String paletteType) {
    if (paletteType == AppColors.colorSystem) {
      return null;
    }
    final palette = AppColors(paletteType, brightness).palette;
    return copyWith(
      surface: palette.background,
      primary: palette.primary,
      onPrimary: palette.secondary,
      inversePrimary: palette.inversePrimary,
      inverseSurface: palette.inverseSurface,
      secondary: palette.secondary,
      onInverseSurface: palette.onInverseSurface,
      onSecondary: palette.onSecondary,
      onSecondaryContainer: palette.onSecondaryContainer,
      onSurface: palette.secondary,
      onSurfaceVariant: palette.secondary,
    );
  }
}

extension CustomButtonTheme on FloatingActionButtonThemeData {
  FloatingActionButtonThemeData? withCustom(String paletteType, Brightness brightness) {
    if (paletteType == AppColors.colorSystem) {
      return null;
    }
    final palette = AppColors(paletteType, brightness).palette;
    return copyWith(
      backgroundColor: palette.inversePrimary,
      foregroundColor: palette.onSecondary,
    );
  }
}

extension CustomTimePickerTheme on TimePickerThemeData {
  TimePickerThemeData? withCustom(String paletteType, TextTheme? text, Brightness brightness) {
    if (paletteType == AppColors.colorSystem) {
      return null;
    }
    return copyWith(
      shape: Border.all(width: 0.2),
      hourMinuteTextStyle: text?.numberLarge,
    );
  }
}

extension CustomDatePickerThemeData on DatePickerThemeData {
  DatePickerThemeData? withCustom(String paletteType, TextTheme? text, Brightness brightness) {
    if (paletteType == AppColors.colorSystem) {
      return null;
    }
    final palette = AppColors(paletteType, brightness).palette;
    final txtStyle = TextStyle(color: palette.secondary);
    return copyWith(
      shape: Border.all(width: 0.2),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: txtStyle,
        fillColor: palette.onSecondaryContainer,
        counterStyle: txtStyle,
      ),
      rangePickerHeaderHelpStyle: txtStyle,
      rangePickerHeaderHeadlineStyle: txtStyle,
      rangePickerBackgroundColor: palette.primary,
      dayStyle: text?.numberMedium,
      yearStyle: text?.numberMedium,
    );
  }
}

class CustomDividerTheme extends DividerThemeData {
  late final Color? _color;

  @override
  Color? get color => _color;

  CustomDividerTheme(
    String paletteType,
    Brightness brightness, {
    super.color,
    super.space,
    super.thickness,
    super.indent,
    super.endIndent,
  }) {
    if (paletteType != AppColors.colorSystem) {
      final palette = AppColors(paletteType, brightness).palette;
      _color = palette.secondary.withValues(alpha: 0.2);
    } else {
      _color = null;
    }
  }
}
