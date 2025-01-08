// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/controller/exchange_controller.dart';
import 'package:app_finance/_classes/herald/app_design.dart';
import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_classes/structure/currency/exchange.dart';
import 'package:app_finance/_classes/structure/invoice_app_data.dart';
import 'package:app_finance/_classes/controller/focus_controller.dart';
import 'package:app_finance/_classes/storage/app_data.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/_ext/double_ext.dart';
import 'package:app_finance/design/wrapper/input_wrapper.dart';
import 'package:app_finance/pages/_interfaces/interface_page_inject.dart';
import 'package:app_finance/design/form/currency_exchange_input.dart';
import 'package:app_finance/design/form/date_time_input.dart';
import 'package:app_finance/design/button/full_sized_button_widget.dart';
import 'package:app_finance/design/wrapper/row_widget.dart';
import 'package:app_finance/design/form/simple_input.dart';
import 'package:app_finance/design/wrapper/single_scroll_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_currency_picker/flutter_currency_picker.dart';

class TransferTab<T> extends StatefulWidget {
  final String? accountFrom;
  final String? accountTo;
  final double? amount;
  final String? description;
  final Currency? currency;
  final DateTime? createdAt;
  final AppData state;
  final bool isLeft;
  final FnPageCallback callback;

  const TransferTab({
    super.key,
    required this.state,
    required this.callback,
    this.accountFrom,
    this.accountTo,
    this.amount,
    this.description,
    this.currency,
    this.createdAt,
    this.isLeft = false,
  });

  @override
  TransferTabState createState() => TransferTabState();
}

class TransferTabState<T extends TransferTab> extends State<T> {
  late FocusController focus;
  String? accountFrom;
  String? accountTo;
  Currency? accountFromCurrency;
  Currency? accountToCurrency;
  late TextEditingController amount;
  late TextEditingController description;
  late ExchangeController exchange;
  late DateTime createdAt;
  Currency? currency;
  bool hasErrors = false;
  bool isPushed = false;

  @override
  void initState() {
    focus = FocusController();
    accountFrom = widget.accountFrom;
    accountTo = widget.accountTo;
    createdAt = widget.createdAt ?? DateTime.now();
    amount = TextEditingController(text: widget.amount != null ? widget.amount.toString() : '');
    description = TextEditingController(text: widget.description);
    currency = widget.currency ?? Exchange.defaultCurrency;
    exchange = ExchangeController({}, store: widget.state, targetController: amount, target: currency, source: []);

    widget.callback((
      buildButton: buildButton,
      buttonName: getButtonName(),
      title: getTitle(),
    ));
    super.initState();
  }

  @override
  dispose() {
    isPushed = false;
    amount.dispose();
    description.dispose();
    exchange.dispose();
    focus.dispose();
    super.dispose();
  }

  bool hasFormErrors() {
    setState(() => hasErrors = accountFrom == null || accountTo == null);
    return hasErrors;
  }

  String getTitle() => AppLocale.labels.createBillHeader;

  void updateStorage() {
    exchange.save();
    widget.state.add(getValues());
  }

  InvoiceAppData getValues() => InvoiceAppData(
        title: description.text,
        color: widget.state.getByUuid(accountFrom ?? '')?.color,
        account: accountTo ?? '',
        accountFrom: accountFrom ?? '',
        details: double.tryParse(amount.text)?.toFixed(currency?.decimalDigits) ?? 0.0,
        currency: currency,
        createdAt: createdAt,
      );

  String getButtonName() => AppLocale.labels.createTransferTooltip;

  Widget buildButton(BuildContext context, BoxConstraints constraints) {
    final nav = Navigator.of(context);
    return FullSizedButtonWidget(
      constraints: constraints,
      controller: focus,
      onPressed: () => {
        setState(() {
          if (hasFormErrors()) {
            return;
          }
          updateStorage();
          nav.pop();
        })
      },
      title: getButtonName(),
      icon: Icons.save,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final indent = ThemeHelper.getIndent(2);
    return SingleScrollWrapper(
      controller: focus,
      child: Container(
        margin: EdgeInsets.fromLTRB(indent, indent, indent, 240),
        child: LayoutBuilder(builder: (context, constraints) {
          double width = constraints.maxWidth;
          return Column(
            crossAxisAlignment: AppDesign.getAlignment(),
            children: [
              InputWrapper(
                type: NamedInputType.accountSelector,
                isRequired: true,
                value: accountFrom != null ? widget.state.getByUuid(accountFrom!) : null,
                title: AppLocale.labels.accountFrom,
                tooltip: '${AppLocale.labels.titleAccountTooltip} (${AppLocale.labels.accountFrom})',
                showError: hasErrors && accountFrom == null,
                state: widget.state,
                onChange: (value) => setState(() {
                  accountFrom = value?.uuid;
                  if (value != null) {
                    accountFromCurrency = value.currency;
                    currency = accountFromCurrency;
                  }
                }),
                width: width,
              ),
              InputWrapper(
                type: NamedInputType.accountSelector,
                isRequired: true,
                value: accountTo != null ? widget.state.getByUuid(accountTo!) : null,
                title: AppLocale.labels.accountTo,
                tooltip: '${AppLocale.labels.titleAccountTooltip} (${AppLocale.labels.accountTo})',
                showError: hasErrors && accountTo == null,
                state: widget.state,
                onChange: (value) => setState(() {
                  accountTo = value?.uuid;
                  if (value != null) {
                    accountToCurrency = value.currency;
                    currency ??= accountToCurrency;
                  }
                }),
                width: width,
              ),
              RowWidget(
                indent: indent,
                maxWidth: width,
                chunk: const [125, null],
                children: [
                  [
                    InputWrapper.currency(
                      type: NamedInputType.currencyShort,
                      value: currency,
                      title: AppLocale.labels.currency,
                      tooltip: AppLocale.labels.currencyTooltip,
                      onChange: (value) => setState(() => currency = value),
                    ),
                  ],
                  [
                    InputWrapper.text(
                      title: AppLocale.labels.expenseTransfer,
                      tooltip: AppLocale.labels.billSetTooltip,
                      controller: amount,
                      inputType: const TextInputType.numberWithOptions(decimal: true),
                      formatter: [
                        SimpleInputFormatter.filterDouble,
                      ],
                    ),
                  ],
                ],
              ),
              CurrencyExchangeInput(
                key: ValueKey('transfer${currency?.code}${accountFromCurrency?.code}${accountToCurrency?.code}'),
                width: width + indent,
                indent: indent,
                target: currency,
                controller: exchange,
                source: [accountFromCurrency, accountToCurrency, Exchange.defaultCurrency],
              ),
              InputWrapper.text(
                title: AppLocale.labels.description,
                tooltip: AppLocale.labels.transferTooltip,
                controller: description,
              ),
              Text(
                AppLocale.labels.balanceDate,
                style: textTheme.bodyLarge,
              ),
              DateTimeInput(
                width: width - indent,
                value: createdAt,
                setState: (value) => setState(() => createdAt = value),
              ),
              ThemeHelper.formEndBox,
            ],
          );
        }),
      ),
    );
  }
}
