import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite database service
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nova_assistant.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        color INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Timers table
    await db.execute('''
      CREATE TABLE timers (
        id TEXT PRIMARY KEY,
        label TEXT,
        duration_seconds INTEGER NOT NULL,
        remaining_seconds INTEGER NOT NULL,
        is_running INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Alarms table
    await db.execute('''
      CREATE TABLE alarms (
        id TEXT PRIMARY KEY,
        label TEXT,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        repeat_days TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        remind_at TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Todos table
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Conversation history table
    await db.execute('''
      CREATE TABLE conversation_history (
        id TEXT PRIMARY KEY,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        intent TEXT,
        action_json TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'key': 'assistant_name', 'value': 'Nova'});
    await db.insert('settings', {'key': 'voice_id', 'value': 'default'});
    await db.insert('settings', {'key': 'listening_mode', 'value': 'push_to_talk'});
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
