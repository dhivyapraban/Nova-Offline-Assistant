import 'package:sqflite/sqflite.dart';
import 'package:nova_assistant/core/services/database_service.dart';

import '../models/app_settings_model.dart';

/// Local datasource for settings using SQLite (via DatabaseService).
class SettingsLocalDatasource {
  /// Retrieves all settings from the database as a key-value map.
  Future<AppSettingsModel> getSettings() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('settings');

    final settingsMap = <String, String>{};
    for (final row in maps) {
      final key = row['key'] as String;
      final value = row['value'] as String;
      settingsMap[key] = value;
    }

    return AppSettingsModel.fromMap(settingsMap);
  }

  /// Updates a single setting in the database.
  /// Uses INSERT OR REPLACE to handle both create and update.
  Future<void> updateSetting(String key, String value) async {
    final db = await DatabaseService.instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Resets all settings to their default values.
  Future<void> resetSettings() async {
    final db = await DatabaseService.instance.database;
    await db.delete('settings');

    // Re-insert defaults
    final defaults = AppSettingsModel.defaults.toMap();
    for (final entry in defaults.entries) {
      await db.insert('settings', {'key': entry.key, 'value': entry.value});
    }
  }

  /// Gets the total database file size in bytes.
  Future<int> getDatabaseSize() async {
    final db = await DatabaseService.instance.database;
    final result = await db.rawQuery("PRAGMA page_count");
    final pageCount = result.first.values.first as int? ?? 0;
    final pageSizeResult = await db.rawQuery("PRAGMA page_size");
    final pageSize = pageSizeResult.first.values.first as int? ?? 4096;
    return pageCount * pageSize;
  }

  /// Clears all data from the database (all tables).
  Future<void> clearAllData() async {
    final db = await DatabaseService.instance.database;
    final tables = [
      'notes',
      'timers',
      'alarms',
      'reminders',
      'todos',
      'conversation_history',
    ];
    for (final table in tables) {
      await db.delete(table);
    }
  }
}
