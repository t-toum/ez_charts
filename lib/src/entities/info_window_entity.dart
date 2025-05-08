
import 'package:ez_charts/src/entities/ez_line_entity.dart';

class InfoWindowEntity {
  EzLineEntity kLineEntity;
  bool isLeft;

  InfoWindowEntity(
    this.kLineEntity, {
    this.isLeft = false,
  });
}
