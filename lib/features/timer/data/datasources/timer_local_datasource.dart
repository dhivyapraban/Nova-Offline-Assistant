import 'package:nova_assistant/core/services/database_service.dart';
import '../models/timer_model.dart';

class TimerLocalDatasource {
  Future<List<TimerModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('timers', orderBy: 'created_at DESC');
    return maps.map((m) => TimerModel.fromMap(m)).toList();
  }

  Future<void> insert(TimerModel timer) async {
    final db = await DatabaseService.instance.database;
    await db.insert('timers', timer.toMap());
  }

  Future<void> update(TimerModel timer) async {
    final db = await DatabaseService.instance.database;
    await db.update('timers', timer.toMap(), where: 'id = ?', whereArgs: [timer.id]);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('timers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await DatabaseService.instance.database;
    await db.delete('timers');
  }
}
