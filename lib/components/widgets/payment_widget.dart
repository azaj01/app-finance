// Copyright 2024 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_design.dart';
import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_classes/structure/bill_app_data.dart';
import 'package:app_finance/_classes/structure/invoice_app_data.dart';
import 'package:app_finance/_classes/structure/navigation/app_route.dart';
import 'package:app_finance/_classes/structure/payment_app_data.dart';
import 'package:app_finance/_configs/automation_type.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/data_ext.dart';
import 'package:app_finance/_ext/date_time_ext.dart';
import 'package:app_finance/components/widgets/payment_list_widget.dart';
import 'package:app_finance/design/generic/base_header_widget.dart';
import 'package:app_finance/design/generic/base_swipe_widget.dart';
import 'package:flutter/material.dart';

class PaymentWidget extends StatelessWidget {
  final List<PaymentAppData> data;
  final AppData state;
  final EdgeInsets? margin;
  final double? width;

  PaymentWidget({
    super.key,
    required this.data,
    required this.state,
    this.margin,
    this.width,
  }) {
    data.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  }

  double getMonthTotals() {
    double amount = 0.0;
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    for (PaymentAppData item in data) {
      item = item.clone();
      while (item.updatedAt.isBefore(nextMonth)) {
        dynamic obj = item.data.toDataObject(state);
        if (obj is BillAppData) {
          amount -= obj.details;
        } else if (obj is InvoiceAppData && obj.accountFrom == null) {
          amount += obj.details;
        }
        if (item.title == AppAutomationType.days.name) {
          item.updatedAt = item.updatedAt.add(Duration(days: item.days > 0 ? item.days : 1));
        } else if (item.title == AppAutomationType.week.name) {
          item.updatedAt = item.updatedAt.add(const Duration(days: 7));
        } else if (item.title == AppAutomationType.year.name) {
          item.updatedAt = item.updatedAt.getNextYear();
        } else {
          item.updatedAt = item.updatedAt.getNextMonth();
        }
      }
    }
    return amount;
  }

  Widget buildListWidget(PaymentAppData item, BuildContext context, BoxConstraints constraints) {
    return BaseSwipeWidget(
      routePath: AppRoute.automationPaymentEditRoute,
      uuid: item.uuid ?? '',
      child: PaymentListWidget(item: item, state: state, width: width, constraints: constraints),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: AppDesign.getAlignment(),
            children: [
              BaseHeaderWidget(
                route: AppRoute.automationRoute,
                width: width ?? constraints.maxWidth,
                total: getMonthTotals(),
                title: '${AppLocale.labels.paymentsHeadline}, ${DateTime.now().fullMonth()}',
                tooltip: AppLocale.labels.paymentsHeadline,
              ),
              ThemeHelper.hIndent,
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: data.length + 1,
                  itemBuilder: (BuildContext context, index) {
                    if (index >= data.length) {
                      return ThemeHelper.formEndBox;
                    }
                    return buildListWidget(data[index], context, constraints);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
