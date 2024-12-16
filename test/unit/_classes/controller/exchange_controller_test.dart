// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/controller/exchange_controller.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:dart_class_wrapper/dart_class_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>(), MockSpec<AppData>()])
import 'exchange_controller_test.mocks.dart';

@GenerateWithMethodSetters([MockAppData])
import 'exchange_controller_test.wrapper.dart';

void main() {
  group('ExchangeController', () {
    setUp(() => CurrencyDefaults.cache = MockSharedPreferences());

    test('_updateSum | _updateRate', () {
      final editor = TextEditingController(text: '123.02');
      final controller = ExchangeController(
        {},
        store: WrapperMockAppData(),
        source: [CurrencyProvider.find('USD'), CurrencyProvider.find('EUR')],
        target: CurrencyProvider.find('EUR'),
        targetController: editor,
      );
      expect(controller.length, 1);
      expect(controller.get(0).from, 'EUR');
      expect(controller.get(0).to, 'USD');
      expect(controller.get(0).rate.text, '1.0');
      expect(controller.get(0).sum.text, '123.02');
      controller.get(0).rate.text = '2.0';
      expect(controller.get(0).sum.text, '246.04');
      controller.get(0).sum.text = '62.51';
      expect(double.parse(controller.get(0).rate.text).toStringAsFixed(1), '0.5');
    });
  });
}
