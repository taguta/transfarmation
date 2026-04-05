import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transfarmation.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Farm offline cache table
    await db.execute('''
      CREATE TABLE farms (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // Marketplace cache
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // Generic Sync Queue for mutations performed entirely offline
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection TEXT NOT NULL,
        documentId TEXT NOT NULL,
        operation TEXT NOT NULL, 
        payload TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
