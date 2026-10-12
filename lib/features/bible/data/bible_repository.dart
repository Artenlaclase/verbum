import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/bible_reference_parser.dart';
import '../models/bible_book.dart';
import '../models/bible_verse.dart';
import 'bible_initial_data.dart';

class BibleRepository {
  final DatabaseHelper _dbHelper;

  BibleRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Asegura que los metadatos de los libros y los versículos semilla estén en la base de datos
  Future<void> ensureInitialized() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM libros'),
    );

    if (count == null || count == 0) {
      await db.transaction((txn) async {
        // 1. Insertar versión RVR09
        await txn.insert(
          'versiones',
          BibleInitialData.versionRVR09,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // 2. Insertar los 66 libros
        for (final book in BibleInitialData.books) {
          await txn.insert(
            'libros',
            book.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // 3. Insertar versículos semilla
        for (final verse in BibleInitialData.seedVerses) {
          await txn.insert(
            'versiculos',
            verse.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    }
  }

  /// Retorna la lista de todos los libros ordenados canónicamente
  Future<List<BibleBook>> getBooks({String? testamento}) async {
    await ensureInitialized();
    final db = await _dbHelper.database;

    List<Map<String, dynamic>> maps;
    if (testamento != null) {
      maps = await db.query(
        'libros',
        where: 'testamento = ?',
        whereArgs: [testamento],
        orderBy: 'orden ASC',
      );
    } else {
      maps = await db.query('libros', orderBy: 'orden ASC');
    }

    return maps.map((map) {
      final book = BibleInitialData.books.firstWhere(
        (b) => b.id == map['id'],
        orElse: () => BibleBook.fromMap(map),
      );
      return book;
    }).toList();
  }

  /// Obtiene un libro por su ID
  Future<BibleBook?> getBookById(int id) async {
    await ensureInitialized();
    try {
      return BibleInitialData.books.firstWhere((b) => b.id == id);
    } catch (_) {
      final db = await _dbHelper.database;
      final maps = await db.query('libros', where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) {
        return BibleBook.fromMap(maps.first);
      }
      return null;
    }
  }

  /// Obtiene los versículos de un libro y capítulo específico
  Future<List<BibleVerse>> getVerses(int libroId, int capitulo) async {
    await ensureInitialized();
    final db = await _dbHelper.database;

    final maps = await db.rawQuery('''
      SELECT v.*, l.nombre AS libro_nombre, l.abreviatura AS libro_abreviatura
      FROM versiculos v
      JOIN libros l ON v.libro_id = l.id
      WHERE v.libro_id = ? AND v.capitulo = ?
      ORDER BY v.numero ASC
    ''', [libroId, capitulo]);

    if (maps.isNotEmpty) {
      return maps.map((m) => BibleVerse.fromMap(m)).toList();
    }

    // Si los versículos de este capítulo específico aún no están poblados en la BD SQLite local,
    // proveemos una representación legible y respetuosa para que la lectura fluya en el MVP
    final book = await getBookById(libroId);
    return List.generate(15, (index) {
      final num = index + 1;
      return BibleVerse(
        id: (libroId * 10000) + (capitulo * 100) + num,
        libroId: libroId,
        capitulo: capitulo,
        numero: num,
        texto: '[$num] Texto bíblico de ${book?.nombre ?? "Libro"} $capitulo:$num (RVR09).',
        libroNombre: book?.nombre,
        libroAbreviatura: book?.abreviatura,
      );
    });
  }

  /// Búsqueda por texto o palabra clave
  Future<List<BibleVerse>> searchVerses(String query) async {
    await ensureInitialized();
    if (query.trim().isEmpty) return [];

    final parsed = BibleReferenceParser.parse(query);
    if (parsed != null) {
      // Búsqueda por cita directa
      final book = findBookByQuery(parsed.bookQuery);
      if (book != null) {
        final chapterVerses = await getVerses(book.id, parsed.chapter);
        if (parsed.startVerse != null) {
          final end = parsed.endVerse ?? parsed.startVerse!;
          return chapterVerses
              .where((v) => v.numero >= parsed.startVerse! && v.numero <= end)
              .toList();
        }
        return chapterVerses;
      }
    }

    final db = await _dbHelper.database;
    final pattern = '%${query.trim()}%';
    final maps = await db.rawQuery('''
      SELECT v.*, l.nombre AS libro_nombre, l.abreviatura AS libro_abreviatura
      FROM versiculos v
      JOIN libros l ON v.libro_id = l.id
      WHERE v.texto LIKE ?
      ORDER BY l.orden ASC, v.capitulo ASC, v.numero ASC
      LIMIT 50
    ''', [pattern]);

    return maps.map((m) => BibleVerse.fromMap(m)).toList();
  }

  BibleBook? findBookByQuery(String query) {
    final clean = query.trim().toLowerCase();
    for (final b in BibleInitialData.books) {
      if (b.nombre.toLowerCase() == clean ||
          b.abreviatura.toLowerCase() == clean ||
          b.nombre.toLowerCase().startsWith(clean) ||
          clean.startsWith(b.nombre.toLowerCase())) {
        return b;
      }
    }
    return null;
  }
}
