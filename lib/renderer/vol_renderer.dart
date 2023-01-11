import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';

class VolRenderer extends BaseChartRenderer<VolumeEntity> {
  late double mVolWidth;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  // added by sumong : Volume Chart Type.
  VolState volState;
  // added by sumong : whether to hide the text(`VOL:~~~  MA5:~~~  MA10:~~~`) in Volume Chart
  bool volTextHidden;

  /// changed by sumong : add [volState], [volTextHidden]
  VolRenderer(Rect mainRect, double maxValue, double minValue,
      double topPadding, this.volState, this.volTextHidden, int fixedLength, this.chartStyle, this.chartColors)
      : super(
    chartRect: mainRect,
    maxValue: maxValue,
    minValue: minValue,
    topPadding: topPadding,
    fixedLength: fixedLength,
    gridColor: chartColors.gridColor,) {
    mVolWidth = this.chartStyle.volWidth;
  }

  /// modified by sumong : applying [chartStyle.volRadius], [chartColors.volBarColor], and [volState]
  @override
  void drawChart(VolumeEntity lastPoint, VolumeEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;
    if (curPoint.vol != 0) {
      // case 1. if volRadius == 0 : just draw Rect.
      if (chartStyle.volRadius == 0) {
        // if volBarColor is not null, volBarColor use for bar color.
        canvas.drawRect(
            Rect.fromLTRB(curX - r, top, curX + r, bottom),
            chartPaint
              ..color = (chartColors.volBarColor != null)
                  ? chartColors.volBarColor! :
              curPoint.close > curPoint.open
                  ? this.chartColors.upColor
                  : this.chartColors.dnColor);
      }
      // case 2. if volRadius != 0 : draw RRect.
      else {
        // if volBarColor is not null, volBarColor use for bar color.
        canvas.drawRRect(
            RRect.fromLTRBR(curX - r, top, curX + r, bottom, Radius.circular(chartStyle.volRadius)),
            chartPaint
              ..color = (chartColors.volBarColor != null)
                  ? chartColors.volBarColor! :
              curPoint.close > curPoint.open
                  ? this.chartColors.upColor
                  : this.chartColors.dnColor);
      }
    }

    /// if volState is [VolState.ALL] or [VolState.MA5], show MA5 Line Chart.
    if (lastPoint.MA5Volume != 0 && (volState == VolState.ALL || volState == VolState.MA5)) {
      drawLine(lastPoint.MA5Volume, curPoint.MA5Volume, canvas, lastX, curX,
          this.chartColors.ma5Color);
    }

    /// if volState is [VolState.ALL] or [VolState.MA10], show MA10 Line Chart.
    if (lastPoint.MA10Volume != 0 && (volState == VolState.ALL || volState == VolState.MA10)) {
      drawLine(lastPoint.MA10Volume, curPoint.MA10Volume, canvas, lastX, curX,
          this.chartColors.ma10Color);
    }
  }

  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawText(Canvas canvas, VolumeEntity data, double x) {
    /// changed by sumong : If [volTextHidden] is false, draw text (`VOL:~~~  MA5:~~~  MA10:~~~`)
    if(volTextHidden == false) {
      TextSpan span = TextSpan(
        children: [
          TextSpan(
              text: "VOL:${NumberUtil.format(data.vol)}    ",
              style: getTextStyle(this.chartColors.volColor)),

          /// changed by sumong : if volState is [VolState.ALL] or [VolState.MA5], show below text.
          if (data.MA5Volume.notNullOrZero &&
              (volState == VolState.ALL || volState == VolState.MA5))
            TextSpan(
                text: "MA5:${NumberUtil.format(data.MA5Volume!)}    ",
                style: getTextStyle(this.chartColors.ma5Color)),

          /// changed by sumong : if volState is [VolState.ALL] or [VolState.MA10], show below text.
          if (data.MA10Volume.notNullOrZero &&
              (volState == VolState.ALL || volState == VolState.MA10))
            TextSpan(
                text: "MA10:${NumberUtil.format(data.MA10Volume!)}    ",
                style: getTextStyle(this.chartColors.ma10Color)),
        ],
      );
      TextPainter tp = TextPainter(
          text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(x, chartRect.top - topPadding));
    }
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextSpan span =
    TextSpan(text: "${NumberUtil.format(maxValue)}", style: textStyle);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas, Offset(chartRect.width - tp.width, chartRect.top - topPadding));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
