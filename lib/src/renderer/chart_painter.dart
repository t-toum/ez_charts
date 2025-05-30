import 'dart:async' show StreamSink;
import 'package:ez_charts/src/entities/ez_line_entity.dart';
import 'package:ez_charts/src/entities/info_window_entity.dart';
import 'package:ez_charts/src/renderer/base_chart_painter.dart';
import 'package:ez_charts/src/renderer/secondary_renderer.dart';
import 'package:ez_charts/src/renderer/vol_renderer.dart';
import 'package:ez_charts/src/utils/number_util.dart';
import 'package:flutter/material.dart';
import '../utils/date_format_util.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';

class TrendLine {
  final Offset p1;
  final Offset p2;
  final double maxHeight;
  final double scale;
  TrendLine(this.p1, this.p2, this.maxHeight, this.scale);
}

double? trendLineX;

double getTrendLineX() {
  return trendLineX ?? 0;
}

class ChartPainter extends BaseChartPainter {
  final List<TrendLine> lines; //For TrendLine
  final bool isTrendLine; //For TrendLine
  bool isrecordingCord = false; //For TrendLine
  final double selectY; //For TrendLine
  static get maxScrollX => BaseChartPainter.maxScrollX;
  late BaseChartRenderer mMainRenderer;
  BaseChartRenderer? mVolRenderer, mSecondaryRenderer;
  StreamSink<InfoWindowEntity?>? sink;
  Color? upColor, dnColor;
  Color? ma5Color, ma10Color, ma30Color;
  Color? volColor;
  Color? macdColor, difColor, deaColor, jColor;
  int fixedLength;
  List<int> maDayList;
  final ChartColors chartColors;
  late Paint selectPointPaint, selectorBorderPaint, nowPricePaint;
  final bool hideGrid;
  final bool showNowPrice;
  final VerticalTextAlignment verticalTextAlignment;

  final bool showMaxPrice;
  final bool showMinPrice;

  ChartPainter(
    ChartStyle chartStyle,
    this.chartColors, {
    required this.lines, //For TrendLine
    required this.isTrendLine, //For TrendLine
    required this.selectY, //For TrendLine
    required datas,
    required scaleX,
    required scrollX,
    required isLongPass,
    required selectX,
    required xFrontPadding,
    required this.showMaxPrice,
    required this.showMinPrice,
    bool isOnTap = false,
    isTapShowInfoDialog,
    required this.verticalTextAlignment,
    mainState,
    volHidden,
    secondaryState,
    this.sink,
    bool isLine = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
  }) : super(
         chartStyle,
         datas: datas,
         scaleX: scaleX,
         scrollX: scrollX,
         isLongPress: isLongPass,
         isOnTap: isOnTap,
         isTapShowInfoDialog: isTapShowInfoDialog,
         selectX: selectX,
         mainState: mainState,
         volHidden: volHidden,
         secondaryState: secondaryState,
         xFrontPadding: xFrontPadding,
         isLine: isLine,
       ) {
    selectPointPaint =
        Paint()
          ..isAntiAlias = true
          ..strokeWidth = 0.5
          ..color = chartColors.selectFillColor;
    selectorBorderPaint =
        Paint()
          ..isAntiAlias = true
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke
          ..color = chartColors.selectBorderColor;
    nowPricePaint =
        Paint()
          ..strokeWidth = chartStyle.nowPriceLineWidth
          ..isAntiAlias = true;
  }

  @override
  void initChartRenderer() {
    if (datas != null && datas!.isNotEmpty) {
      var t = datas![0];
      fixedLength = NumberUtil.getMaxDecimalLength(
        t.open,
        t.close,
        t.high,
        t.low,
      );
    }
    mMainRenderer = MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      mTopPadding,
      mainState,
      isLine,
      fixedLength,
      chartStyle,
      chartColors,
      scaleX,
      verticalTextAlignment,
      maDayList,
    );
    if (mVolRect != null) {
      mVolRenderer = VolRenderer(
        mVolRect!,
        mVolMaxValue,
        mVolMinValue,
        mChildPadding,
        fixedLength,
        chartStyle,
        chartColors,
      );
    }
    if (mSecondaryRect != null) {
      mSecondaryRenderer = SecondaryRenderer(
        mSecondaryRect!,
        mSecondaryMaxValue,
        mSecondaryMinValue,
        mChildPadding,
        secondaryState,
        fixedLength,
        chartStyle,
        chartColors,
      );
    }
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: chartColors.bgColor,
    );
    Rect mainRect = Rect.fromLTRB(
      0,
      0,
      mMainRect.width,
      mMainRect.height + mTopPadding,
    );
    canvas.drawRect(
      mainRect,
      mBgPaint..shader = mBgGradient.createShader(mainRect),
    );

    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(
        0,
        mVolRect!.top - mChildPadding,
        mVolRect!.width,
        mVolRect!.bottom,
      );
      canvas.drawRect(
        volRect,
        mBgPaint..shader = mBgGradient.createShader(volRect),
      );
    }

    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(
        0,
        mSecondaryRect!.top - mChildPadding,
        mSecondaryRect!.width,
        mSecondaryRect!.bottom,
      );
      canvas.drawRect(
        secondaryRect,
        mBgPaint..shader = mBgGradient.createShader(secondaryRect),
      );
    }
    Rect dateRect = Rect.fromLTRB(
      0,
      size.height - mBottomPadding,
      size.width,
      size.height,
    );
    canvas.drawRect(
      dateRect,
      mBgPaint..shader = mBgGradient.createShader(dateRect),
    );
  }

  @override
  void drawGrid(canvas) {
    if (!hideGrid) {
      mMainRenderer.drawGrid(canvas, mGridRows, mGridColumns);
      mVolRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
      mSecondaryRenderer?.drawGrid(canvas, mGridRows, mGridColumns);
    }
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      EzLineEntity? curPoint = datas?[i];
      if (curPoint == null) continue;
      EzLineEntity lastPoint = i == 0 ? curPoint : datas![i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryRenderer?.drawChart(
        lastPoint,
        curPoint,
        lastX,
        curX,
        size,
        canvas,
      );
    }

    if ((isLongPress == true || (isTapShowInfoDialog && isOnTap)) &&
        isTrendLine == false) {
      drawCrossLine(canvas, size);
    }
    if (isTrendLine == true) drawTrendLines(canvas, size);
    canvas.restore();
  }

  @override
  void drawVerticalText(canvas) {
    var textStyle = getTextStyle(chartColors.defaultTextColor);
    if (!hideGrid) {
      mMainRenderer.drawVerticalText(canvas, textStyle, mGridRows);
    }
    mVolRenderer?.drawVerticalText(canvas, textStyle, mGridRows);
    mSecondaryRenderer?.drawVerticalText(canvas, textStyle, mGridRows);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    if (datas == null) return;

    double columnSpace = size.width / mGridColumns;
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double x = 0.0;
    double y = 0.0;
    for (var i = 0; i <= mGridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);

      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);

        if (datas?[index] == null) continue;
        TextPainter tp = getTextPainter(getDate(datas![index].time), null);
        y = size.height - (mBottomPadding - tp.height) / 2 - tp.height;
        x = columnSpace * i - tp.width / 2;
        // Prevent date text out of canvas
        if (x < 0) x = 0;
        if (x > size.width - tp.width) x = size.width - tp.width;
        tp.paint(canvas, Offset(x, y));
      }
    }

    //    double translateX = xToTranslateX(0);
    //    if (translateX >= startX && translateX <= stopX) {
    //      TextPainter tp = getTextPainter(getDate(datas[mStartIndex].id));
    //      tp.paint(canvas, Offset(0, y));
    //    }
    //    translateX = xToTranslateX(size.width);
    //    if (translateX >= startX && translateX <= stopX) {
    //      TextPainter tp = getTextPainter(getDate(datas[mStopIndex].id));
    //      tp.paint(canvas, Offset(size.width - tp.width, y));
    //    }
  }

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    EzLineEntity point = getItem(index);

    TextPainter tp = getTextPainter(point.close, chartColors.crossTextColor);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = 1;
      Path path = Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = mWidth - textWidth - 1 - 2 * w1 - w2;
      Path path = Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(mWidth - 2, y + r);
      path.lineTo(mWidth - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter dateTp = getTextPainter(
      getDate(point.time),
      chartColors.crossTextColor,
    );
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = size.height - mBottomPadding;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - w1,
        y,
        x + textWidth / 2 + w1,
        y + baseLine + r,
      ),
      selectPointPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - w1,
        y,
        x + textWidth / 2 + w1,
        y + baseLine + r,
      ),
      selectorBorderPaint,
    );

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));
    sink?.add(InfoWindowEntity(point, isLeft: isLeft));
  }

  @override
  void drawText(Canvas canvas, EzLineEntity data, double x) {
    if (isLongPress || (isTapShowInfoDialog && isOnTap)) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    mMainRenderer.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;
    double lineSize = 20;
    double lineToTextOffset = 5;

    Paint linePaint = Paint()..strokeWidth = 1;
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);

    //Min price
    if (showMinPrice) {
      if (x < mWidth / 2) {
        TextPainter tp = getTextPainter(
          mMainLowMinValue.toStringAsFixed(fixedLength),
          chartColors.minColor,
        );

        canvas.drawLine(
          Offset(x, y),
          Offset(x + lineSize, y),
          linePaint..color = chartColors.minColor,
        );

        tp.paint(
          canvas,
          Offset(x + lineSize + lineToTextOffset, y - tp.height / 2),
        );
      } else {
        TextPainter tp = getTextPainter(
          mMainLowMinValue.toStringAsFixed(fixedLength),
          chartColors.minColor,
        );

        canvas.drawLine(
          Offset(x, y),
          Offset(x - lineSize, y),
          linePaint..color = chartColors.minColor,
        );

        tp.paint(
          canvas,
          Offset(x - tp.width - lineSize - lineToTextOffset, y - tp.height / 2),
        );
      }
    }

    //Max price
    if (showMaxPrice) {
      x = translateXtoX(getX(mMainMaxIndex));
      y = getMainY(mMainHighMaxValue);
      if (x < mWidth / 2) {
        TextPainter tp = getTextPainter(
          mMainHighMaxValue.toStringAsFixed(fixedLength),
          chartColors.maxColor,
        );

        canvas.drawLine(
          Offset(x, y),
          Offset(x + lineSize, y),
          linePaint..color = chartColors.maxColor,
        );

        tp.paint(
          canvas,
          Offset(x + lineSize + lineToTextOffset, y - tp.height / 2),
        );
      } else {
        TextPainter tp = getTextPainter(
          mMainHighMaxValue.toStringAsFixed(fixedLength),
          chartColors.maxColor,
        );

        canvas.drawLine(
          Offset(x, y),
          Offset(x - lineSize, y),
          linePaint..color = chartColors.maxColor,
        );

        tp.paint(
          canvas,
          Offset(x - tp.width - lineSize - lineToTextOffset, y - tp.height / 2),
        );
      }
    }
  }

  @override
  void drawNowPrice(Canvas canvas) {
    if (!showNowPrice) {
      return;
    }

    if (datas == null) {
      return;
    }

    double value = datas!.last.close;
    double y = getMainY(value);

    if (y > getMainY(mMainLowMinValue)) {
      y = getMainY(mMainLowMinValue);
    }

    if (y < getMainY(mMainHighMaxValue)) {
      y = getMainY(mMainHighMaxValue);
    }

    nowPricePaint.color =
        value >= datas!.last.open
            ? chartColors.nowPriceUpColor
            : chartColors.nowPriceDnColor;
    double startX = 0;
    final max = -mTranslateX + mWidth / scaleX;
    final space = chartStyle.nowPriceLineSpan + chartStyle.nowPriceLineLength;
    while (startX < max) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + chartStyle.nowPriceLineLength, y),
        nowPricePaint,
      );
      startX += space;
    }
    TextPainter tp = getTextPainter(
      value.toStringAsFixed(fixedLength),
      chartColors.nowPriceTextColor,
    );

    double offsetX;
    switch (verticalTextAlignment) {
      case VerticalTextAlignment.left:
        offsetX = 0;
        break;
      case VerticalTextAlignment.right:
        offsetX = mWidth - tp.width;
        break;
    }

    double top = y - tp.height / 2;
    canvas.drawRect(
      Rect.fromLTRB(offsetX, top, offsetX + tp.width, top + tp.height),
      nowPricePaint,
    );
    tp.paint(canvas, Offset(offsetX, top));
  }

  //For TrendLine
  void drawTrendLines(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    Paint paintY =
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..isAntiAlias = true;
    double x = getX(index);
    trendLineX = x;

    double y = selectY;
    // getMainY(point.close);

    canvas.drawLine(
      Offset(x, mTopPadding),
      Offset(x, size.height - mBottomPadding),
      paintY,
    );
    Paint paintX =
        Paint()
          ..color = Colors.orangeAccent
          ..strokeWidth = 1
          ..isAntiAlias = true;
    Paint paint =
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintX,
    );
    if (scaleX >= 1) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          height: 15.0 * scaleX,
          width: 15.0,
        ),
        paint,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          height: 10.0,
          width: 10.0 / scaleX,
        ),
        paint,
      );
    }
    if (lines.isNotEmpty) {
      for (TrendLine element in lines) {
        var y1 = -((element.p1.dy - 35) / element.scale) + element.maxHeight;
        var y2 = -((element.p2.dy - 35) / element.scale) + element.maxHeight;
        var a = (trendLineMax! - y1) * trendLineScale! + trendLineContentRec!;
        var b = (trendLineMax! - y2) * trendLineScale! + trendLineContentRec!;
        var p1 = Offset(element.p1.dx, a);
        var p2 = Offset(element.p2.dx, b);
        canvas.drawLine(
          p1,
          element.p2 == Offset(-1, -1) ? Offset(x, y) : p2,
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  void drawCrossLine(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    EzLineEntity point = getItem(index);
    Paint paintY =
        Paint()
          ..color = chartColors.vCrossColor
          ..strokeWidth = chartStyle.vCrossWidth
          ..isAntiAlias = true;
    double x = getX(index);
    double y = getMainY(point.close);
    canvas.drawLine(
      Offset(x, mTopPadding),
      Offset(x, size.height - mBottomPadding),
      paintY,
    );

    Paint paintX =
        Paint()
          ..color = chartColors.hCrossColor
          ..strokeWidth = chartStyle.hCrossWidth
          ..isAntiAlias = true;
    canvas.drawLine(
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintX,
    );
    if (scaleX >= 1) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0 * scaleX, width: 2.0),
        paintX,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0, width: 2.0 / scaleX),
        paintX,
      );
    }
  }

  TextPainter getTextPainter(text, color) {
    color ??= chartColors.defaultTextColor;
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(int? date) => dateFormat(
    DateTime.fromMillisecondsSinceEpoch(
      date ?? DateTime.now().millisecondsSinceEpoch,
    ),
    mFormats,
  );

  double getMainY(double y) => mMainRenderer.getY(y);

  bool isInSecondaryRect(Offset point) {
    return mSecondaryRect?.contains(point) ?? false;
  }

  bool isInMainRect(Offset point) {
    return mMainRect.contains(point);
  }
}
