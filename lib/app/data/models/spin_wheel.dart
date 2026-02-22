import 'package:hive_ce/hive_ce.dart';

import 'package:spin_wheel_picker/app/data/models/wheel_item.dart';

part 'spin_wheel.g.dart';

@HiveType(typeId: 0)
class SpinWheel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late List<WheelItem> items;

  @HiveField(3)
  late List<String> resultHistory;

  SpinWheel({
    required this.id,
    required this.name,
    required this.items,
    List<String>? resultHistory,
  }) : resultHistory = resultHistory ?? [];
}
