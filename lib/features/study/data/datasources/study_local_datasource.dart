import 'package:uuid/uuid.dart';

import 'package:nova_assistant/core/services/database_service.dart';
import '../models/study_document_model.dart';

/// Local datasource for study assistant feature.
class StudyLocalDatasource {
  static const _documentsTable = 'study_documents';
  static const _bookmarksTable = 'study_bookmarks';

  /// Ensures the required database tables exist.
  Future<void> ensureTables() async {
    final db = await DatabaseService.instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_documentsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL UNIQUE,
        page_count INTEGER NOT NULL DEFAULT 0,
        last_page INTEGER NOT NULL DEFAULT 0,
        opened_at TEXT NOT NULL,
        bookmarked_pages TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_bookmarksTable (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES $_documentsTable(id)
      )
    ''');
  }

  Future<List<StudyDocumentModel>> getDocuments() async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(_documentsTable, orderBy: 'opened_at DESC');
    return maps.map((m) => StudyDocumentModel.fromMap(m)).toList();
  }

  Future<StudyDocumentModel> openDocument(String filePath) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;

    // Check if document already exists
    final existing = await db.query(
      _documentsTable,
      where: 'file_path = ?',
      whereArgs: [filePath],
    );

    if (existing.isNotEmpty) {
      // Update opened_at timestamp
      await db.update(
        _documentsTable,
        {'opened_at': DateTime.now().toIso8601String()},
        where: 'file_path = ?',
        whereArgs: [filePath],
      );
      final updated = await db.query(
        _documentsTable,
        where: 'file_path = ?',
        whereArgs: [filePath],
      );
      return StudyDocumentModel.fromMap(updated.first);
    }

    // Create new document entry
    final fileName = filePath.split('/').last.split('\\').last;
    final title = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    final doc = StudyDocumentModel(
      id: const Uuid().v4(),
      title: title,
      filePath: filePath,
      pageCount: 0,
      lastPage: 0,
      openedAt: DateTime.now(),
      bookmarkedPages: [],
    );

    await db.insert(_documentsTable, doc.toMap());
    return doc;
  }

  Future<BookmarkModel> addBookmark(
    String documentId,
    int pageNumber, {
    String? note,
  }) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;

    final bookmark = BookmarkModel(
      id: const Uuid().v4(),
      documentId: documentId,
      pageNumber: pageNumber,
      note: note,
      createdAt: DateTime.now(),
    );

    await db.insert(_bookmarksTable, bookmark.toMap());

    // Update bookmarked_pages in document
    final docMaps = await db.query(
      _documentsTable,
      where: 'id = ?',
      whereArgs: [documentId],
    );
    if (docMaps.isNotEmpty) {
      final doc = StudyDocumentModel.fromMap(docMaps.first);
      if (!doc.bookmarkedPages.contains(pageNumber)) {
        final updatedPages = [...doc.bookmarkedPages, pageNumber];
        await db.update(
          _documentsTable,
          {'bookmarked_pages': updatedPages.join(',')},
          where: 'id = ?',
          whereArgs: [documentId],
        );
      }
    }

    return bookmark;
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    await db.delete(
      _bookmarksTable,
      where: 'id = ?',
      whereArgs: [bookmarkId],
    );
  }

  Future<List<BookmarkModel>> getBookmarks(String documentId) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _bookmarksTable,
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'page_number ASC',
    );
    return maps.map((m) => BookmarkModel.fromMap(m)).toList();
  }

  Future<List<StudyDocumentModel>> searchDocuments(String query) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      _documentsTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'opened_at DESC',
    );
    return maps.map((m) => StudyDocumentModel.fromMap(m)).toList();
  }

  Future<void> updateLastPage(String documentId, int page) async {
    await ensureTables();
    final db = await DatabaseService.instance.database;
    await db.update(
      _documentsTable,
      {'last_page': page},
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }
}
