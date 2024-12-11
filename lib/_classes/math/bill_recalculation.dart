// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/math/abstract_recalculation.dart';
import 'package:app_finance/_classes/storage/history_data.dart';
import 'package:app_finance/_classes/structure/account_app_data.dart';
import 'package:app_finance/_classes/structure/bill_app_data.dart';
import 'package:app_finance/_classes/structure/budget_app_data.dart';

class BillRecalculation extends AbstractRecalculation {
  BillAppData change;
  BillAppData? initial;

  BillRecalculation({
    required this.change,
    this.initial,
  });

  @override
  double getDelta() => throw UnimplementedError();

  double getPrevDelta() => initial?.hidden == true ? 0.0 : initial?.details;

  double getStateDelta(dynamic prev, dynamic curr, [bool isBudget = true]) {
    double initialDetails = initial?.details ?? 0.0;
    double delta = change.hidden ? 0.0 : change.details;
    if (isBudget) {
      initialDetails *= initial?.exchangeCategory ?? 1.0;
      delta *= change.exchangeCategory;
    } else {
      initialDetails *= initial?.exchangeAccount ?? 1.0;
      delta *= change.exchangeAccount;
    }
    if (initial != null && prev?.uuid == curr?.uuid) {
      delta = initial?.hidden == true ? delta : delta - initialDetails;
    }
    return delta;
  }

  BillRecalculation updateAccount(AccountAppData accountChange, AccountAppData? accountInitial) {
    double? diffDelta;
    if (accountInitial != null && initial != null && accountChange.uuid != accountInitial.uuid) {
      diffDelta = getPrevDelta();
      HistoryData.addLog(accountInitial.uuid!, initial, 0.0, diffDelta, initial!.uuid);
    }
    double delta = getStateDelta(accountInitial, accountChange, false);
    HistoryData.addLog(accountChange.uuid!, change, 0.0, -delta, change.uuid);
    if (diffDelta != null && accountInitial?.createdAt.isBefore(initial?.createdAt ?? DateTime.now()) == true) {
      accountInitial!.details += exchange.reform(diffDelta, initial?.currency, accountInitial.currency);
    }
    if (accountChange.createdAt.isBefore(change.createdAt)) {
      accountChange.details -= delta;
    }
    return this;
  }

  BillRecalculation updateBudget(BudgetAppData budgetChange, BudgetAppData? budgetInitial) {
    if (budgetChange.getDateBoundary().isAfter(change.createdAt)) {
      return this;
    }
    if (budgetInitial != null && budgetChange.uuid != budgetInitial.uuid) {
      double prevDelta = exchange.reform(getPrevDelta(), initial?.currency, budgetInitial.currency);
      budgetInitial.progress = getProgress(budgetInitial.amountLimit, budgetInitial.progress, -prevDelta);
      budgetInitial.amount -= prevDelta;
    }
    double delta = getStateDelta(budgetInitial, budgetChange, true);
    budgetChange.progress = getProgress(budgetChange.amountLimit, budgetChange.progress, delta);
    budgetChange.amount += delta;
    return this;
  }
}
