import 'package:hive_ce/hive_ce.dart';

part 'wheel_item.g.dart';

@HiveType(typeId: 1)
class WheelItem {
  @HiveField(0)
  String label;

  @HiveField(1)
  int colorValue;

  WheelItem({required this.label, required this.colorValue});
}
