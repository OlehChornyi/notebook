import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
  Future<Database> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE my_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value TEXT,
            created_at TEXT,
            updated_at TEXT,
            catalog_name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE archive_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value TEXT,
            created_at TEXT,
            updated_at TEXT,
            catalog_name TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertValue(String value, String catalogName) async {
    final Database db = await database;
    await db.insert(
      'my_table',
      {
        'value': value,
        'created_at': DateTime.now().toUtc().toString(),
        'updated_at': DateTime.now().toUtc().toString(),
        'catalog_name': catalogName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNoteAndArchive(int id) async {
    final Database db = await database;
    // Get the note to be deleted
    final noteToDelete = await db.query('my_table', where: 'id = ?', whereArgs: [id]);
    if (noteToDelete.isNotEmpty) {
      // Insert the note into the archive table
      await db.insert('archive_table', noteToDelete.first, conflictAlgorithm: ConflictAlgorithm.rollback);
      // Delete the note from the main table
      await db.delete('my_table', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<List<Map<String, dynamic>>> getValues() async {
    final Database db = await database;
    return await db.query('my_table');
  }

  Future<List<Map<String, dynamic>>> getArchivedNotes() async {
    final Database db = await database;
    return await db.query('archive_table');
  }

  Future<void> deleteValue(int id) async {
    final Database db = await database;
    await db.delete(
      'my_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFromArchive(int id) async {
    final Database db = await database;
    await db.delete(
      'archive_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getDetailById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'my_table',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      // Assuming 'value' is the column name in my_table
      return result[0]['value'].toString();
    } else {
      return null; // No record found for the given ID
    }
  }

  Future<String?> getArchiveDetailById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'archive_table',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      // Assuming 'value' is the column name in my_table
      return result[0]['value'].toString();
    } else {
      return null; // No record found for the given ID
    }
  }

  void updateRecord(int id, String newValue) async {
    final Database db = await database;
    await db.update(
      'my_table',
      {
        'value': newValue,
        'updated_at': DateTime.now().toUtc().toString(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCatalogName(int id, String newCatalogName) async {
    final Database db = await database;
    await db.update(
      'my_table',
      {'catalog_name': newCatalogName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getNotesByCatalogName(String catalogName) async {
    final Database db = await database;
    return await db.query('my_table', where: 'catalog_name = ?', whereArgs: [catalogName]);
  }
}
