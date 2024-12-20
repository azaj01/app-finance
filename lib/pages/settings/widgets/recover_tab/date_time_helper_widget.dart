// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_configs/theme_helper.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/design/wrapper/table_widget.dart';
import 'package:flutter/material.dart';

class DateTimeHelperWidget extends StatelessWidget {
  const DateTimeHelperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TableWidget(
      width: ThemeHelper.getWidth(context, 6),
      chunk: const [64, null, null],
      shadowColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
      data: [
        [Text(AppLocale.labels.symbol), Text(AppLocale.labels.meaning), Text(AppLocale.labels.example)],
        [const Text('y'), Text(AppLocale.labels.dtYear), const Text('2023')],
        [const Text('M'), Text(AppLocale.labels.dtMonth), const Text('July & 07')],
        [const Text('d'), Text(AppLocale.labels.dtDay), const Text('10')],
        [const Text('E'), Text(AppLocale.labels.dtNamedDay), const Text('Tuesday')],
        [const Text('h'), Text(AppLocale.labels.dtHalfHour), const Text('12')],
        [const Text('a'), Text(AppLocale.labels.dtAmPm), const Text('PM')],
        [const Text('H'), Text(AppLocale.labels.dtHour), const Text('18')],
        [const Text('m'), Text(AppLocale.labels.dtMinute), const Text('23')],
        [const Text('s'), Text(AppLocale.labels.dtSecond), const Text('48')],
        [const Text("'"), Text(AppLocale.labels.dtEscape), const Text("'Date='")],
        [const Text("''"), Text(AppLocale.labels.dtQuote), const Text("'o''clock'")],
      ],
    );
  }
}
