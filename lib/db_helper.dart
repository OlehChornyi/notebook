import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  //1.Creation of database
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
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE my_table (
            id INTEGER PRIMARY KEY,
            value TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
    );
  }
  //3.Insert values in database table
  Future<void> insertValue(String value) async {
    final Database db = await database;
    await db.insert(
      'my_table',
      {
        'value': value,
        'created_at': DateTime.now().toUtc().toString(),
        'updated_at': DateTime.now().toUtc().toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  //4.Receive values from database table
  Future<List<Map<String, dynamic>>> getValues() async {
    final Database db = await database;
    return await db.query('my_table');
  }
  //5.Delete values from database table
  Future<void> deleteValue(int id) async {
    final Database db = await database;
    await db.delete(
      'my_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //6.Get specific value from database table
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
  //7.Update specific value in database table
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
}
