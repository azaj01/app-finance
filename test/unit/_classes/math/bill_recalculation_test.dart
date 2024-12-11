// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be
// found in the LICENSE file.

import 'package:app_finance/_classes/storage/app_preferences.dart';
import 'package:app_finance/_classes/structure/account_app_data.dart';
import 'package:app_finance/_classes/structure/bill_app_data.dart';
import 'package:app_finance/_classes/math/bill_recalculation.dart';
import 'package:app_finance/_classes/structure/budget_app_data.dart';
import 'package:app_finance/_classes/structure/currency/exchange.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:dart_class_wrapper/gen/generate_with_method_setters.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateWithMethodSetters([BillRecalculation, Exchange])
import 'bill_recalculation_test.wrapper.dart';

@GenerateNiceMocks([MockSpec<AppData>(), MockSpec<SharedPreferences>()])
import 'bill_recalculation_test.mocks.dart';

void main() {
  setUp(() {
    AppPreferences.pref = MockSharedPreferences();
  });

  group('BillRecalculation', () {
    late BillRecalculation object;

    setUp(() {
      final billMock = BillAppData(
        uuid: '1',
        title: 'test',
        account: '',
        category: '',
      );
      object = BillRecalculation(
        initial: billMock.clone(),
        change: billMock.clone(),
      );
      object.exchange = WrapperExchange(store: MockAppData());
    });

    test('getDelta (UnimplementedError)', () {
      expect(() => object.getDelta(), throwsA(isA<UnimplementedError>()));
    });

    group('getStateDelta', () {
      final testCases = [
        (
          initial: (hidden: true, uuid: '1', details: 10.0),
          change: (hidden: true, uuid: '2', details: 20.0),
          result: 0.0,
        ),
        (
          initial: (hidden: false, uuid: '1', details: 10.0),
          change: (hidden: false, uuid: '2', details: 20.0),
          result: 20.0,
        ),
        (
          initial: (hidden: false, uuid: '1', details: 10.0),
          change: (hidden: false, uuid: '1', details: 20.0),
          result: 10.0,
        ),
        (
          initial: (hidden: false, uuid: '1', details: 10.0),
          change: (hidden: true, uuid: '1', details: 20.0),
          result: -10.0,
        ),
        (
          initial: (hidden: true, uuid: '1', details: 10.0),
          change: (hidden: false, uuid: '1', details: 20.0),
          result: 20.0,
        ),
        (
          initial: null,
          change: (hidden: false, uuid: '1', details: 20.0),
          result: 20.0,
        ),
      ];

      for (var v in testCases) {
        test('$v', () {
          if (v.initial == null) {
            object.initial = null;
          } else {
            object.initial!.hidden = v.initial!.hidden;
            object.initial!.details = v.initial!.details;
            object.initial!.uuid = v.initial!.uuid;
          }
          object.change.hidden = v.change.hidden;
          object.change.details = v.change.details;
          object.change.uuid = v.change.uuid;
          expect(object.getStateDelta(object.initial, object.change), v.result);
        });
      }
    });
    group('getPrevDelta', () {
      final testCases = [
        (
          initial: (hidden: true, details: 10.0),
          result: 0.0,
        ),
        (
          initial: (hidden: false, details: 10.0),
          result: 10.0,
        ),
      ];

      for (var v in testCases) {
        test('$v', () {
          object.initial!.hidden = v.initial.hidden;
          object.initial!.details = v.initial.details;
          expect(object.getPrevDelta(), v.result);
        });
      }
    });

    group('updateAccount', () {
      final testCases = [
        (
          getStateDelta: 10.0,
          getPrevDelta: 0.0,
          initial: (createdAtFormatted: '2023-07-17 00:00:00'),
          initialAccount: (createdAtFormatted: '2023-07-10 00:00:00', uuid: '1'),
          change: (createdAtFormatted: '2023-07-17 00:00:00'),
          changeAccount: (createdAtFormatted: '2023-07-10 00:00:00', uuid: '1'),
          result: (initialAccountDetails: 0.0, changeAccountDetails: -10.0),
        ),
        (
          getStateDelta: 20.0,
          getPrevDelta: 10.0,
          initial: (createdAtFormatted: '2023-07-17 00:00:00'),
          initialAccount: (createdAtFormatted: '2023-07-10 00:00:00', uuid: '1'),
          change: (createdAtFormatted: '2023-07-17 00:00:00'),
          changeAccount: (createdAtFormatted: '2023-07-10 00:00:00', uuid: '2'),
          result: (initialAccountDetails: 10.0, changeAccountDetails: -20.0),
        ),
        (
          getStateDelta: 20.0,
          getPrevDelta: 10.0,
          initial: (createdAtFormatted: '2023-07-17 00:00:00'),
          initialAccount: (createdAtFormatted: '2023-07-20 00:00:00', uuid: '1'),
          change: (createdAtFormatted: '2023-07-17 00:00:00'),
          changeAccount: (createdAtFormatted: '2023-07-20 00:00:00', uuid: '2'),
          result: (initialAccountDetails: 0.0, changeAccountDetails: 0.0),
        ),
        (
          getStateDelta: 20.0,
          getPrevDelta: 10.0,
          initial: (createdAtFormatted: '2023-07-17 00:00:00'),
          initialAccount: (createdAtFormatted: '2023-07-10 00:00:00', uuid: '1'),
          change: (createdAtFormatted: '2023-07-17 00:00:00'),
          changeAccount: (createdAtFormatted: '2023-07-20 00:00:00', uuid: '2'),
          result: (initialAccountDetails: 10.0, changeAccountDetails: 0.0),
        ),
      ];

      for (var v in testCases) {
        test('$v', () {
          object.initial!.createdAtFormatted = v.initial.createdAtFormatted;
          object.change.createdAtFormatted = v.change.createdAtFormatted;
          final mock = WrapperBillRecalculation(
            initial: object.initial,
            change: object.change,
          );
          mock.exchange = object.exchange;
          mock.mockGetStateDelta = (a, b, [c = true]) => v.getStateDelta;
          mock.mockGetPrevDelta = () => v.getPrevDelta;
          final initial = AccountAppData(title: '', type: '')
            ..uuid = v.initialAccount.uuid
            ..createdAtFormatted = v.initialAccount.createdAtFormatted;
          final change = AccountAppData(title: '', type: '')
            ..uuid = v.changeAccount.uuid
            ..createdAtFormatted = v.changeAccount.createdAtFormatted;
          mock.updateAccount(change, initial);
          expect(initial.details, v.result.initialAccountDetails);
          expect(change.details, v.result.changeAccountDetails);
        });
      }
    });

    group('updateBudget', () {
      final testCases = [
        (
          getStateDelta: 10.0,
          getPrevDelta: 0.0,
          initialBudget: (amountLimit: 100.0, progress: 0.5, uuid: '1'),
          changeBudget: (amountLimit: 100.0, progress: 0.5, uuid: '1'),
          result: (initialBudgetProgress: 0.5, changeBudgetProgress: 0.6),
        ),
        (
          getStateDelta: 10.0,
          getPrevDelta: 20.0,
          initialBudget: (amountLimit: 100.0, progress: 0.5, uuid: '1'),
          changeBudget: (amountLimit: 100.0, progress: 0.5, uuid: '2'),
          result: (initialBudgetProgress: 0.3, changeBudgetProgress: 0.6),
        ),
      ];

      for (var v in testCases) {
        test('$v', () {
          final mock = WrapperBillRecalculation(
            initial: object.initial,
            change: object.change,
          );
          mock.exchange = object.exchange;
          mock.mockGetStateDelta = (a, b, [c = true]) => v.getStateDelta;
          mock.mockGetPrevDelta = () => v.getPrevDelta;
          final initial = BudgetAppData(title: '', amountLimit: v.initialBudget.amountLimit)
            ..uuid = v.initialBudget.uuid
            ..progress = v.initialBudget.progress;
          final change = BudgetAppData(title: '', amountLimit: v.changeBudget.amountLimit)
            ..uuid = v.changeBudget.uuid
            ..progress = v.changeBudget.progress;
          mock.updateBudget(change, initial);
          expect(initial.progress, v.result.initialBudgetProgress);
          expect(change.progress, v.result.changeBudgetProgress);
        });
      }
    });

    test('updateBudget with Currency change', () {
      object.initial!.details = 100.0;
      object.initial!.currency = (
        code: 'USD',
        name: CurrencyDefaults.labels.currencyUSD,
        symbol: '\$',
        flag: '🇺🇸',
        decimalDigits: 2,
        thousandsSeparator: ',',
        decimalSeparator: '.',
        hasSpace: false,
        symbolOnLeft: true,
      );
      object.initial!.exchangeCategory = 2;
      object.change.details = 100.0;
      object.change.currency = (
        code: 'EUR',
        name: CurrencyDefaults.labels.currencyEUR,
        symbol: '€',
        flag: '🇪🇺',
        decimalDigits: 2,
        thousandsSeparator: ' ',
        decimalSeparator: ',',
        hasSpace: true,
        symbolOnLeft: false,
      );
      object.change.exchangeCategory = 1;
      final mock = WrapperBillRecalculation(
        initial: object.initial,
        change: object.change,
      )..exchange = object.exchange;
      (object.exchange as WrapperExchange).mockReform =
          (amount, Currency? from, Currency? to) => (amount ?? 0.0) * (from?.code == 'USD' ? 2 : 1);
      final budget = BudgetAppData(title: '', amount: 100);
      mock.updateBudget(budget, budget);
      expect(budget.amount, 0);
    });
  });
}
