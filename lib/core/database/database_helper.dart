import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'platform_init.dart';
import 'schema.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseSchema.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Inicializar FFI o Web según la plataforma
    initPlatformDatabase();

    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: DatabaseSchema.version,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    final batch = db.batch();
    for (final sql in DatabaseSchema.allCreateTableStatements) {
      batch.execute(sql);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
