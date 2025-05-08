import 'package:ez_charts/src/entities/ez_entity.dart';

class EzLineEntity extends EzEntity {
  late double? amount;
  double? change;
  double? ratio;
  int? time;

  EzLineEntity.fromCustom({
    this.amount,
    required double open,
    required double close,
    this.change,
    this.ratio,
    required this.time,
    required double high,
    required double low,
    required double vol,
  }) {
    this.open = open;
    this.close = close;
    this.high = high;
    this.low = low;
    this.vol = vol;
  }

  EzLineEntity.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toDouble() ?? 0;
    high = json['high']?.toDouble() ?? 0;
    low = json['low']?.toDouble() ?? 0;
    close = json['close']?.toDouble() ?? 0;
    vol = json['vol']?.toDouble() ?? 0;
    amount = json['amount']?.toDouble();
    int? tempTime = json['time']?.toInt();
    if (tempTime == null) {
      tempTime = json['id']?.toInt() ?? 0;
      tempTime = tempTime! * 1000;
    }
    time = tempTime;
    ratio = json['ratio']?.toDouble();
    change = json['change']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['open'] = open;
    data['close'] = close;
    data['high'] = high;
    data['low'] = low;
    data['vol'] = vol;
    data['amount'] = amount;
    data['ratio'] = ratio;
    data['change'] = change;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, time: $time, amount: $amount, ratio: $ratio, change: $change}';
  }
}
