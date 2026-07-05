import 'package:nova_assistant/core/services/database_service.dart';

import '../models/alarm_model.dart';

/// Local data source for alarm CRUD operations using SQLite
class AlarmLocalDatasource {
  static const String _tableName = 'alarms';

  /// Fetch all alarms ordered by hour and minute
  Future<List<AlarmModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _tableName,
      orderBy: 'hour ASC, minute ASC',
    );
    return maps.map((map) => AlarmModel.fromMap(map)).toList();
  }

  /// Insert a new alarm
  Future<void> insert(AlarmModel alarm) async {
    final db = await DatabaseService.instance.database;
    await db.insert(_tableName, alarm.toMap());
  }

  /// Update an existing alarm
  Future<void> update(AlarmModel alarm) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      _tableName,
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  /// Delete an alarm by ID
  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle the enabled state of an alarm
  Future<void> toggleEnabled(String id, bool isEnabled) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      _tableName,
      {'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
