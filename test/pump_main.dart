// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'dart:io' as io;
import 'package:app_finance/_classes/herald/app_design.dart';
import 'package:app_finance/_classes/herald/app_purchase.dart';
import 'package:app_finance/_classes/herald/app_start_of_month.dart';
import 'package:app_finance/_classes/herald/app_start_of_week.dart';
import 'package:app_finance/_classes/storage/transaction_log/abstract_storage.dart';
import 'package:app_finance/_configs/custom_text_theme.dart';
import 'package:dart_class_wrapper/dart_class_wrapper.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';

import 'package:app_finance/_classes/herald/app_palette.dart';
import 'package:app_finance/_classes/herald/app_sync.dart';
import 'package:app_finance/_classes/herald/app_zoom.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/herald/app_theme.dart';
import 'package:app_finance/_classes/storage/app_preferences.dart';
import 'package:app_finance/l10n/app_localization.dart';
import 'package:app_finance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen_capture.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
import 'pump_main.mocks.dart';
@GenerateWithMethodSetters([MockSharedPreferences])
import 'pump_main.wrapper.dart';

class PumpMain {
  static const path = './coverage/data';
  static const FileSystem fs = LocalFileSystem();
  static const Platform platform = LocalPlatform();

  static Future<void> init(WidgetTester tester, [bool isIntegration = false]) async {
    final pumpMain = PumpMain();
    final tmp = '$path/${UniqueKey()}';
    wrapProvider(tester, 'plugins.flutter.io/path_provider', tmp);
    io.File('$tmp/${AbstractStorage.filePath}').createSync(recursive: true);
    await initFonts();
    await initPref(isIntegration);
    await pumpMain.initMain(tester, isIntegration);
  }

  static Future<void> initFonts() async {
    await _initFont('Abel-Regular');
    await _initFont('RobotoCondensed-Regular');
    // await _initFont('MaterialIcons-Regular');
  }

  static Future<void> _initFont(String name) async {
    final root = fs.directory(platform.environment['FLUTTER_ROOT']).path.replaceAll('\\', '/');
    final scope = [
      'assets/fonts/$name.ttf',
      'assets/fonts/$name.otf',
      '$root/bin/cache/artifacts/material_fonts/$name.otf',
    ];
    final path = scope.firstWhere((path) => io.File(path).existsSync());
    final Future<ByteData> fontData = rootBundle.load(path);
    final FontLoader fontLoader = FontLoader(name)..addFont(fontData);
    await fontLoader.load();
  }

  static Future<void> initPaint(WidgetTester tester, CustomPainter paint, [Size size = const Size(320, 240)]) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;

    await initFonts();
    await initPref(false);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: ThemeData.light().textTheme.withCustom('', Brightness.light),
          useMaterial3: true,
        ),
        home: CustomPaint(
          size: size,
          painter: paint,
        ),
      ),
    );
  }

  AppData getStore(AppSync appSync, bool isIntegration) {
    final appData = AppData(appSync);
    if (!isIntegration) {
      appData.isLoading = false;
    }
    return appData;
  }

  static void cleanUpData() {
    final dir = io.Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static void wrapProvider(WidgetTester tester, String channel, String output) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (MethodCall methodCall) => Future.value(output),
    );
  }

  static Future<void> initPref(bool isIntegration) async {
    if (isIntegration) {
      AppPreferences.pref = await SharedPreferences.getInstance();
      await AppPreferences.set(AppPreferences.prefCurrency, 'USD');
    } else {
      final pref = WrapperMockSharedPreferences();
      pref.mockGetString = (value) => switch (value) {
            AppPreferences.prefCurrency => 'USD',
            AppPreferences.prefLocale => 'en',
            AppPreferences.prefPrivacyPolicy => '',
            AppPreferences.prefVersion => '1.0',
            _ => null,
          };
      AppPreferences.pref = pref;
    }
  }

  Future<void> initMain(WidgetTester tester, bool isIntegration) async {
    final appSync = AppSync();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSync>(
          create: (_) => appSync,
        ),
        ChangeNotifierProvider<AppData>(
          create: (_) => getStore(appSync, isIntegration),
        ),
        ChangeNotifierProvider<AppTheme>(
          create: (_) => AppTheme(ThemeMode.system),
        ),
        ChangeNotifierProvider<AppLocale>(
          create: (_) => AppLocale(),
        ),
        ChangeNotifierProvider<AppDesign>(
          create: (_) => AppDesign(),
        ),
        ChangeNotifierProvider<AppZoom>(
          create: (_) => AppZoom(),
        ),
        ChangeNotifierProvider<AppPalette>(
          create: (_) => AppPalette(),
        ),
        ChangeNotifierProvider<AppPurchase>(
          create: (_) => AppPurchase(),
        ),
        ChangeNotifierProvider<AppStartOfWeek>(
          create: (_) => AppStartOfWeek(),
        ),
        ChangeNotifierProvider<AppStartOfMonth>(
          create: (_) => AppStartOfMonth(),
        ),
      ],
      child: RepaintBoundary(
        key: ScreenCapture.getKey(),
        child: const MyApp(),
      ),
    ));
  }
}
