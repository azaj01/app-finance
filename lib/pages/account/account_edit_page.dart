// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/structure/account_app_data.dart';
import 'package:app_finance/_configs/account_type.dart';
import 'package:app_finance/pages/account/account_add_page.dart';
import 'package:flutter/material.dart';

class AccountEditPage extends AccountAddPage {
  final String uuid;

  const AccountEditPage({
    super.key,
    required this.uuid,
  });

  @override
  AccountEditPageState createState() => AccountEditPageState();
}

class AccountEditPageState extends AccountAddPageState<AccountEditPage> {
  bool isFirstRun = true;

  void bindState() {
    if (!isFirstRun) {
      return;
    }
    setState(() {
      isFirstRun = false;
      final form = state.getByUuid(widget.uuid) as AccountAppData;
      title.text = form.title;
      description.text = form.description ?? '';
      type = form.type;
      balance.text = form.details != null ? form.details.toString() : '';
      color = form.color;
      currency = form.currency;
      icon = form.icon;
      validTillDate = form.closedAt;
      skip = form.skip;
      balanceUpdateDate = DateTime.now();
    });
  }

  @override
  void updateStorage() {
    super.state.update(
        widget.uuid,
        AccountAppData(
          uuid: widget.uuid,
          title: title.text,
          type: type ?? AppAccountType.cash.toString(),
          description: description.text,
          details: double.tryParse(balance.text) ?? 0.0,
          progress: 1.0,
          color: color ?? Colors.red,
          currency: currency,
          hidden: false,
          skip: skip,
          icon: icon,
          closedAt: validTillDate,
          createdAt: balanceUpdateDate,
        ));
  }

  @override
  String getTitle() => AppLocale.labels.editAccountHeader;

  @override
  String getButtonName() => AppLocale.labels.updateAccountTooltip;

  @override
  Widget buildContent(BuildContext context, BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) => bindState());
    return super.buildContent(context, constraints);
  }
}
