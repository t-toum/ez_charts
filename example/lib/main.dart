import 'dart:convert';
import 'package:ez_charts/ez_charts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});
  final String? title;
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<EzLineEntity>? datas;
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  bool _volHidden = false;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = true;
  bool _hideGrid = true;
  bool _showNowPrice = true;
  bool isChangeUI = false;
  bool _isTrendLine = false;
  bool _priceLeft = true;
  VerticalTextAlignment _verticalTextAlignment = VerticalTextAlignment.left;

  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();

  @override
  void initState() {
    super.initState();
    getData('1day');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Stack(
          children: <Widget>[
            SizedBox(
              height: 450,
              width: double.infinity,
              child: EzChartsWidget(
                datas,
                chartStyle,
                chartColors,
                isLine: isLine,
                isTrendLine: _isTrendLine,
                mainState: _mainState,
                volHidden: _volHidden,
                secondaryState: _secondaryState,
                fixedLength: 2,
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                showNowPrice: _showNowPrice,
                hideGrid: _hideGrid,
                isTapShowInfoDialog: false,
                verticalTextAlignment: _verticalTextAlignment,
                maDayList: const [1, 100, 1000],
                // showMaxPrice: false,
                // showMinPrice: false,
              ),
            ),
            if (showLoading)
              Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
        buildButtons(),
      ],
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("Time Mode", onPressed: () => isLine = true),
        button("K Line Mode", onPressed: () => isLine = false),
        button("TrendLine", onPressed: () => _isTrendLine = !_isTrendLine),
        button("Line:MA", onPressed: () => _mainState = MainState.MA),
        button("Line:BOLL", onPressed: () => _mainState = MainState.BOLL),
        button("Hide Line", onPressed: () => _mainState = MainState.NONE),
        button(
          "Secondary Chart:MACD",
          onPressed: () => _secondaryState = SecondaryState.MACD,
        ),
        button(
          "Secondary Chart:KDJ",
          onPressed: () => _secondaryState = SecondaryState.KDJ,
        ),
        button(
          "Secondary Chart:RSI",
          onPressed: () => _secondaryState = SecondaryState.RSI,
        ),
        button(
          "Secondary Chart:WR",
          onPressed: () => _secondaryState = SecondaryState.WR,
        ),
        button(
          "Secondary Chart:CCI",
          onPressed: () => _secondaryState = SecondaryState.CCI,
        ),
        button(
          "Secondary Chart:Hide",
          onPressed: () => _secondaryState = SecondaryState.NONE,
        ),
        button(
          _volHidden ? "Show Vol" : "Hide Vol",
          onPressed: () => _volHidden = !_volHidden,
        ),
        button(
          _hideGrid ? "Show Grid" : "Hide Grid",
          onPressed: () => _hideGrid = !_hideGrid,
        ),
        button(
          _showNowPrice ? "Hide Now Price" : "Show Now Price",
          onPressed: () => _showNowPrice = !_showNowPrice,
        ),
        button(
          "Customize UI",
          onPressed: () {
            setState(() {
              isChangeUI = !isChangeUI;
              if (isChangeUI) {
                chartColors.selectBorderColor = Colors.red;
                chartColors.selectFillColor = Colors.red;
                chartColors.lineFillColor = Colors.red;
                chartColors.kLineColor = Colors.yellow;
              } else {
                chartColors.selectBorderColor = const Color(0xff6C7A86);
                chartColors.selectFillColor = const Color(0xff0D1722);
                chartColors.lineFillColor = const Color(0x554C86CD);
                chartColors.kLineColor = const Color(0xff4C86CD);
              }
            });
          },
        ),
        button(
          "Change PriceTextPaint",
          onPressed: () => setState(() {
            _priceLeft = !_priceLeft;
            if (_priceLeft) {
              _verticalTextAlignment = VerticalTextAlignment.left;
            } else {
              _verticalTextAlignment = VerticalTextAlignment.right;
            }
          }),
        ),
      ],
    );
  }

  Widget button(String text, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      style: TextButton.styleFrom(
        // primary: Colors.white,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: Colors.blue,
      ),
      child: Text(text),
    );
  }

  Future<void> getData(String period) async {
    try {
      String url =
          'https://api.huobi.br.com/market/history/kline?period=$period&size=300&symbol=btcusdt';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map parseJson =
            json.decode(response.body) as Map<dynamic, dynamic>;
        final list = parseJson['data'] as List<dynamic>;
        datas = list
            .map(
              (item) => EzLineEntity.fromJson(item as Map<String, dynamic>),
            )
            .toList()
            .reversed
            .toList()
            .cast<EzLineEntity>();
        DataUtil.calculate(datas!);
        showLoading = false;
        setState(() {});
      } else {
        showLoading = false;
        setState(() {});
        debugPrint('### datas error ');
      }
    } catch (err) {
      showLoading = false;
      setState(() {});
      debugPrint('### datas error ');
    }
  }
}
