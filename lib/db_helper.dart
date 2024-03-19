import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  //1.Setup of database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
  //2.Initialization of database
  Future<Database> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      //2.1.Creation of my_table
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
        //2.2. Creation of archive_table
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
  //3.Insert values in  my_table
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
  //3.1. Insert values in  archive_table and delete from my_table
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
  // Future<void> deleteNoteAndArchive(int id) async {
  //   final Database db = await database;
  //
  //   // Get the note to be deleted
  //   final noteToDelete = await db.query('my_table', where: 'id = ?', whereArgs: [id]);
  //
  //   if (noteToDelete.isNotEmpty) {
  //     // Check if the ID already exists in the archive_table
  //     final existingIds = await db.query('archive_table',
  //         columns: ['id'],
  //         where: 'id = ?',
  //         whereArgs: [id]);
  //
  //     int newId;
  //
  //     // If the ID already exists in the archive_table, choose a new ID
  //     if (existingIds.isNotEmpty) {
  //       newId = await _getNewArchiveId(db);
  //     } else {
  //       // Use the existing ID
  //       newId = id;
  //     }
  //
  //     // Insert the note into the archive table with the new ID
  //     await db.insert('archive_table', {
  //       'id': newId,
  //       'value': noteToDelete.first['value'], // Assuming 'value' is a column in your table
  //     });
  //
  //     // Delete the note from the main table
  //     await db.delete('my_table', where: 'id = ?', whereArgs: [id]);
  //   }
  // }
  //
  // Future<int> _getNewArchiveId(Database db) async {
  //   // This function should return a new ID that doesn't exist in the archive_table
  //   int newId = 1; // Starting new ID, you might want to implement a more robust logic
  //   final existingIds = await db.query('archive_table', columns: ['id']);
  //
  //   while (existingIds.any((row) => row['id'] == newId)) {
  //     newId++; // Increment new ID until a unique one is found
  //   }
  //
  //   return newId;
  // }
  //4.Receive values from my_table
  Future<List<Map<String, dynamic>>> getValues() async {
    final Database db = await database;
    return await db.query('my_table');
  }
  //4.1. Receive values from archive_table
  Future<List<Map<String, dynamic>>> getArchivedNotes() async {
    final Database db = await database;
    return await db.query('archive_table');
  }
  //5.Delete values from  my_table
  Future<void> deleteValue(int id) async {
    final Database db = await database;
    await db.delete(
      'my_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //5.1. Delete values from archive_table
  Future<void> deleteFromArchive(int id) async {
    final Database db = await database;
    await db.delete(
      'archive_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //6.Get specific value from my_table
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
  //6.1. Get specific value from archive_table
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
  //7.Update specific value in my_table
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
  //8. Update catalog_name for a specific record in my_table
  Future<void> updateCatalogName(int id, String newCatalogName) async {
    final Database db = await database;
    await db.update(
      'my_table',
      {'catalog_name': newCatalogName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Load notes with a specific catalog_name
  Future<List<Map<String, dynamic>>> getNotesByCatalogName(String catalogName) async {
    final Database db = await database;
    return await db.query('my_table', where: 'catalog_name = ?', whereArgs: [catalogName]);
  }
}
