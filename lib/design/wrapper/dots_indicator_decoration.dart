// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class DotsIndicatorDecoration extends Decoration {
  final PageController controller;
  final int itemCount;
  final Color color;
  final double dotSize;
  final double _spacing;

  const DotsIndicatorDecoration({
    required this.controller,
    required this.itemCount,
    required this.color,
    required this.dotSize,
    double? spacing,
  }) : _spacing = spacing ?? dotSize;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      controller: controller,
      itemCount: itemCount,
      color: color,
      dotSize: dotSize,
      spacing: _spacing,
      onChanged: onChanged,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final PageController controller;
  final int itemCount;
  final Color color;
  final double dotSize;
  final double spacing;

  _CustomTabIndicatorPainter({
    required this.controller,
    required this.itemCount,
    required this.color,
    required this.dotSize,
    required this.spacing,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (itemCount <= 1) {
      return;
    }
    final activeIndex = controller.page?.round() ?? controller.initialPage;
    final active = Paint()..color = color;
    final inactive = Paint()..color = color.withValues(alpha: 0.3);
    for (int i = 0; i < itemCount; i++) {
      double xPos = spacing + i * (dotSize + spacing);
      double yPos = spacing * 0.6;
      if (i == activeIndex) {
        canvas.drawCircle(Offset(xPos, yPos), dotSize / 2, active);
      } else {
        canvas.drawCircle(Offset(xPos, yPos), dotSize / 2, inactive);
      }
    }
  }
}
