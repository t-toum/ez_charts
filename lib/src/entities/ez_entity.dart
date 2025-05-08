import 'package:ez_charts/src/entities/candle_entity.dart';
import 'package:ez_charts/src/entities/cci_entity.dart';
import 'package:ez_charts/src/entities/kdj_entity.dart';
import 'package:ez_charts/src/entities/macd_entity.dart';
import 'package:ez_charts/src/entities/rsi_entity.dart';
import 'package:ez_charts/src/entities/rw_entity.dart';
import 'package:ez_charts/src/entities/volume_entity.dart';

class EzEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {}
