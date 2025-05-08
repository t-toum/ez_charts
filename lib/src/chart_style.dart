import 'package:flutter/material.dart' show Color;

class ChartColors {
  List<Color> bgColor = const [Color(0xff18191d), Color(0xff18191d)];

  Color kLineColor = const Color(0xff4C86CD);
  Color lineFillColor = const Color(0x554C86CD);
  Color lineFillInsideColor = const Color(0x00000000);
  Color ma5Color = const Color(0xffC9B885);
  Color ma10Color = const Color(0xff6CB0A6);
  Color ma30Color = const Color(0xff9979C6);
  Color upColor = const Color(0xff4DAA90);
  Color dnColor = const Color(0xffC15466);
  Color volColor = const Color(0xff4729AE);

  Color macdColor = const Color(0xff4729AE);
  Color difColor = const Color(0xffC9B885);
  Color deaColor = const Color(0xff6CB0A6);

  Color kColor = const Color(0xffC9B885);
  Color dColor = const Color(0xff6CB0A6);
  Color jColor = const Color(0xff9979C6);
  Color rsiColor = const Color(0xffC9B885);

  Color defaultTextColor = const Color(0xff60738E);

  Color nowPriceUpColor = const Color(0xff4DAA90);
  Color nowPriceDnColor = const Color(0xffC15466);
  Color nowPriceTextColor = const Color(0xffffffff);

  Color depthBuyColor = const Color(0xff60A893);
  Color depthSellColor = const Color(0xffC15866);

  Color selectBorderColor = const Color(0xff6C7A86);

  Color selectFillColor = const Color(0xff0D1722);

  Color gridColor = const Color(0xff4c5c74);

  Color infoWindowNormalColor = const Color(0xffffffff);
  Color infoWindowTitleColor = const Color(0xffffffff);
  Color infoWindowUpColor = const Color(0xff00ff00);
  Color infoWindowDnColor = const Color(0xffff0000);

  Color hCrossColor = const Color(0xffffffff);
  Color vCrossColor = const Color(0x1Effffff);
  Color crossTextColor = const Color(0xffffffff);

  Color maxColor = const Color(0xffffffff);
  Color minColor = const Color(0xffffffff);

  Color getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }
}

class ChartStyle {
  double topPadding = 30.0;

  double bottomPadding = 20.0;

  double childPadding = 12.0;

  double pointWidth = 11.0;

  double candleWidth = 8.5;

  double candleLineWidth = 1.5;

  double volWidth = 8.5;

  double macdWidth = 3.0;

  double vCrossWidth = 8.5;

  double hCrossWidth = 0.5;

  double nowPriceLineLength = 1;

  double nowPriceLineSpan = 1;

  double nowPriceLineWidth = 1;

  int gridRows = 4;

  int gridColumns = 4;

  List<String>? dateTimeFormat;
}
