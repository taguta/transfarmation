
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  static Future<Database> init() async {
    return openDatabase(
      join(await getDatabasesPath(), 'agrolink.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE loans(
          id TEXT PRIMARY KEY,
          farmerId TEXT,
          amount REAL,
          status TEXT,
          createdAt TEXT,
          isSynced INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE sync_queue(
          id TEXT PRIMARY KEY,
          type TEXT,
          payload TEXT,
          retryCount INTEGER
        )
        ''');
      },
    );
  }
}
