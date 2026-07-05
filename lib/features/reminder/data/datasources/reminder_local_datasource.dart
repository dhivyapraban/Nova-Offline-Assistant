import 'package:nova_assistant/core/services/database_service.dart';
import '../models/reminder_model.dart';

class ReminderLocalDatasource {
  Future<List<ReminderModel>> getAll() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('reminders', orderBy: 'remind_at ASC');
    return maps.map((m) => ReminderModel.fromMap(m)).toList();
  }

  Future<void> insert(ReminderModel reminder) async {
    final db = await DatabaseService.instance.database;
    await db.insert('reminders', reminder.toMap());
  }

  Future<void> update(ReminderModel reminder) async {
    final db = await DatabaseService.instance.database;
    await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> delete(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
