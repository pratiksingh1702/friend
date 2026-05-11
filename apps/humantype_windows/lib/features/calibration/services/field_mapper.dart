import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class FieldMapEntry {
  final String id;
  final String name;
  final double x;
  final double y;
  final double screenWidth;
  final double screenHeight;

  FieldMapEntry({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.screenWidth,
    required this.screenHeight,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'x': x,
        'y': y,
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
      };

  factory FieldMapEntry.fromMap(Map<dynamic, dynamic> m) => FieldMapEntry(
        id: m['id'] as String,
        name: m['name'] as String,
        x: m['x'] as double,
        y: m['y'] as double,
        screenWidth: m['screenWidth'] as double,
        screenHeight: m['screenHeight'] as double,
      );
}

class FieldMapperNotifier extends StateNotifier<List<FieldMapEntry>> {
  static const String _boxName = 'field_maps';
  Box? _box;

  FieldMapperNotifier() : super([]);

  Future<void> load() async {
    _box = await Hive.openBox(_boxName);
    final saved = _box?.values;
    if (saved != null) {
      state = saved.map((e) => FieldMapEntry.fromMap(e as Map)).toList();
    }
  }

  void addEntry(String name, double x, double y, double sw, double sh) {
    final entry = FieldMapEntry(
      id: const Uuid().v4(),
      name: name,
      x: x,
      y: y,
      screenWidth: sw,
      screenHeight: sh,
    );
    state = [...state, entry];
    _box?.put(entry.id, entry.toMap());
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
    _box?.delete(id);
  }
}

final fieldMapperProvider = StateNotifierProvider<FieldMapperNotifier, List<FieldMapEntry>>((ref) {
  final notifier = FieldMapperNotifier();
  notifier.load();
  return notifier;
});
