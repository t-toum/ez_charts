import 'package:ez_charts/src/entities/volume_entity.dart';
import 'package:ez_charts/src/extensions/num_ext.dart';
import 'package:ez_charts/src/renderer/base_chart_renderer.dart';
import 'package:ez_charts/src/utils/number_util.dart';
import 'package:flutter/material.dart';

class VolRenderer extends BaseChartRenderer<VolumeEntity> {
  late double mVolWidth;
  final ChartStyle chartStyle;
  final ChartColors chartColors;

  VolRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    int fixedLength,
    this.chartStyle,
    this.chartColors,
  ) : super(
        chartRect: mainRect,
        maxValue: maxValue,
        minValue: minValue,
        topPadding: topPadding,
        fixedLength: fixedLength,
        gridColor: chartColors.gridColor,
      ) {
    mVolWidth = chartStyle.volWidth;
  }

  @override
  void drawChart(
    VolumeEntity lastPoint,
    VolumeEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;
    if (curPoint.vol != 0) {
      canvas.drawRect(
        Rect.fromLTRB(curX - r, top, curX + r, bottom),
        chartPaint
          ..color =
              curPoint.close > curPoint.open
                  ? chartColors.upColor
                  : chartColors.dnColor,
      );
    }

    if (lastPoint.MA5Volume != 0) {
      drawLine(
        lastPoint.MA5Volume,
        curPoint.MA5Volume,
        canvas,
        lastX,
        curX,
        chartColors.ma5Color,
      );
    }

    if (lastPoint.MA10Volume != 0) {
      drawLine(
        lastPoint.MA10Volume,
        curPoint.MA10Volume,
        canvas,
        lastX,
        curX,
        chartColors.ma10Color,
      );
    }
  }

  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawText(Canvas canvas, VolumeEntity data, double x) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(
          text: "VOL:${NumberUtil.format(data.vol)}    ",
          style: getTextStyle(chartColors.volColor),
        ),
        if (data.MA5Volume.notNullOrZero)
          TextSpan(
            text: "MA5:${NumberUtil.format(data.MA5Volume!)}    ",
            style: getTextStyle(chartColors.ma5Color),
          ),
        if (data.MA10Volume.notNullOrZero)
          TextSpan(
            text: "MA10:${NumberUtil.format(data.MA10Volume!)}    ",
            style: getTextStyle(chartColors.ma10Color),
          ),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextSpan span = TextSpan(
      text: NumberUtil.format(maxValue),
      style: textStyle,
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(chartRect.width - tp.width, chartRect.top - topPadding),
    );
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(
      Offset(0, chartRect.bottom),
      Offset(chartRect.width, chartRect.bottom),
      gridPaint,
    );
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }
}
