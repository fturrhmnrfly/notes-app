import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'notes.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            category TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('notes', data);
  }

  Future<List<Map<String, dynamic>>> fetchAllNotes() async {
    final db = await database;
    return db.query('notes', orderBy: 'createdAt DESC');
  }

  Future<int> deleteNoteById(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
