import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:nova_assistant/core/services/database_service.dart';
import '../../domain/entities/file_item.dart';
import '../models/file_item_model.dart';

/// Local datasource for file explorer feature.
class FileLocalDatasource {
  static const _filesTable = 'files';

  static const _extensionTypeMap = <String, FileType>{
    'pdf': FileType.pdf,
    'doc': FileType.docx,
    'docx': FileType.docx,
    'ppt': FileType.ppt,
    'pptx': FileType.ppt,
    'jpg': FileType.image,
    'jpeg': FileType.image,
    'png': FileType.image,
    'gif': FileType.image,
    'webp': FileType.image,
    'bmp': FileType.image,
    'mp3': FileType.audio,
    'm4a': FileType.audio,
    'wav': FileType.audio,
    'flac': FileType.audio,
    'aac': FileType.audio,
    'ogg': FileType.audio,
    'mp4': FileType.video,
    'mkv': FileType.video,
    'avi': FileType.video,
    'mov': FileType.video,
    'webm': FileType.video,
  };

  /// Ensures the required database tables exist.
  Future<void> ensureTables() async {
    final db = await DatabaseService.instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_filesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        path TEXT NOT NULL UNIQUE,
        extension TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        modified_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL
      )
    ''');
  }

  /// Scans common directories for files and caches them.
  Future<List<FileItemModel>> scanFiles() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    const uuid = Uuid();

    final directories = <Directory>[];

    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final rootPath = extDir.path.split('Android').first;
        final commonDirs = ['Documents', 'Download', 'Pictures', 'Music', 'Movies'];
        for (final name in commonDirs) {
          final dir = Directory('$rootPath$name');
          if (await dir.exists()) directories.add(dir);
        }
      }
    } catch (_) {}

    try {
      final appDir = await getApplicationDocumentsDirectory();
      directories.add(appDir);
    } catch (_) {}

    final files = <FileItemModel>[];

    for (final dir in directories) {
      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final stat = await entity.stat();
            final fileName = entity.path.split(Platform.pathSeparator).last;
            final ext = fileName.contains('.')
                ? fileName.split('.').last.toLowerCase()
                : '';
            final fileType = _extensionTypeMap[ext] ?? FileType.other;

            final model = FileItemModel(
              id: uuid.v4(),
              name: fileName,
              path: entity.path,
              extension: ext,
              sizeBytes: stat.size,
              modifiedAt: stat.modified,
              isFavorite: false,
              type: fileType,
            );

            await db.insert(
              _filesTable,
              model.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            files.add(model);
          }
        }
      } catch (_) {
        // Skip inaccessible directories
      }
    }

    return files;
  }

  Future<List<FileItemModel>> getAllFiles({FileType? filterType}) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = filterType != null
        ? await db.query(
            _filesTable,
            where: 'type = ?',
            whereArgs: [filterType.name],
            orderBy: 'modified_at DESC',
          )
        : await db.query(_filesTable, orderBy: 'modified_at DESC');
    return maps.map((m) => FileItemModel.fromMap(m)).toList();
  }

  Future<List<FileItemModel>> searchFiles(String query) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _filesTable,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'modified_at DESC',
    );
    return maps.map((m) => FileItemModel.fromMap(m)).toList();
  }

  Future<List<FileItemModel>> getRecentFiles() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _filesTable,
      orderBy: 'modified_at DESC',
      limit: 20,
    );
    return maps.map((m) => FileItemModel.fromMap(m)).toList();
  }

  Future<void> toggleFavorite(String fileId) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _filesTable,
      where: 'id = ?',
      whereArgs: [fileId],
    );
    if (maps.isEmpty) return;
    final current = maps.first['is_favorite'] as int;
    await db.update(
      _filesTable,
      {'is_favorite': current == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  Future<List<FileItemModel>> getFavorites() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _filesTable,
      where: 'is_favorite = 1',
      orderBy: 'name ASC',
    );
    return maps.map((m) => FileItemModel.fromMap(m)).toList();
  }

  Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }
}
