import 'package:hive_ce/hive_ce.dart';

part 'wheel_item.g.dart';

@HiveType(typeId: 1)
class WheelItem {
  @HiveField(0)
  String label;

  @HiveField(1)
  int colorValue;

  /// User-chosen color override. If null, colorValue (auto-assigned) is used.
  @HiveField(2)
  int? customColorValue;

  WheelItem({required this.label, required this.colorValue, this.customColorValue});

  int get effectiveColorValue => customColorValue ?? colorValue;
}
